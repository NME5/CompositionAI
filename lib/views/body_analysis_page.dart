import 'dart:async';
import 'package:flutter/material.dart';
import '../services/composition_calculator.dart';

class BodyAnalysisPage extends StatefulWidget {
  final BodyCompositionResult? compositionResult;
  
  const BodyAnalysisPage({this.compositionResult});

  @override
  State<BodyAnalysisPage> createState() => _BodyAnalysisPageState();
}

class _BodyAnalysisPageState extends State<BodyAnalysisPage> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  int _currentStep = 0;
  
  // Body composition metrics from calculated result or default values
  late Map<String, double> _bodyMetrics;
  
  @override
  void initState() {
    super.initState();
    
    // Use calculated result or default values
    if (widget.compositionResult != null) {
      final result = widget.compositionResult!;
      _bodyMetrics = {
        'bodyFat': result.bfrPercent,
        'muscleMass': result.slmPercent,
        'water': result.tfrPercent,
        'boneMass': result.boneMassKg,
      };
    } else {
      // Default values if no result provided
      _bodyMetrics = {
        'bodyFat': 20,
        'muscleMass': 20,
        'water': 40,
        'boneMass': 20,
      };
    }
    
    _progressController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _startMeasurement();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startMeasurement() {
    _progressController.forward();
    
    Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
        Future.delayed(Duration(seconds: 1), () {
          // Navigator.pop(context);
        });
      }
    });
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
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  Text('Body Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 48),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            Text(
              'Your Body Composition',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Analyzing your body metrics breakdown',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32),
            // Progress Circle
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: MultiColorProgressPainter(
                                  progress: _progressAnimation.value,
                                  metrics: _bodyMetrics,
                                ),
                                child: Container(),
                              );
                            },
                          ),
                        ),
                        Column(
                          children: [
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Text(
                                  '${(_progressAnimation.value * 100).round()}%',
                                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Text(
                                  _progressAnimation.value < 1.0 
                                    ? 'Analyzing...' 
                                    : 'Complete',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        if (_progressAnimation.value < 1.0) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF667EEA),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Analyzing composition',
                                  style: TextStyle(
                                    color: Color(0xFF667EEA),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Analysis complete',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Measurement Steps
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Weight: ${_bodyMetrics['weight']} kg'),
                  SizedBox(height: 16),
                  Text('Weight: ${_bodyMetrics['unit']} kg'),
                  SizedBox(height: 16),
                  _buildMeasurementStep(2, 'Calculating composition', _currentStep >= 2),
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
            color: isCompleted ? Colors.green : (isActive ? Colors.blue : Colors.grey[300]),
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

class MultiColorProgressPainter extends CustomPainter {
  final double progress;
  final Map<String, double> metrics;
  
  MultiColorProgressPainter({
    required this.progress,
    required this.metrics,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 8.0;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);
    
    // Calculate arc segments for each metric
    // Normalize values so they fit in the circle (they should add up to represent total)
    double total = metrics['bodyFat']! + metrics['muscleMass']! + metrics['water']! + metrics['boneMass']!;
    double normalizedBodyFat = (metrics['bodyFat']! / total) * 100;
    double normalizedMuscle = (metrics['muscleMass']! / total) * 100;
    double normalizedWater = (metrics['water']! / total) * 100;
    double normalizedBone = (metrics['boneMass']! / total) * 100;
    
    // Start angle (top of circle)
    double startAngle = -90 * (3.14159 / 180); // Start from top (-90 degrees in radians)
    
    // Paint for each segment
    final bodyFatPaint = Paint()
      ..color = Colors.yellowAccent // Yellow for body fat
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final musclePaint = Paint()
      ..color = Colors.redAccent // Red for muscle
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final waterPaint = Paint()
      ..color = Color(0xFF339AF0) // Blue for water
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final bonePaint = Paint()
      ..color = const Color.fromARGB(255, 253, 253, 200) // bone white for bone
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw each segment with animation
    double sweepAngle = 2 * 3.14159; // Full circle in radians
    double currentAngle = startAngle;
    
    // Body Fat segment
    double bodyFatSweep = (normalizedBodyFat / 100) * sweepAngle * progress;
    if (bodyFatSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        currentAngle,
        bodyFatSweep,
        false,
        bodyFatPaint,
      );
      currentAngle += bodyFatSweep;
    }
    
    // Muscle Mass segment
    double muscleSweep = (normalizedMuscle / 100) * sweepAngle * progress;
    if (muscleSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        currentAngle,
        muscleSweep,
        false,
        musclePaint,
      );
      currentAngle += muscleSweep;
    }
    
    // Water segment
    double waterSweep = (normalizedWater / 100) * sweepAngle * progress;
    if (waterSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        currentAngle,
        waterSweep,
        false,
        waterPaint,
      );
      currentAngle += waterSweep;
    }
    
    // Bone Mass segment
    double boneSweep = (normalizedBone / 100) * sweepAngle * progress;
    if (boneSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        currentAngle,
        boneSweep,
        false,
        bonePaint,
      );
    }
  }

  @override
  bool shouldRepaint(MultiColorProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.metrics != metrics;
  }
}

