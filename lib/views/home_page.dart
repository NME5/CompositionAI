import 'package:flutter/material.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/dialogs.dart';
import '../widgets/shared_widgets.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late HomeViewModel _viewModel;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CompositionAI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Smart Body Analysis', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Image(image: AssetImage('assets/img/Logo CompositionAI.png'),),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Connection Status
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1 + (_pulseController.value * 0.5),
                                        child: Container(
                                          width: 16, height: 16,
                                          decoration: BoxDecoration(
                                            color: (_viewModel.isConnected ? Colors.green : Colors.red).withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(
                                      color: _viewModel.isConnected ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Scale Status', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(_viewModel.isConnected ? 'Connected' : 'Not Connected', 
                                       style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _showConnectDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _viewModel.isConnected ? Colors.green : Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(_viewModel.isConnected ? 'Connected' : 'Connect', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),

                    // Start Weighing Button
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      height: 55, //aman ga
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Start Weighing', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),

                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today\'s Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      
                      // Quick Stats
                      Row(
                        children: [
                          Expanded(child: StatCard(emoji: '💪', value: '42.8%', label: 'Muscle Mass')),
                          SizedBox(width: 16),
                          Expanded(child: StatCard(emoji: '🔥', value: '18.2%', label: 'Body Fat')),
                        ],
                      ),
                      SizedBox(height: 32),
                      
                      Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      
                      // Recent Activity Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('📊', style: TextStyle(fontSize: 24)),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Last Measurement', style: TextStyle(fontWeight: FontWeight.w600)),
                                        Text('Yesterday, 8:30 AM', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('18.5%', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('↓ 0.3%', style: TextStyle(color: Colors.green, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Text('Next measurement recommended in ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('2 hours', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConnectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectScaleDialog(
        onConnected: () {
          _viewModel.toggleConnection();
          Navigator.pop(context);
        },
      ),
    );
  }

  void showMeasurementDialog() {
    if (!_viewModel.isConnected) {
      _showConnectDialog();
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MeasurementDialog(),
    );
  }
}

