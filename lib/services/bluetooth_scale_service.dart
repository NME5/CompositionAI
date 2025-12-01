import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/scale_reading.dart';
import '../models/user_profile.dart';
import 'body_composition_calculator.dart';

/// Bluetooth Scale Service
/// Handles BLE scanning, device connection, and data parsing from scale manufacturer data
class BluetoothScaleService {
  static final BluetoothScaleService _instance = BluetoothScaleService._internal();
  factory BluetoothScaleService() => _instance;
  BluetoothScaleService._internal();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamController<ScaleReading>? _readingController;
  StreamController<String>? _deviceController;
  Timer? _scanRestartTimer;
  bool _keepAlive = false;
  bool _hasNonZeroImpedance = false;
  
  /// Target MAC address (empty string to accept any scale)
  String targetMac = "";

  /// Stream of scale readings
  Stream<ScaleReading>? get readingStream => _readingController?.stream;

  /// Stream of device names found
  Stream<String>? get deviceStream => _deviceController?.stream;

  bool get isScanning => _scanSubscription != null;

  /// Start scanning for BLE scales
  Future<void> startScanning({String? targetMacAddress}) async {
    if (isScanning) {
      print('[BLE] startScanning: already scanning, stopping previous scan first');
      await stopScanning();
    }

    if (targetMacAddress != null && targetMacAddress.isNotEmpty) {
      targetMac = targetMacAddress.toUpperCase();
      print('[BLE] startScanning: targetMac filter = $targetMac');
    }

    _readingController = StreamController<ScaleReading>.broadcast();
    _deviceController = StreamController<String>.broadcast();
    _keepAlive = true;
    _hasNonZeroImpedance = false;

    // Check if Bluetooth is available
    if (await FlutterBluePlus.isSupported == false) {
      print('[BLE] startScanning: Bluetooth not supported');
      throw Exception('Bluetooth not supported on this device');
    }

    // Request permissions and turn on Bluetooth
    print('[BLE] startScanning: turning on Bluetooth...');
    await FlutterBluePlus.turnOn();

    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (List<ScanResult> results) {
        print('[BLE] scanResults: batch size = ${results.length}');
        for (ScanResult result in results) {
          _processScanResult(result);
        }
      },
      onError: (error) {
        print('[BLE] scanResults error: $error');
      },
    );

    // Start scanning with filters
    print('[BLE] startScanning: starting scan (10s timeout)');
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );

    // Ensure scanning keeps running while impedance stays 0 and dialog/page is open
    _scheduleScanRestart();
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    print('[BLE] stopScanning: requested');
    _keepAlive = false;
    _hasNonZeroImpedance = false;
    _scanRestartTimer?.cancel();
    _scanRestartTimer = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('[BLE] stopScan error: $e');
    }
    await _readingController?.close();
    await _deviceController?.close();
    _readingController = null;
    _deviceController = null;
    print('[BLE] stopScanning: completed');
  }

  /// Process a scan result and extract scale data
  void _processScanResult(ScanResult result) {
    try {
      final device = result.device;
      final address = device.remoteId.str.toUpperCase();

      // Filter by target MAC if specified
      if (targetMac.isNotEmpty && address != targetMac) {
        return;
      }

      // Check manufacturer data
      final manufacturerData = result.advertisementData.manufacturerData;
      
      for (var entry in manufacturerData.entries) {
        final companyId = entry.key;
        final dataList = entry.value;

        // Expect 13-byte payload
        if (dataList.length != 13) {
          continue;
        }

        // Convert List<int> to Uint8List
        final data = Uint8List.fromList(dataList);

        // Parse the payload
        final reading = _parsePayload(data, companyId, result.rssi);
        
        if (reading != null) {
          // Emit device name if this is first reading from this device
          _deviceController?.add(device.advName.isNotEmpty 
              ? device.advName 
              : 'Scale $address');

          // Emit reading
          _readingController?.add(reading);

          // Mark when we first see a non-zero impedance to stop forced restarts
          if (reading.hasValidImpedance && reading.impedanceOhm > 0) {
            _hasNonZeroImpedance = true;
            print('[BLE] first non-zero impedance detected: ${reading.impedanceOhm.toStringAsFixed(1)} Ω');
          }

          print('[BLE] reading from $address (mfg=$companyId rssi=${result.rssi}): '
                'weightKg=${reading.weightKg?.toStringAsFixed(1) ?? 'null'}, '
                'impedance=${reading.impedanceOhm.toStringAsFixed(1)} Ω, '
                'unit=0x${reading.unitStatus.toRadixString(16)}');
        }
      }
    } catch (e) {
      print('[BLE] Error processing scan result: $e');
    }
  }

  /// Schedule periodic restart of scanning while impedance remains zero
  void _scheduleScanRestart() {
    _scanRestartTimer?.cancel();
    _scanRestartTimer = Timer.periodic(const Duration(seconds: 12), (timer) async {
      if (!_keepAlive) {
        print('[BLE] restart timer: keepAlive=false, cancel');
        timer.cancel();
        return;
      }
      if (_hasNonZeroImpedance) {
        // We have started receiving meaningful measurements; no need to force restarts
        // print('[BLE] restart timer: non-zero impedance observed, no restart');
        return;
      }
      try {
        // Restart scan to keep results flowing if platform auto-stopped after timeout
        print('[BLE] restart timer: restarting scan because impedance is still 0');
        await FlutterBluePlus.stopScan();
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 10),
          androidUsesFineLocation: true,
        );
      } catch (e) {
        print('[BLE] Error restarting scan: $e');
      }
    });
  }

  /// Parse 13-byte payload from scale manufacturer data
  /// bytes[0:2] BE -> weight ×100 (kg)
  /// bytes[2:4] BE -> impedance ×10 (ohm)
  /// byte[6] -> unit/status flag
  ScaleReading? _parsePayload(Uint8List payload, int mfgId, int rssi) {
    if (payload.length != 13) {
      return null;
    }

    try {
      // bytes[0:2] BE -> weight ×100 (kg)
      final weightRaw = (payload[0] << 8) | payload[1];
      
      // bytes[2:4] BE -> impedance ×10 (ohm)
      final impRaw = (payload[2] << 8) | payload[3];
      
      // byte[6] -> unit/status flag
      final unitStatus = payload[6];

      final weightKg = weightRaw == 0 ? null : (weightRaw / 100.0);
      final impedanceOhm = impRaw / 10.0;

      // Convert payload to hex string
      final rawHex = payload.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                            .join('');

      final reading = ScaleReading(
        weightKg: weightKg,
        impedanceOhm: impedanceOhm,
        unitStatus: unitStatus,
        rawHex: rawHex,
        mfgId: mfgId,
        rssi: rssi,
      );
      print('[BLE] parse payload: mfg=$mfgId rssi=$rssi raw=$rawHex -> '
            'weightKg=${weightKg?.toStringAsFixed(2) ?? 'null'}, '
            'impedance=${impedanceOhm.toStringAsFixed(1)} Ω, '
            'unit=0x${unitStatus.toRadixString(16)}');
      return reading;
    } catch (e) {
      print('[BLE] Error parsing payload: $e');
      return null;
    }
  }

  /// Parse full advertisement hex string (for testing/offline verification)
  /// Format: "10 FF C0 35 10 0E 17 70 0A 01 25 08 B8 D0 8B 3E D3"
  ScaleReading? parseFullAdHex(String adHex) {
    try {
      // Remove spaces and 0x prefixes
      adHex = adHex.replaceAll(' ', '').replaceAll('0x', '').toUpperCase();
      final bytes = Uint8List(
        adHex.length ~/ 2,
      );
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = int.parse(adHex.substring(i * 2, i * 2 + 2), radix: 16);
      }

      // Layout: [len][0xFF][cid_lo][cid_hi][13 bytes...]
      if (bytes.length < 4 || bytes[1] != 0xFF || bytes.length < 4 + 13) {
        return null;
      }

      // Little-endian company identifier
      final cid = bytes[2] | (bytes[3] << 8);
      final payload = bytes.sublist(4, 4 + 13);
      
      final reading = _parsePayload(payload, cid, 0);
      return reading;
    } catch (e) {
      print('Error parsing hex string: $e');
      return null;
    }
  }

  /// Calculate body composition from scale reading and user profile
  BodyCompositionResult? calculateComposition(
    ScaleReading reading,
    UserProfile userProfile,
  ) {
    if (!reading.hasValidWeight || !reading.hasValidImpedance) {
      print('[BLE] calculateComposition: invalid reading: '
            'hasWeight=${reading.hasValidWeight}, hasImpedance=${reading.hasValidImpedance}, '
            'weightKg=${reading.weightKg}, impedance=${reading.impedanceOhm}');
      return null;
    }

    final isMale = userProfile.gender.toLowerCase() == 'male';

    // Apply impedance offset calibration (e.g. +200 Ω) before calculations.
    // Adjust this value if you recalibrate the scale in the future.
    const double impedanceOffsetOhm = 400.0;
    final double calibratedImpedance = reading.impedanceOhm + impedanceOffsetOhm;
    
    return BodyCompositionCalculator.calculateAll(
      weightKg: reading.weightKg!,
      impedanceOhm: calibratedImpedance,
      heightCm: userProfile.height.toInt(),
      age: userProfile.age,
      isMale: isMale,
    );
  }

  /// Dispose resources
  void dispose() {
    stopScanning();
  }
}
