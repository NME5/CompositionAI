import 'package:flutter/material.dart';
import '../viewmodels/analytics_view_model.dart';
import '../widgets/shared_widgets.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late AnalyticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnalyticsViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
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
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('Analytics', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('Detailed body composition insights', style: TextStyle(color: Colors.grey[600])),
                                ),
                              ],
                            ),
                            
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Color.fromARGB(255, 145, 165, 255), Color.fromARGB(255, 108, 51, 164)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: Text('📈', style: TextStyle(fontSize: 18))),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
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
                                children: ['7D', '1M', '3M', '1Y'].map((period) {
                                  bool isSelected = _viewModel.selectedPeriod == period;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => _viewModel.selectPeriod(period),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : null,
                                        ),
                                        child: Text(
                                          period,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected ? Colors.blue : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Text('Body Fat Percentage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 10),
                                        Text(_viewModel.bodyFatPercentText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(_viewModel.bodyFatDeltaText.isEmpty ? '—' : _viewModel.bodyFatDeltaText, style: TextStyle(color: Colors.green, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    height: 150,
                                    child: CustomPaint(
                                      painter: ChartPainter(_viewModel.chartData),
                                      size: Size(double.infinity, 150),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: _viewModel.xAxisLabels
                                        .map(
                                          (label) => Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  label,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: _viewModel.xAxisLabels.length > 7 ? 10 : 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
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
                                MetricCard(
                                  emoji: '🔥', 
                                  value: _viewModel.bodyFatText, 
                                  label: 'Body Fat', 
                                  change: _viewModel.bodyFatDeltaCardText, 
                                  color: Colors.pink,
                                  progressValue: _viewModel.bodyFatProgress,
                                ),
                                MetricCard(
                                  emoji: '💪', 
                                  value: _viewModel.muscleMassText, 
                                  label: 'Muscle Mass', 
                                  change: _viewModel.muscleDeltaText, 
                                  color: Colors.green,
                                  progressValue: _viewModel.muscleMassProgress,
                                ),
                                MetricCard(
                                  emoji: '💧', 
                                  value: _viewModel.waterText, 
                                  label: 'Water', 
                                  change: _viewModel.waterDeltaText, 
                                  color: Colors.blue,
                                  progressValue: _viewModel.waterProgress,
                                ),
                                MetricCard(
                                  emoji: '🦴', 
                                  value: _viewModel.boneMassText, 
                                  label: 'Bone Mass', 
                                  change: _viewModel.boneDeltaText, 
                                  color: Colors.grey,
                                  progressValue: _viewModel.boneMassProgress,
                                ),
                                MetricCard(
                                  emoji: '⚡', 
                                  value: _viewModel.bmrText, 
                                  label: 'BMR (kcal)', 
                                  change: _viewModel.bmrDeltaText, 
                                  color: Colors.orange,
                                  progressValue: _viewModel.bmrProgress,
                                ),
                                MetricCard(
                                  emoji: '📏', 
                                  value: _viewModel.bmiText, 
                                  label: 'BMI', 
                                  change: _viewModel.bmiDeltaText, 
                                  color: Colors.purple,
                                  progressValue: _viewModel.bmiProgress,
                                ),
                              ],
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
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
}

