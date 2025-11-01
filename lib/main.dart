import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(BodySyncApp());
}

class BodySyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompostionAI',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isConnected = false;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Container(
        constraints: BoxConstraints(maxWidth: 428),
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomePage(),
                _buildAnalyticsPage(),
                _buildInsightsPage(),
                _buildProfilePage(),
              ],
            ),
            _buildFloatingActionButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Column(
        children: [
          // Status Bar Simulation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('9:41', style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Container(width: 16, height: 8, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    SizedBox(width: 4),
                    Container(
                      width: 24, height: 12,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(2)),
                      child: Container(margin: EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(1))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
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
                      child: Icon(Icons.flash_on, color: Colors.white, size: 24),
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
                                        color: (_isConnected ? Colors.green : Colors.red).withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: _isConnected ? Colors.green : Colors.red,
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
                              Text(_isConnected ? 'Connected' : 'Not Connected', 
                                   style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showConnectDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isConnected ? Colors.green : Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_isConnected ? 'Connected' : 'Connect', style: TextStyle(fontSize: 14)),
                      ),
                    ],
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
                      Expanded(child: _buildStatCard('💪', '42.8%', 'Muscle Mass')),
                      SizedBox(width: 16),
                      Expanded(child: _buildStatCard('🔥', '18.2%', 'Body Fat')),
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
  }

  Widget _buildAnalyticsPage() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analytics', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Detailed body composition insights', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Time Period Selector
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: ['7D', '1M', '3M', '1Y'].asMap().entries.map((entry) {
                        bool isSelected = entry.key == 0;
                        return Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : null,
                            ),
                            child: Text(
                              entry.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Main Chart
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Body Fat Percentage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text('18.2%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('↓ 2.1%', style: TextStyle(color: Colors.green, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildChart(),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .map((day) => Text(day, style: TextStyle(color: Colors.grey[500], fontSize: 12)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Metrics Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildMetricCard('💪', '42.8%', 'Muscle Mass', '+1.2%', Colors.green),
                      _buildMetricCard('💧', '58.4%', 'Water', '+0.8%', Colors.blue),
                      _buildMetricCard('🦴', '3.2kg', 'Bone Mass', '0.0%', Colors.grey),
                      _buildMetricCard('⚡', '1,847', 'BMR (kcal)', '+45', Colors.orange),
                    ],
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsPage() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Insights', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Personalized recommendations', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text('🧠', style: TextStyle(fontSize: 20))),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // AI Summary
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.smart_toy, color: Colors.white),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weekly Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Based on your measurements', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.green[50]!, Colors.blue[50]!]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🎯 Excellent Progress!', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text(
                                'Your body composition is improving significantly. Body fat decreased by 2.1% while muscle mass increased by 1.2%. This indicates effective training and nutrition.',
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Recommendations
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personalized Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        _buildRecommendationCard('🏃‍♂️', 'Cardio Optimization', 'Add 2 HIIT sessions per week to accelerate fat loss', 'High Priority', Colors.blue),
                        SizedBox(height: 16),
                        _buildRecommendationCard('🥗', 'Protein Intake', 'Increase to 1.8g per kg body weight for muscle growth', 'Medium Priority', Colors.green),
                        SizedBox(height: 16),
                        _buildRecommendationCard('😴', 'Recovery Time', 'Maintain 7-8 hours sleep for optimal recovery', 'Maintain', Colors.purple),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Health Score
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Text('Health Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 24),
                        _buildHealthScore(),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildScoreDetail('92', 'Body Comp', Colors.green),
                            _buildScoreDetail('78', 'Fitness', Colors.blue),
                            _buildScoreDetail('85', 'Wellness', Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Personal settings & preferences', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFFECD2), Color(0xFFFCB69F)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.person, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // User Info
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(Icons.person, color: Colors.white, size: 40),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Alex Johnson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text('Premium Member', style: TextStyle(color: Colors.grey[600])),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('⭐ Gold', style: TextStyle(color: Colors.amber[700], fontSize: 10)),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Member since 2023', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProfileStat('127', 'Measurements'),
                            _buildProfileStat('89', 'Days Active'),
                            _buildProfileStat('15', 'Goals Achieved'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Personal Info
                  _buildInfoSection('Personal Information', [
                    _buildInfoRow('Age', '28 years'),
                    _buildInfoRow('Height', '175 cm'),
                    _buildInfoRow('Weight', '72.5 kg'),
                    _buildInfoRow('Activity Level', 'Moderately Active'),
                  ]),
                  SizedBox(height: 24),
                  
                  // Settings
                  _buildInfoSection('Settings', [
                    _buildSettingRow('Units', 'Metric (kg, cm)', 'Change'),
                    _buildToggleRow('Notifications', 'Daily reminders enabled', true),
                    _buildToggleRow('Data Sync', 'Auto-sync with cloud', true),
                  ]),
                  SizedBox(height: 24),
                  
                  // Support
                  _buildInfoSection('Support & Info', [
                    _buildActionRow('Help Center'),
                    _buildActionRow('Privacy Policy'),
                    _buildActionRow('Terms of Service'),
                    _buildActionRow('Sign Out', color: Colors.red),
                  ]),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String value, String label, String change, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(change, style: TextStyle(color: color, fontSize: 10)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 150,
      child: CustomPaint(
        painter: ChartPainter(),
        size: Size(double.infinity, 150),
      ),
    );
  }

  Widget _buildRecommendationCard(String emoji, String title, String description, String priority, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 16))),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(priority, style: TextStyle(color: color, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: 0.85,
            strokeWidth: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        Column(
          children: [
            Text('85', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('Excellent', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreDetail(String score, String label, Color color) {
    return Column(
      children: [
        Text(score, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle, String action) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(action, style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Switch(
            value: value,
            onChanged: (newValue) {},
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, {Color? color}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        items: [
          BottomNavigationBarItem(icon: Text('📊', style: TextStyle(fontSize: 20)), label: 'Home'),
          BottomNavigationBarItem(icon: Text('📈', style: TextStyle(fontSize: 20)), label: 'Analytics'),
          BottomNavigationBarItem(icon: Text('🧠', style: TextStyle(fontSize: 20)), label: 'Insights'),
          BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        onPressed: () => _showMeasurementDialog(),
        backgroundColor: Color(0xFF667EEA),
        child: Text('📊', style: TextStyle(fontSize: 20)),
        elevation: 8,
      ),
    );
  }

  void _showConnectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectScaleDialog(
        onConnected: () {
          setState(() => _isConnected = true);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMeasurementDialog() {
    if (!_isConnected) {
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

class ConnectScaleDialog extends StatefulWidget {
  final VoidCallback onConnected;
  
  ConnectScaleDialog({required this.onConnected});

  @override
  _ConnectScaleDialogState createState() => _ConnectScaleDialogState();
}

class _ConnectScaleDialogState extends State<ConnectScaleDialog> with TickerProviderStateMixin {
  int _selectedDevice = -1;
  bool _isConnecting = false;
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
                  icon: Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                Text('Connect Scale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(width: 48),
              ],
            ),
          ),
          
          // Scanning Animation
          Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_scanController.value * 0.3),
                          child: Container(
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
                        );
                      },
                    ),
                  ],
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  _buildDeviceItem(0, 'BodySync Pro X1', 'Signal: Strong • 2.4m away', true),
                  SizedBox(height: 12),
                  _buildDeviceItem(1, 'SmartScale Elite', 'Signal: Medium • 5.1m away', false),
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

  Widget _buildDeviceItem(int index, String name, String details, bool isStrong) {
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
                    gradient: isStrong ? LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]) : null,
                    color: isStrong ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text('⚖️', style: TextStyle(fontSize: 20))),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(details, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: isStrong ? Colors.green : Colors.orange,
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
  _MeasurementDialogState createState() => _MeasurementDialogState();
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

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Sample data points
    final points = [
      Offset(20, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.35, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width - 20, size.height * 0.35),
    ];

    // Draw line
    paint.shader = LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      pointPaint.color = i == points.length - 1 ? Color(0xFF764BA2) : Color(0xFF667EEA);
      canvas.drawCircle(points[i], i == points.length - 1 ? 6 : 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}