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

class MetricCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final String change;
  final Color color;

  const MetricCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.change,
    required this.color,
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
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final points = data.map((d) {
      final x = (d['x'] as int) * (size.width / (data.length - 1));
      final y = size.height * (1 - (d['y'] as double));
      return Offset(x, y);
    }).toList();

    paint.shader = LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    final pointPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      pointPaint.color = i == points.length - 1 ? Color(0xFF764BA2) : Color(0xFF667EEA);
      canvas.drawCircle(points[i], i == points.length - 1 ? 6 : 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

