import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/data_service.dart';

class ConnectScaleDialog extends StatefulWidget {
  final VoidCallback onConnected;
  
  const ConnectScaleDialog({required this.onConnected});

  @override
  State<ConnectScaleDialog> createState() => _ConnectScaleDialogState();
}

class _ConnectScaleDialogState extends State<ConnectScaleDialog> with TickerProviderStateMixin {
  int _selectedDevice = -1;
  bool _isConnecting = false;
  late AnimationController _scanController;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
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

                    Text('Connect Scale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Scanning Animation
                  Padding(
                    padding: EdgeInsets.only(top: 48, bottom: 40),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
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
                              // Fixed inner circle
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
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text('⚖️', style: TextStyle(fontSize: 48))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),
                        Text('Searching for Devices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Make sure your BIA scale is powered on and in pairing mode', 
                             style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  
                  // Available Devices
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        ..._dataService.getAvailableDevices().asMap().entries.map((entry) {
                          final device = entry.value;
                          final index = entry.key;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: _buildDeviceItem(index, device),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Connect Button
          Padding(
            padding: EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDevice >= 0 && !_isConnecting ? _connectToDevice : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  _isConnecting ? 'Connecting...' : 
                  _selectedDevice >= 0 ? 'Connect to Device' : 'Select a Device to Connect',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(int index, Device device) {
    bool isSelected = _selectedDevice == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDevice = index),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: device.isStrong ? LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]) : null,
                    color: device.isStrong ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text('⚖️', style: TextStyle(fontSize: 20))),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(device.details, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: device.isStrong ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connectToDevice() {
    setState(() => _isConnecting = true);
    
    Future.delayed(Duration(seconds: 2), () {
      widget.onConnected();
      setState(() => _isConnecting = false);
    });
  }
}

class MeasurementDialog extends StatefulWidget {
  @override
  State<MeasurementDialog> createState() => _MeasurementDialogState();
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

