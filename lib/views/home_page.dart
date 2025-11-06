import 'package:flutter/material.dart';
import '../viewmodels/home_view_model.dart';
import '../services/data_service.dart';
import '../models/body_metrics.dart';
import '../widgets/dialogs.dart';
import '../widgets/shared_widgets.dart';
import '../navigation/route_observer.dart';
import '../services/body_composition_calculator.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, RouteAware {
  late HomeViewModel _viewModel;
  late AnimationController _pulseController;
  final DataService _dataService = DataService();
  List<MeasurementEntry> _recent = const [];
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.initializeBinding();
    _loadRecentMeasurements();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _pulseController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadRecentMeasurements();
  }

  void _loadRecentMeasurements() {
    final all = _dataService.getAllMeasurements();
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _recent = all.take(3).toList(growable: false);
    });
  }

  Future<void> _refresh() async {
    await _viewModel.initializeBinding();
    _loadRecentMeasurements();
    await Future.delayed(Duration(milliseconds: 150));
  }

  // Removed duplicate dispose (consolidated above with routeObserver unsubscribe)

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return SafeArea(
          child: RefreshIndicator(
            key: _refreshKey,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                                padding: EdgeInsets.all(8.0),
                                child: Image(image: AssetImage('assets/img/Logo CompositionAI.png')), 
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
                                      Text(_viewModel.deviceName, style: TextStyle(fontWeight: FontWeight.w500)),
                                      Text(_viewModel.isConnected ? 'Binded' : 'Not Binded', 
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              if (_viewModel.showUnbindButton && _viewModel.isConnected)
                                ElevatedButton(
                                  onPressed: () {
                                    _viewModel.unbindScale();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9E7AE8),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('Unbind', style: TextStyle(fontSize: 14)),
                                ),
                            ],
                          ),
                        ),
                        // Start Weighing Button
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          height: 55,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showConnectDialog(),
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
                  // Body content
                  Padding(
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
                        if (_recent.isEmpty)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0)],
                            ),
                            child: Row(
                              children: [
                                Text('📭', style: TextStyle(fontSize: 24)),
                                SizedBox(width: 12),
                                Text('No measurements yet', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        else
                          ...List.generate(_recent.length, (i) {
                            final entry = _recent[i];
                            final prev = i + 1 < _recent.length ? _recent[i + 1] : null;
                            return _buildRecentActivityCardFrom(entry, previous: prev);
                          }),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConnectDialog() {
    ConnectScaleDialog.show(
      context,
      onConnected: (deviceName) {
        _viewModel.bindScale(deviceName: deviceName);
      },
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

  Widget _buildRecentActivityCardFrom(MeasurementEntry entry, {MeasurementEntry? previous}) {
    final dt = entry.timestamp;
    final weight = entry.metrics.weight;
    final bodyFat = entry.metrics.bodyFat;
    final prevFat = previous?.metrics.bodyFat;
    final fatDelta = prevFat != null ? (bodyFat - prevFat) : null;


    //ui recent activity card
    return InkWell(
      onTap: () {
        final profile = _dataService.getUserProfile();
        final m = entry.metrics;
        final weightKg = m.weight;
        final slmKg = m.muscleMass;
        final bfrPercent = m.bodyFat;
        final tfrPercent = m.water;
        final boneMassKg = m.boneMass;
        final bmr = m.bmr.toDouble();
        final slmPercent = weightKg > 0 ? (slmKg / weightKg) * 100.0 : 0.0;
        final fatMassKg = (bfrPercent / 100.0) * weightKg;
        final bmi = BodyCompositionCalculator.calculateBMI(profile.height.round(), weightKg);
        final isMale = profile.gender.toLowerCase().startsWith('m');
        final vfr = BodyCompositionCalculator.calculateVFR(
          heightCm: profile.height.round(),
          weightKg: weightKg,
          age: profile.age,
          isMale: isMale,
          impedanceOhm: 0.0,
        );
        final bodyAge = BodyCompositionCalculator.calculateBodyAge(
          heightCm: profile.height.round(),
          weightKg: weightKg,
          age: profile.age,
          isMale: isMale,
          impedanceOhm: 0.0,
        );

        final result = BodyCompositionResult(
          weightKg: weightKg,
          impedanceOhm: 0.0,
          bfrPercent: bfrPercent,
          fatMassKg: fatMassKg,
          vfr: vfr,
          tfrPercent: tfrPercent,
          slmKg: slmKg,
          slmPercent: slmPercent,
          boneMassKg: boneMassKg,
          bmr: bmr,
          bodyAge: bodyAge,
          bmi: bmi,
        );
        BodyAnalysisDialog.show(context, compositionResult: result);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
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
                        Text('Measurement', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(_formatDateTime(dt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${bodyFat.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (fatDelta != null)
                      Text(
                        '${fatDelta >= 0 ? '↑' : '↓'} ${fatDelta.abs().toStringAsFixed(1)}%',
                        style: TextStyle(color: fatDelta >= 0 ? Colors.red : Colors.green, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Weight: ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('${weight.toStringAsFixed(1)} kg', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final time = TimeOfDay.fromDateTime(dt);
    final hh = time.hourOfPeriod.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ampm = time.period == DayPeriod.am ? 'AM' : 'PM';
    if (isToday) return 'Today, $hh:$mm $ampm';
    final yesterday = now.subtract(Duration(days: 1));
    final isYesterday = dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
    if (isYesterday) return 'Yesterday, $hh:$mm $ampm';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}, $hh:$mm $ampm';
  }
}

