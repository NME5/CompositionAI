import 'dart:async';
import 'package:flutter/material.dart';
import '../views/scale_measurement_page.dart';
import '../views/body_analysis_page.dart';
import '../services/body_composition_calculator.dart';
import '../services/data_service.dart';

class ConnectScaleDialog {
  static void show(BuildContext context, {required Function(String deviceName) onConnected}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScaleMeasurementPage(
          onConnected: onConnected,
        ),
      ),
    );
  }
}

class MeasurementDialog extends StatefulWidget {
  @override
  State<MeasurementDialog> createState() => _MeasurementDialogState();
}

class BodyAnalysisDialog {
  static Future<void> show(BuildContext context, {required BodyCompositionResult compositionResult, DateTime? measurementDate}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return Container(
          height: screenHeight * 0.96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Grab handle
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        Text('Body Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(width: 48),
                      ],
                    ),
                    SizedBox(height: 10,),
                    
                    Divider(color: Colors.grey[200], height: 1),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: BodyAnalysisContent(
                    result: compositionResult,
                    measurementDate: measurementDate,
                    userProfile: DataService().getUserProfile(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showFullScreen(BuildContext context, {required BodyCompositionResult compositionResult, bool replaceCurrent = false, DateTime? measurementDate}) async {
    final route = PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      reverseTransitionDuration: Duration(milliseconds: 250),
      fullscreenDialog: true,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                            Text('Body Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(width: 48),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.grey[200], height: 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: BodyAnalysisContent(
                        result: compositionResult,
                        measurementDate: measurementDate,
                        userProfile: DataService().getUserProfile(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final offsetTween = Tween<Offset>(begin: Offset(0, 0.05), end: Offset.zero);
        return SlideTransition(position: offsetTween.animate(curved), child: child);
      },
    );

    if (replaceCurrent) {
      await Navigator.pushReplacement(context, route);
    } else {
      await Navigator.push(context, route);
    }
  }
}

class _MeasurementDialogState extends State<MeasurementDialog> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
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
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          
          SizedBox(height: 32),
          Text('Step on the Scale', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Stand still for accurate measurement', style: TextStyle(color: Colors.grey[600])),
          
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
                            return CircularProgressIndicator(
                              value: _progressAnimation.value,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
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
                          Text('Analyzing...', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Measuring body composition', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                      ],
                    ),
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
                _buildMeasurementStep(0, 'Weight detected', _currentStep >= 0),
                SizedBox(height: 16),
                _buildMeasurementStep(1, 'Analyzing impedance', _currentStep >= 1),
                SizedBox(height: 16),
                _buildMeasurementStep(2, 'Calculating composition', _currentStep >= 2),
              ],
            ),
          ),
        ],
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

