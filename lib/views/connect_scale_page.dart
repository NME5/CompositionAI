import 'package:flutter/material.dart';

class ConnectScalePage extends StatefulWidget {
  final Function(String deviceName)? onConnected;
  
  const ConnectScalePage({this.onConnected});

  @override
  State<ConnectScalePage> createState() => _ConnectScalePageState();
}

class _ConnectScalePageState extends State<ConnectScalePage> with TickerProviderStateMixin {
  late AnimationController _scanController;

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

                      Text('Searching for Device', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              gradient: LinearGradient(colors: [Color.fromARGB(255, 132, 162, 254), Color.fromARGB(255, 158, 91, 187)]),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Image.asset('assets/img/Composition Scale.png', width: 80, height: 80)),
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
                        Text('Step on the Scale', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Make sure your BIA scale is powered on and in pairing mode', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  // void _connectToDevice() {
  //   setState(() => _isConnecting = true);
    
  //   Future.delayed(Duration(seconds: 2), () {
  //     if (_selectedDevice >= 0) {
  //       final devices = _dataService.getAvailableDevices();
  //       final deviceName = devices[_selectedDevice].name;
        
  //       if (widget.onConnected != null) {
  //         widget.onConnected!(deviceName);
  //       }
        
  //       Navigator.pop(context);
  //     }
  //     setState(() => _isConnecting = false);
  //   });
  // }
}

