import 'package:flutter/material.dart';
import '../viewmodels/insights_view_model.dart';
import '../services/data_service.dart';

class InsightsPage extends StatefulWidget {
  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late InsightsViewModel _viewModel;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _viewModel = InsightsViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = _dataService.getHealthScore();
    final recommendations = _dataService.getRecommendations();

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
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
                            ...recommendations.map((rec) => Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: _buildRecommendationCard(rec),
                            )).toList(),
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
                            _buildHealthScore(healthScore.overall),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildScoreDetail('${healthScore.bodyComp}', 'Body Comp', Colors.green),
                                _buildScoreDetail('${healthScore.fitness}', 'Fitness', Colors.blue),
                                _buildScoreDetail('${healthScore.wellness}', 'Wellness', Colors.purple),
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
      },
    );
  }

  Widget _buildRecommendationCard(rec) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(rec.priorityColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Color(rec.priorityColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(rec.emoji, style: TextStyle(fontSize: 16))),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.title, style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(rec.description, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(rec.priorityColor).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(rec.priority, style: TextStyle(color: Color(rec.priorityColor), fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore(int score) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        Column(
          children: [
            Text('$score', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
}

