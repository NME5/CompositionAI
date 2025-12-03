import 'package:flutter/material.dart';
import '../models/diabetes_result.dart';
import '../viewmodels/insights_view_model.dart';
import '../services/data_service.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/dialogs.dart';

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
                            GestureDetector(
                              onTap: () => ProfileDialog.show(context),
                              child: const UserProfileAvatar(size: 48),
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
                          'Unable to fetch AI analysis. Please try again shortly.',
                          style: TextStyle(color: Colors.red[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _viewModel.loadAiInsights,
                  child: Text('Try Again'),
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
                Text('Top factors driving your risk', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        'Last calculated: ${_formatTimestamp(lastUpdated)}',
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
                  'No AI analysis yet',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Sync your latest scale data to unlock a personalized health risk analysis.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                TextButton(
                  onPressed: _viewModel.loadAiInsights,
                  child: Text('Generate Now'),
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
                Text('Refreshing with the latest data...'),
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
        return 'Risk is under control';
      case RiskCategory.moderate:
        return 'Time to pay closer attention';
      case RiskCategory.high:
        return 'Prioritize prevention steps';
    }
  }

  String _riskCategorySummary(RiskCategory category, double score) {
    final percentage = (score * 100).toStringAsFixed(1);
    switch (category) {
      case RiskCategory.low:
        return 'The model estimates a $percentage% risk. Keep your current habits and continue monitoring.';
      case RiskCategory.moderate:
        return 'Your risk sits in the moderate range ($percentage%). Focus on improving nutrition, activity, and regular tracking.';
      case RiskCategory.high:
        return 'Risk is elevated at $percentage%. Consider medical follow-up, targeted nutrition changes, and consistent training.';
    }
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    }
  }
}
