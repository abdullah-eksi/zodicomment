import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Splash sayfası için arka plan animasyonu.
///
/// Ekranın arka planında, rastgele konumlarda ve boyutlarda oluşturulan
/// yıldız ve ay şekilleri içerir. Bu şekiller, farklı hızlarda yana doğru
/// hareket ederek ve dönerek akıcı bir arka plan animasyonu oluşturur.
class SplashBackground extends StatefulWidget {
  final Color backgroundColor;
  final int particleCount;

  const SplashBackground({
    Key? key,
    required this.backgroundColor,
    this.particleCount = 30,
  }) : super(key: key);

  @override
  State<SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<SplashBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<BackgroundParticle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _particles = List.generate(widget.particleCount, (_) => _createParticle());

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BackgroundParticle _createParticle() {
    final isAstar = _random.nextBool();
    final size = _random.nextDouble() * 10 + 5;
    final speed = _random.nextDouble() * 5 + 1;
    final rotationSpeed = _random.nextDouble() * 2 + 0.5;
    final initialX = _random.nextDouble() * 2 - 1; // -1 to 1
    final initialY = _random.nextDouble(); // 0 to 1
    final opacity = _random.nextDouble() * 0.7 + 0.3; // 0.3 to 1.0

    // Mavi ve mor tonları arasında rastgele renk
    final hue = _random.nextDouble() * 60 + 220; // 220-280 arası (mavi-mor)
    final saturation = _random.nextDouble() * 0.5 + 0.5; // 0.5-1.0 arası
    final lightness = _random.nextDouble() * 0.6 + 0.4; // 0.4-1.0 arası

    final color = HSLColor.fromAHSL(
      opacity,
      hue,
      saturation,
      lightness,
    ).toColor();

    return BackgroundParticle(
      isAstar: isAstar,
      size: size,
      speed: speed,
      rotationSpeed: rotationSpeed,
      initialX: initialX,
      initialY: initialY,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            controller: _controller,
            particles: _particles,
            backgroundColor: widget.backgroundColor,
          ),
          child: child,
        );
      },
      child: Container(),
    );
  }
}

/// Arka plan parçacığı (yıldız veya ay)
class BackgroundParticle {
  final bool isAstar;
  final double size;
  final double speed;
  final double rotationSpeed;
  final double initialX;
  final double initialY;
  final Color color;

  BackgroundParticle({
    required this.isAstar,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
    required this.initialX,
    required this.initialY,
    required this.color,
  });
}

/// Arka plan için özel çizim
class BackgroundPainter extends CustomPainter {
  final AnimationController controller;
  final List<BackgroundParticle> particles;
  final Color backgroundColor;

  BackgroundPainter({
    required this.controller,
    required this.particles,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sadece arka plan şeffaf değilse arka planı doldur
    if (backgroundColor != Colors.transparent) {
      final paint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(Offset.zero & size, paint);
    } // Her bir parçacığı çiz
    for (final particle in particles) {
      // Parçacık konumunu hesapla
      final progress = controller.value;
      final x = (particle.initialX + progress * particle.speed) % 2 - 1;
      final actualX = (x + 1) / 2 * size.width;
      final actualY = particle.initialY * size.height;

      // Dönüş açısını hesapla
      final rotation = progress * particle.rotationSpeed * 2 * math.pi;

      // Çizim için Paint nesnesi oluştur
      final particlePaint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(actualX, actualY);
      canvas.rotate(rotation);

      if (particle.isAstar) {
        // Yıldız çiz
        _drawStar(canvas, particle.size, particlePaint);
      } else {
        // Ay çiz
        _drawMoon(canvas, particle.size, particlePaint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    const spikes = 5;

    for (int i = 0; i < spikes * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = i * math.pi / spikes;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMoon(Canvas canvas, double size, Paint paint) {
    final fullCircle = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: size));

    final clipCircle = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(size * 0.5, 0), radius: size * 0.9),
      );

    final moonPath = Path.combine(
      PathOperation.difference,
      fullCircle,
      clipCircle,
    );

    canvas.drawPath(moonPath, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.controller.value != controller.value;
  }
}
