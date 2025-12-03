import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_scale_service.dart';
import '../services/data_service.dart';
import '../models/scale_reading.dart';
// import 'body_analysis_page.dart';
import '../widgets/dialogs.dart';
import '../navigation/route_observer.dart';

class ScaleMeasurementPage extends StatefulWidget {
  final Function(String deviceName)? onConnected;
  final String? targetMacAddress; // Optional: filter by specific MAC address
  
  const ScaleMeasurementPage({this.onConnected, this.targetMacAddress});

  @override
  State<ScaleMeasurementPage> createState() => _ScaleMeasurementPageState();
}

class _ScaleMeasurementPageState extends State<ScaleMeasurementPage> with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _progressController;
  
  final BluetoothScaleService _bluetoothService = BluetoothScaleService();
  final DataService _dataService = DataService();
  
  StreamSubscription<ScaleReading>? _readingSubscription;
  StreamSubscription<String>? _deviceSubscription;
  
  bool _isMeasuring = false;
  int _currentStep = 0;
  String _deviceName = '';
  ScaleReading? _latestReading;
  bool _hasValidReading = false;

  @override
  void initState() {
    super.initState();
    print('[UI] ScaleMeasurementPage.initState');
    _scanController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );
    
    // Start Bluetooth scanning
    print('[UI] Starting Bluetooth scanning...');
    _startBluetoothScanning();
  }
  
  Future<void> _startBluetoothScanning() async {
    try {
      await _bluetoothService.startScanning(targetMacAddress: widget.targetMacAddress);
      
      // Listen for device names
      _deviceSubscription = _bluetoothService.deviceStream?.listen((deviceName) {
        if (mounted && _deviceName.isEmpty) {
          setState(() {
            _deviceName = deviceName;
          });
          print('[UI] Device detected: $_deviceName');
        }
      });
      
      // Listen for scale readings
      _readingSubscription = _bluetoothService.readingStream?.listen((reading) {
        if (mounted) {
          setState(() {
            _latestReading = reading;
          });
          print('[UI] Reading update: weightKg=${reading.weightKg?.toStringAsFixed(1) ?? 'null'}, '
                'impedance=${reading.impedanceOhm.toStringAsFixed(1)} Ω, '
                'hasWeight=${reading.hasValidWeight}, hasImp=${reading.hasValidImpedance}, isMeasuring=$_isMeasuring');
          
          // Start measuring when we get a valid reading
          if (!_isMeasuring && reading.hasValidWeight) {
            print('[UI] Valid weight detected, starting measuring');
            _startMeasuring();
          }
          
          // Update progress based on impedance reading
          // When impedance > 0 and stable (~600), we're measuring
          if (_isMeasuring && reading.hasValidImpedance && reading.impedanceOhm > 50) {
            // Estimate progress: impedance goes from ~0 (measuring) to ~600 (stable)
            final impedanceProgress = (reading.impedanceOhm / 600.0).clamp(0.0, 1.0);
            _progressController.value = impedanceProgress;
            print('[UI] Impedance progress: ${(impedanceProgress * 100).toStringAsFixed(0)}% (ohm=${reading.impedanceOhm.toStringAsFixed(1)})');
            
            // Update steps and readiness without a separate step 3
            if (impedanceProgress >= 0.33 && _currentStep < 2) {
              setState(() => _currentStep = 2);
              print('[UI] Step advanced: 2 (Weight detected)');
            }
            if (impedanceProgress >= 0.66 && !_hasValidReading) {
              setState(() {
                _hasValidReading = true;
              });
              print('[UI] Measurement ready (impedance stable), proceeding to results');
              // When measurement is complete, navigate to results
              Future.delayed(Duration(seconds: 1), () {
                if (mounted && _hasValidReading && _latestReading != null) {
                  print('[UI] Navigating to results page');
                  _navigateToResults();
                }
              });
            }
          }
        }
      });
    } catch (e) {
      print('[UI] Bluetooth scanning error: $e');
      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bluetooth error: $e')),
        );
      }
    }
  }

  void _startMeasuring() {
    if (mounted) {
      setState(() {
        _isMeasuring = true;
        _currentStep = 1; // Step 0 (Scale detected) is completed, step 1 (Weight measured) becomes active
      });
      print('[UI] Measuring started: step=1');
      _progressController.value = 0.0;
    }
  }
  
  void _navigateToResults() {
    if (_latestReading == null || !_hasValidReading) return;
    
    // Calculate body composition
    final userProfile = _dataService.getUserProfile();
    final composition = _bluetoothService.calculateComposition(_latestReading!, userProfile);
    
    if (composition == null) {
      print('[UI] Composition calculation returned null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to calculate body composition. Please try again.')),
      );
      return;
    }
    
    // Persist measurement to history - store raw data (weight + calibrated impedance)
    // Calculations will be done on-the-fly using current calculation method
    try {
      // Get calibrated impedance (impedance + offset)
      const double impedanceOffsetOhm = 400.0;
      final double calibratedImpedance = _latestReading!.impedanceOhm + impedanceOffsetOhm;
      
      _dataService.addMeasurement(
        weightKg: composition.weightKg,
        calibratedImpedanceOhm: calibratedImpedance,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('[UI] Failed to save measurement: $e');
    }

    // Stop scanning
    print('[UI] Stopping scanning before navigation');
    _bluetoothService.stopScanning();
    
    // Call onConnected callback if provided
    if (widget.onConnected != null && _deviceName.isNotEmpty) {
      print('[UI] onConnected callback with device: $_deviceName');
      widget.onConnected!(_deviceName);
    }
    
    // Navigate to results page with calculated data
    if (mounted) {
      // Pop measurement page, then show an almost-full-screen, draggable bottom sheet over previous screen
      final measurementTimestamp = DateTime.now();
      Navigator.pop(context);
      Future.microtask(() {
        final ctx = appNavigatorKey.currentContext;
        if (ctx != null) {
          BodyAnalysisDialog.show(ctx, compositionResult: composition, measurementDate: measurementTimestamp);
        }
      });
    }
  }

  @override
  void dispose() {
    _readingSubscription?.cancel();
    _deviceSubscription?.cancel();
    _bluetoothService.stopScanning();
    _scanController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),

                      Text(
                        _isMeasuring ? 'Measuring' : 'Searching for Device',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),

                  SizedBox(height: 10),

                  Divider(color: Colors.grey[200], height: 1),
                ],
              ),
            ),
            
            // Scanning Animation & Available Devices (Scrollable)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanning Animation
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Pulsing Lingkaran
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, child) {
                              // Offset each lingkaran animation by a phase
                              double phase = (_scanController.value + (index * 0.33)) % 1.0;
                              // Scale from 1.0 to 2.0
                              double scale = 1.0 + (phase * 1.0);
                              // Opacity: fade in cepet (0-0.2), trus fade out pelan (0.2-1.0)
                              double opacity = phase < 0.2
                                ? 0.6 + (phase * 2.0)  // Quick fade in: 0.6 -> 1.0
                                : 1.0 - ((phase - 0.2) / 0.8);  // Slow fade out: 1.0 -> 0.0 over 0.8 phase
                              
                              // gelapin warna ke outer circle yang paling luar
                              Color color1 = Color.lerp(
                                Color(0xFF667EEA),
                                Color(0xFF4A5BA8), // Darker blue
                                phase,
                              )!;
                              Color color2 = Color.lerp(
                                Color(0xFF764BA2),
                                Color(0xFF5A3A7A), // Darker purple
                                phase,
                              )!;
                              
                              return Opacity(
                                opacity: opacity.clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [color1, color2]),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // Fixed inner circle with progress
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Color.fromARGB(255, 132, 162, 254), Color.fromARGB(255, 158, 91, 187)]),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _isMeasuring 
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${(_latestReading?.weightKg ?? 0).toStringAsFixed(1)}',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'kg',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  )
                                : Image.asset('assets/img/Composition Scale.png', width: 80, height: 80),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 35),
                    child: Column(
                      children: [
                        Text(
                          _isMeasuring ? 'Measuring Body Composition' : 'Step on the Scale',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isMeasuring 
                            ? 'Please stand still on the scale'
                            : 'Make sure your BIA scale is powered on and in pairing mode',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
             // Measurement Steps (removed step 3: Analyzing impedance)
             Padding(
               padding: EdgeInsets.all(24),
               child: Column(
                 children: [
                   _buildMeasurementStep(0, 'Scale detected', _currentStep >= 1),
                   SizedBox(height: 16),
                   _buildMeasurementStep(1, 'Weight detected', _currentStep >= 2),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementStep(int stepIndex, String label, bool isCompleted) {
    bool isActive = _currentStep == stepIndex;
    
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : (isActive ? Color(0xFF667EEA) : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted 
              ? Icon(Icons.check, color: Colors.white, size: 16)
              : Text('${stepIndex + 1}', style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
        SizedBox(width: 16),
        Text(
          label, 
          style: TextStyle(
            color: isCompleted || isActive ? Colors.black : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

