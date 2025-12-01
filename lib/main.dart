import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_profile.dart';
import 'models/device.dart';
import 'models/body_metrics.dart';
import 'navigation/route_observer.dart';
import 'views/home_page.dart';
import 'views/analytics_page.dart';
import 'views/insights_page.dart';
import 'widgets/dialogs.dart';
// import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(DeviceAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(BodyMetricsAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(MeasurementEntryAdapter());
  }
  await Hive.openBox<UserProfile>('userProfileBox');
  await Hive.openBox<Device>('boundDeviceBox');
  await Hive.openBox<BodyMetrics>('metricsBox');
  await Hive.openBox<MeasurementEntry>('measurementsBox');
  // Lightweight app settings (e.g. calculation method)
  await Hive.openBox('settingsBox');
  
  // // Update nama user di profile
  // final dataService = DataService();
  // final existingProfile = dataService.getUserProfile();
  // if (existingProfile.name == 'Lionel Winston Sengkey') {
  //   await dataService.updateUserName('Timothy Juwono');
  // }
  
  runApp(BodySyncApp());
}

class BodySyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompostionAI',
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [routeObserver],
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
              ],
            ),
            // _buildFloatingActionButton(), //haruse gabutuh to
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
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        items: [
          BottomNavigationBarItem(icon: Text('📊', style: TextStyle(fontSize: 20)), label: 'Recent'),
          BottomNavigationBarItem(icon: Text('📈', style: TextStyle(fontSize: 20)), label: 'Analytics'),
          BottomNavigationBarItem(icon: Text('🧠', style: TextStyle(fontSize: 20)), label: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 20,
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
