import 'dart:async';
import 'package:flutter/material.dart';
import 'body_analysis_page.dart';

class ScaleMeasurementPage extends StatefulWidget {
  final Function(String deviceName)? onConnected;
  
  const ScaleMeasurementPage({this.onConnected});

  @override
  State<ScaleMeasurementPage> createState() => _ScaleMeasurementPageState();
}

class _ScaleMeasurementPageState extends State<ScaleMeasurementPage> with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  double _progress = 0.0;
  bool _isMeasuring = false;
  int _currentStep = 0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });
    
    // Start measuring after a delay (when device is found)
    _startMeasuring();
  }

  void _startMeasuring() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isMeasuring = true;
          _currentStep = 1; // Step 0 (Weight detected) is completed, step 1 (Analyzing impedance) becomes active
        });
        _progressController.forward();
        
        // Update steps based on progress
        _progressController.addListener(() {
          final progress = _progressController.value;
          if (mounted) {
            if (progress >= 0.33 && _currentStep < 2) {
              setState(() => _currentStep = 2); // Step 1 completed, step 2 (Calculating composition) becomes active
            } else if (progress >= 0.66 && _currentStep < 3) {
              setState(() => _currentStep = 3); // Step 2 completed
            }
          }
        });
        
        // Navigate to BodyAnalysisPage when progress reaches 100% and all steps are completed
        _progressController.addStatusListener((status) {
          if (status == AnimationStatus.completed && _currentStep >= 3) {
            Future.delayed(Duration(seconds: 1), () {
              if (mounted) {
                if (widget.onConnected != null) {
                  widget.onConnected!('BodySync Pro X1'); // Mock device name
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BodyAnalysisPage()),
                );
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _progressController.dispose();
    _progressTimer?.cancel();
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
                                        '${_progress.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '%',
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
            
             // Measurement Steps
             Padding(
               padding: EdgeInsets.all(24),
               child: Column(
                 children: [
                   _buildMeasurementStep(0, 'Scale detected', _currentStep >= 1),
                   SizedBox(height: 16),
                   _buildMeasurementStep(1, 'Weight measured', _currentStep >= 2),
                   SizedBox(height: 16),
                   _buildMeasurementStep(2, 'Calculating composition', _currentStep >= 3),
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

