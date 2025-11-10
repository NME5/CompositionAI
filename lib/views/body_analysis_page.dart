import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/body_composition_calculator.dart';

class BodyAnalysisPage extends StatefulWidget {
  final BodyCompositionResult? compositionResult;
  
  const BodyAnalysisPage({this.compositionResult});

  @override
  State<BodyAnalysisPage> createState() => _BodyAnalysisPageState();
}

class _BodyAnalysisPageState extends State<BodyAnalysisPage> {
  late BodyCompositionResult _result;
  
  @override
  void initState() {
    super.initState();
    // Fallback sample if no result provided (for safety) MUST BE REMOVED LATER
    _result = widget.compositionResult ?? BodyCompositionResult(
      weightKg: 70.0,
      impedanceOhm: 500,
      bfrPercent: 20.0,
      fatMassKg: 14.0,
      vfr: 8.0,
      tfrPercent: 55.0,
      slmKg: 28.0,
      slmPercent: 40.0,
      boneMassKg: 3.0,
      bmr: 1650.0,
      bodyAge: 28,
      bmi: 22.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: BodyAnalysisContent(result: _result),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class BodyAnalysisContent extends StatelessWidget {
  final BodyCompositionResult result;
  final DateTime? measurementDate;

  const BodyAnalysisContent({required this.result, this.measurementDate});

  //date for display
  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$month $day, $year at $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        Text(
          'Your Body Composition',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Text(
          measurementDate != null ? _formatDate(measurementDate!) : 'Overview of your latest measurement',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        SizedBox(height: 20),

        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    result.weightKg.toStringAsFixed(1),
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${result.weightKg.toStringAsFixed(1)} kg', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(text: 'BMI ${result.bmi.toStringAsFixed(1)}'),
                        SizedBox(width: 8),
                        _Chip(text: 'BMR ${result.bmr.toStringAsFixed(0)} kcal'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Composition breakdown', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: SegmentedRadialPainter(
                          bodyFatPercent: result.bfrPercent,
                          musclePercent: result.slmPercent,
                          waterPercent: result.tfrPercent,
                          bonePercent: ((result.boneMassKg / result.weightKg) * 100.0),
                          colors: const {
                            'fat': Color(0xFFFFC857),
                            'muscle': Color(0xFF2A9D8F),
                            'water': Color(0xFF78C0E0),
                            'bone': Color(0xFF9E7AE8),
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _LegendDot(color: Color(0xFFFFC857), label: 'Fat ${result.bfrPercent.toStringAsFixed(1)}%'),
                      _LegendDot(color: Color(0xFF2A9D8F), label: 'Muscle ${result.slmPercent.toStringAsFixed(1)}%'),
                      _LegendDot(color: Color(0xFF78C0E0), label: 'Water ${result.tfrPercent.toStringAsFixed(1)}%'),
                      _LegendDot(color: Color(0xFF9E7AE8), label: 'Bone ${((result.boneMassKg / result.weightKg) * 100.0).toStringAsFixed(1)}%'),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(emoji: '🧈', title: 'Body Fat', value: '${result.bfrPercent.toStringAsFixed(1)}%', subtitle: '${result.fatMassKg.toStringAsFixed(1)} kg', color: Color(0xFFFFC857)),
              _MetricCard(emoji: '💧', title: 'Water', value: '${result.tfrPercent.toStringAsFixed(1)}%', subtitle: 'Hydration', color: Color(0xFF78C0E0)),
              _MetricCard(emoji: '⚠️', title: 'Visceral Fat', value: result.vfr.toStringAsFixed(0), subtitle: 'Rating', color: Color(0xFFE76F51)),
              _MetricCard(emoji: '💪', title: 'Muscle Mass', value: '${result.slmKg.toStringAsFixed(1)} kg', subtitle: '${result.slmPercent.toStringAsFixed(1)}%', color: Color(0xFF2A9D8F)),
              _MetricCard(emoji: '🦴', title: 'Bone Mass', value: '${result.boneMassKg.toStringAsFixed(1)} kg', subtitle: 'Skeletal', color: Color(0xFF9E7AE8)),
              _MetricCard(emoji: '🎂', title: 'Body Age', value: '${result.bodyAge}', subtitle: 'years', color: Color(0xFF8D99AE)),
            ],
          ),
        ),
      ],
    );
  }
}

// Simple themed metric card & chip widgets matching app style
class _MetricCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _MetricCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 24 - 24 - 16 - 16 - 12) / 2,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
      children: [
              Text(emoji, style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700))),
            ],
          ),
          SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
      ],
    );
  }
}

class SegmentedRadialPainter extends CustomPainter {
  final double bodyFatPercent;
  final double musclePercent;
  final double waterPercent;
  final double bonePercent;
  final Map<String, Color> colors;

  SegmentedRadialPainter({
    required this.bodyFatPercent,
    required this.musclePercent,
    required this.waterPercent,
    required this.bonePercent,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 14.0;
    
    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Values and normalization (avoid >100% total by renormalizing)
    final raw = [
      bodyFatPercent.clamp(0.0, 100.0),
      musclePercent.clamp(0.0, 100.0),
      waterPercent.clamp(0.0, 100.0),
      bonePercent.clamp(0.0, 100.0),
    ];
    double sum = raw.fold(0.0, (a, b) => a + b);
    if (sum <= 0) return;
    final vals = raw.map((v) => v / sum).toList();

    final paints = [
      Paint()
        ..color = colors['fat']!
      ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
      Paint()
        ..color = colors['muscle']!
      ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
      Paint()
        ..color = colors['water']!
      ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
      Paint()
        ..color = colors['bone']!
      ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    ];

    double startAngle = -90 * (3.1415926535 / 180.0);
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    
    final labelNames = ['Fat', 'Muscle', 'Water', 'Bone'];
    final labelPercents = [
      bodyFatPercent,
      musclePercent,
      waterPercent,
      bonePercent,
    ];
    final textStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < vals.length; i++) {
      final sweep = vals[i] * 2 * 3.1415926535;
      if (sweep <= 0) continue;
      canvas.drawArc(rect, startAngle, sweep, false, paints[i]);
      
      // Draw label at midpoint of segment
      if (sweep > 0.1) { // Only draw label if segment is large enough
        final midAngle = startAngle + sweep / 2;
        final labelRadius = radius - strokeWidth / 2 + 25; // Position label outside the ring
        final labelX = center.dx + labelRadius * math.cos(midAngle);
        final labelY = center.dy + labelRadius * math.sin(midAngle);
        
        final labelText = '${labelNames[i]}\n${labelPercents[i].toStringAsFixed(1)}%';
        final textSpan = TextSpan(text: labelText, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
        );
      }
      
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedRadialPainter oldDelegate) {
    return bodyFatPercent != oldDelegate.bodyFatPercent ||
        musclePercent != oldDelegate.musclePercent ||
        waterPercent != oldDelegate.waterPercent ||
        bonePercent != oldDelegate.bonePercent ||
        colors != oldDelegate.colors;
  }
}

