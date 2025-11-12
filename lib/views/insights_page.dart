import 'package:flutter/material.dart';
import '../models/diabetes_result.dart';
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
    _viewModel.loadAiInsights();
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
            
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 32, 0, 24),
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

                      // AI Insights Section
                      _buildAiInsightsSection(),
                      SizedBox(height: 24),

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

  Widget _buildAiInsightsSection() {
    final isLoading = _viewModel.isLoadingAi;
    final result = _viewModel.latestResult;
    final error = _viewModel.aiError;
    final lastUpdated = _viewModel.lastUpdated;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.auto_awesome, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Health Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Generated from your latest body metrics',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!isLoading)
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _viewModel.loadAiInsights,
                  tooltip: 'Refresh AI insights',
                ),
            ],
          ),
          SizedBox(height: 20),
          if (isLoading && result == null)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Crunching numbers...'),
                ],
              ),
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tidak bisa mengambil analisis AI. Coba lagi dalam beberapa saat.',
                          style: TextStyle(color: Colors.red[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _viewModel.loadAiInsights,
                  child: Text('Coba Lagi'),
                ),
              ],
            )
          else if (result != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _riskCategoryColor(result.category).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${result.riskPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _riskCategoryColor(result.category),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${result.categoryName} Risk',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _riskCategoryHeadline(result.category),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _riskCategorySummary(result.category, result.riskScore),
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.shield_moon, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                                'Confidence: ${result.confidencePercentage.toStringAsFixed(0)}%',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('Top Factors yang paling berpengaruh', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.factors
                      .map(
                        (factor) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            factor,
                            style: TextStyle(fontSize: 12, color: Colors.blueGrey[700]),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (lastUpdated != null) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 6),
                      Text(
                        'Terakhir dihitung: ${_formatTimestamp(lastUpdated)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada analisis AI',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Sinkronkan data terbaru dari timbangan untuk melihat analisis risiko kesehatan.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                TextButton(
                  onPressed: _viewModel.loadAiInsights,
                  child: Text('Generate Sekarang'),
                ),
              ],
            ),
          if (isLoading && result != null) ...[
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Update terbaru sedang diproses...'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _riskCategoryColor(RiskCategory category) {
    switch (category) {
      case RiskCategory.low:
        return Colors.green;
      case RiskCategory.moderate:
        return Colors.orange;
      case RiskCategory.high:
        return Colors.red;
    }
  }

  String _riskCategoryHeadline(RiskCategory category) {
    switch (category) {
      case RiskCategory.low:
        return 'Risiko masih aman';
      case RiskCategory.moderate:
        return 'Perlu perhatian ekstra';
      case RiskCategory.high:
        return 'Fokus ke pencegahan';
    }
  }

  String _riskCategorySummary(RiskCategory category, double score) {
    final percentage = (score * 100).toStringAsFixed(1);
    switch (category) {
      case RiskCategory.low:
        return 'Model menghitung risiko sebesar $percentage%. Tetap pertahankan kebiasaan baik dan monitor berkala.';
      case RiskCategory.moderate:
        return 'Risikomu berada di zona moderate ($percentage%). Prioritaskan perbaikan pola makan, aktivitas, dan monitoring lebih rutin.';
      case RiskCategory.high:
        return 'Skor risiko cukup tinggi ($percentage%). Disarankan fokus pada intervensi cepat: cek medis, perbaiki nutrisi, dan rutinkan olahraga.';
    }
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
    }
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
