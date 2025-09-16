import 'package:flutter/material.dart';
import 'package:zodicomment/routes.dart';
import 'package:zodicomment/view/components/components.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      AppRoutes.goFromSplash(context);
    }
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için kontrolörü temizle
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          // Animasyonlu arka plan
          SplashBackground(
            backgroundColor: Colors.transparent,
            particleCount: 20,
          ),
          // İçerik
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Maskot görseli
                  AnimatedLogo(
                    assetPath: 'assets/images/maskot.png',
                    size: size.width * 0.18,
                  ),
                  const SizedBox(height: 36),
                  // Uygulama başlığı ve animasyonlu yıldızlar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animasyonlu yıldızlar
                      Positioned(
                        top: -10,
                        right: 30,
                        child: AnimatedStar(
                          size: 28,
                          color: Colors.amber[300]!,
                          duration: const Duration(seconds: 3),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 30,
                        child: AnimatedStar(
                          size: 20,
                          color: Colors.white,
                          duration: const Duration(seconds: 2),
                        ),
                      ),
                      // Uygulama başlığı
                      const Text(
                        'ZodiComment 🔮✨',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Uygulama açıklaması
                  const Text(
                    'Fal, burç ve rüya yorumları maskotunla interaktif ve eğlenceli!',
                    style: TextStyle(color: Colors.white70, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Yükleniyor göstergesi
                  const SplashLoading(message: 'Yükleniyor...'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
