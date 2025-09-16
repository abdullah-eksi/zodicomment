import 'package:flutter/material.dart';
import 'package:zodicomment/view/pages/homepage.dart';
import 'package:zodicomment/view/pages/login_page.dart' hide SizedBox;
import 'package:zodicomment/view/pages/register_page.dart';
import 'package:zodicomment/view/pages/profilepage.dart';
import 'package:zodicomment/view/pages/splash_page.dart';
import 'package:zodicomment/model/userModel.dart';

class AppRoutes {
  static Future<void> goFromSplash(BuildContext context) async {
    final isLoggedIn = await UserModel.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, home);
    } else {
      Navigator.pushReplacementNamed(context, login);
    }
  }

  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String splash = '/splash';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => _HomeAuthGuard(),
    profile: (context) => _ProfileAuthGuard(),
  };
}

class _HomeAuthGuard extends StatelessWidget {
  const _HomeAuthGuard({Key? key}) : super(key: key);

  Future<bool> _checkLogin() async {
    return await UserModel.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          return const HomePage();
        } else {
          // Giriş yapılmadıysa login sayfasına yönlendir
          Future.microtask(
            () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
          );
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

/// Profil sayfası için oturum kontrolü
class _ProfileAuthGuard extends StatelessWidget {
  const _ProfileAuthGuard({Key? key}) : super(key: key);

  Future<bool> _checkLogin() async {
    return await UserModel.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          return const ProfilePage();
        } else {
          // Giriş yapılmadıysa login sayfasına yönlendir
          Future.microtask(
            () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
          );
          return const Scaffold(
            body: Center(child: Text('Giriş yapmalısınız...')),
          );
        }
      },
    );
  }
}

// ------------------- Geçiş Animasyonları -------------------

class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final Offset begin;

  SlideRoute({required this.page, this.begin = const Offset(1.0, 0.0)})
    : super(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          var slideAnimation = Tween(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );
          return SlideTransition(position: slideAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
    : super(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;

  ScaleRoute({required this.page})
    : super(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          );
          return ScaleTransition(scale: scaleAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      );
}

// ------------------- AuthGuard (Yetkilendirme kontrolü) -------------------

class AuthGuard {
  static Widget requireAuth({required Widget child, Widget? fallback}) {
    return FutureBuilder<bool>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        final isAuth = snapshot.data ?? false;

        if (!isAuth) {
          // Giriş yapılmamışsa login sayfasına yönlendir
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          });

          return fallback ?? _unauthorizedScreen();
        }

        return child;
      },
    );
  }

  // Auth kontrolünü yap
  static Future<bool> _checkAuthStatus() async {
    try {
      return await UserModel.isLoggedIn() && await UserModel.isSessionValid();
    } catch (_) {
      return false;
    }
  }

  // Bekleme ekranı
  static Widget _loadingScreen() => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
  );

  // Yetkisiz erişim ekranı
  static Widget _unauthorizedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF8F94FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.white),
            SizedBox(height: 20),
            const Text(
              'Yetkisiz Giriş',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 10),
            const Text(
              'Bu sayfaya erişmek için giriş yapmalısınız',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
