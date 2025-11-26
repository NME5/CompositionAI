import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserProfileAvatar extends StatelessWidget {
  final double size;

  const UserProfileAvatar({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade300,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/img/credits/timothy_juwono.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final String change;
  final Color color;
  final double? progressValue;

  const MetricCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.change,
    required this.color,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(change, style: TextStyle(color: color, fontSize: 10)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          if (progressValue != null) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, num>> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) {
      return; // not enough data to render a meaningful bar chart
    }

    // Layout paddings so bars align nicely with surrounding text
    const double leftPadding = 16.0;
    const double rightPadding = 16.0;
    const double topPadding = 5.0; // leave 5px padding at the very top

    final contentWidth = size.width - leftPadding - rightPadding;

    // Compute bar width, spacing, and dynamic vertical scale
    final barCount = data.length;
    final barWidth = contentWidth / (barCount * 1.5); // a bit of spacing between bars
    final maxBarHeight = size.height - topPadding;

    // Find max Y so tallest bar reaches the top (dynamic scaling)
    final maxY = data
        .map((d) => (d['y']?.toDouble() ?? 0.0))
        .fold<double>(0.0, (prev, v) => v > prev ? v : prev);
    if (maxY <= 0) {
      return;
    }

    final gradient = LinearGradient(
      colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // Pre-compute bar center positions
    final List<double> centers = [];
    for (int i = 0; i < barCount; i++) {
      final d = data[i];
      final xValue = d['x']?.toDouble() ?? i.toDouble();
      final normalizedX = barCount == 1 ? 0.5 : (xValue / (barCount - 1));
      final centerX = leftPadding + normalizedX * contentWidth;
      centers.add(centerX);
    }

    // Draw subtle vertical separators in the middle of gaps between bars
    if (barCount > 1) {
      final separatorPaint = Paint()
        ..color = Colors.grey.withOpacity(0.18)
        ..strokeWidth = 1;

      for (int i = 0; i < barCount - 1; i++) {
        final gapX = (centers[i] + centers[i + 1]) / 2;
        canvas.drawLine(Offset(gapX, 0), Offset(gapX, size.height), separatorPaint);
      }
    }

    for (int i = 0; i < barCount; i++) {
      final d = data[i];
      final rawY = d['y']?.toDouble() ?? 0.0;
      final yValue = (rawY / maxY).clamp(0.0, 1.0); // normalize against maxY

      final centerX = centers[i];

      final barHeight = maxBarHeight * yValue;
      final rect = Rect.fromLTWH(
        centerX - barWidth / 2,
        topPadding + (maxBarHeight - barHeight),
        barWidth,
        barHeight,
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(rect);

      // Draw bar with uniformly rounded corners using RRect
      final rrect = RRect.fromRectXY(
        rect,
        3,
        3,
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    if (identical(oldDelegate.data, data)) {
      return false;
    }
    if (oldDelegate.data.length != data.length) {
      return true;
    }
    for (var i = 0; i < data.length; i++) {
      final current = data[i];
      final previous = oldDelegate.data[i];
      if (current['x'] != previous['x'] || current['y'] != previous['y']) {
        return true;
      }
    }
    return false;
  }
}

