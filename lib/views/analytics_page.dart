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
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                                  Container(
                                    height: 150,
                                    child: CustomPaint(
                                      painter: ChartPainter(_viewModel.chartData),
                                      size: Size(double.infinity, 150),
                                    ),
                                  ),
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
                                MetricCard(emoji: '💪', value: '42.8%', label: 'Muscle Mass', change: '+1.2%', color: Colors.green),
                                MetricCard(emoji: '💧', value: '58.4%', label: 'Water', change: '+0.8%', color: Colors.blue),
                                MetricCard(emoji: '🦴', value: '3.2kg', label: 'Bone Mass', change: '0.0%', color: Colors.grey),
                                MetricCard(emoji: '⚡', value: '1,847', label: 'BMR (kcal)', change: '+45', color: Colors.orange),
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

