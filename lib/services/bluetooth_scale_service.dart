import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/scale_reading.dart';
import '../models/user_profile.dart';
import 'composition_calculator.dart';

/// Bluetooth Scale Service
/// Handles BLE scanning, device connection, and data parsing from scale manufacturer data
class BluetoothScaleService {
  static final BluetoothScaleService _instance = BluetoothScaleService._internal();
  factory BluetoothScaleService() => _instance;
  BluetoothScaleService._internal();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamController<ScaleReading>? _readingController;
  StreamController<String>? _deviceController;
  
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
      await stopScanning();
    }

    if (targetMacAddress != null && targetMacAddress.isNotEmpty) {
      targetMac = targetMacAddress.toUpperCase();
    }

    _readingController = StreamController<ScaleReading>.broadcast();
    _deviceController = StreamController<String>.broadcast();

    // Check if Bluetooth is available
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth not supported on this device');
    }

    // Request permissions and turn on Bluetooth
    await FlutterBluePlus.turnOn();

    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (List<ScanResult> results) {
        for (ScanResult result in results) {
          _processScanResult(result);
        }
      },
      onError: (error) {
        print('BLE Scan error: $error');
      },
    );

    // Start scanning with filters
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await FlutterBluePlus.stopScan();
    await _readingController?.close();
    await _deviceController?.close();
    _readingController = null;
    _deviceController = null;
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
        }
      }
    } catch (e) {
      print('Error processing scan result: $e');
    }
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

      return ScaleReading(
        weightKg: weightKg,
        impedanceOhm: impedanceOhm,
        unitStatus: unitStatus,
        rawHex: rawHex,
        mfgId: mfgId,
        rssi: rssi,
      );
    } catch (e) {
      print('Error parsing payload: $e');
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
      return null;
    }

    final isMale = userProfile.gender.toLowerCase() == 'male';
    
    return BodyCompositionCalculator.calculateAll(
      weightKg: reading.weightKg!,
      impedanceOhm: reading.impedanceOhm,
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
