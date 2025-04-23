import 'package:flutter/material.dart';
import 'package:b_connect_task/core/constants/app_colors.dart';

class MapPin extends StatefulWidget {
  final bool isMoving;
  
  const MapPin({
    Key? key, 
    required this.isMoving,
  }) : super(key: key);

  @override
  State<MapPin> createState() => _MapPinState();
}

class _MapPinState extends State<MapPin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: -20.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void didUpdateWidget(MapPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving && !oldWidget.isMoving) {
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: SizedBox(
            height: 50,
            width: 50,
            child: CustomPaint(
              painter: PinPainter(),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.main,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.main
      ..strokeWidth = 2.5
      ..style = PaintingStyle.fill;
      
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw shadow
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: 15))
      ..moveTo(center.dx - 8, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + 25, center.dx + 8, center.dy)
      ..close();
      
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Draw the pin
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: 15))
      ..moveTo(center.dx - 8, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + 25, center.dx + 8, center.dy)
      ..close();
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}