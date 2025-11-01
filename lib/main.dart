import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/analytics_page.dart';
import 'pages/insights_page.dart';
import 'pages/profile_page.dart';
import 'widgets/dialogs.dart';

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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

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
                HomePage(),
                AnalyticsPage(),
                InsightsPage(),
                ProfilePage(),
              ],
            ),
            _buildFloatingActionButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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

  void _showMeasurementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MeasurementDialog(),
    );
  }
}
