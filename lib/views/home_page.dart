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
      _recent = all.toList(growable: false);
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
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CompositionAI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Smart Body Analysis', style: TextStyle(color:Color.fromRGBO(117, 117, 117, 1))), //grey[600]
                              ],
                            ),
                            Container(
                              width: 48, 
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Image(image: AssetImage('assets/img/Logo CompositionAI.png')), 
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Connection Status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(245, 245, 245, 1), //grey[100]
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
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_viewModel.deviceName, style: TextStyle(fontWeight: FontWeight.w500)),
                                      Text(_viewModel.isConnected ? 'Binded' : 'Not Binded', 
                                          style: const TextStyle(color: Color.fromRGBO(117, 117, 117, 1), fontSize: 12)), //grey[600]
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Unbind', style: TextStyle(fontSize: 14)),
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
                            return _buildRecentActivityCardFrom(entry, index: i, totalCount: _recent.length, previous: prev);
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

  Widget _buildRecentActivityCardFrom(MeasurementEntry entry, {required int index, required int totalCount, MeasurementEntry? previous}) {
    final weight = entry.metrics.weight;
    final prevWeight = previous?.metrics.weight;
    final weightDelta = prevWeight != null ? (weight - prevWeight) : null;

    // Color wheel - cycling through gradients
    final colorWheel = [
      [Color(0xFF667EEA), Color(0xFF764BA2)], // Purple gradient
      [Color(0xFFFFECD2), Color(0xFFFCB69F)], // Peach gradient
      [Color(0xFFA8EDEA), Color(0xFFFED6E3)], // Mint-Pink gradient
      [Color(0xFFFF9A9E), Color(0xFFFAD0C4)], // Coral gradient
      [Color(0xFFA1C4FD), Color(0xFFC2E9FB)], // Blue gradient
      [Color(0xFFFFD1DC), Color(0xFFFFB6C1)], // Pink gradient
    ];
    final gradientColors = colorWheel[index % colorWheel.length];

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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon/Indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('📊', style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              index == 0 
                                ? 'Last measurement' 
                                : 'Measurement #${totalCount - index}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _viewModel.formatRelativeDate(entry, isFirst: index == 0),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.monitor_weight, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 6),
                      Text(
                        'Weight: ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        '${weight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (weightDelta != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                weightDelta >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12,
                                color: weightDelta >= 0 ? Colors.red : Colors.green,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${weightDelta.abs().toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  color: weightDelta >= 0 ? Colors.red : Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

}

