import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:zodicomment/viewmodel/login_viewmodel.dart';
import 'package:zodicomment/view/components/animated_background.dart';
import 'package:zodicomment/view/components/login_form.dart';

/// Modüler yapıda Login sayfası
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginPageContent(),
    );
  }
}

/// Login sayfasının içeriği
class _LoginPageContent extends StatelessWidget {
  const _LoginPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo veya Maskot
                _buildLogo(),

                const SizedBox(height: 24),

                // Başlık
                _buildTitle(),

                const SizedBox(height: 8),

                // Alt başlık
                _buildSubtitle(),

                const SizedBox(height: 40),

                // Form
                const LoginForm(),

                const SizedBox(height: 24),

                // Kayıt linki
                _buildRegisterLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logo veya maskot bileşeni
  Widget _buildLogo() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/maskot.png',
          fit: BoxFit.contain,
          height: 120,
          width: 120,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.auto_awesome,
              size: 100,
              color: Colors.white70,
            );
          },
        ),
      ),
    );
  }

  /// Başlık bileşeni
  Widget _buildTitle() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: const Text(
        'ZodiComment',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Color(0xAABB00FF),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  /// Alt başlık bileşeni
  Widget _buildSubtitle() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: const Text(
        'Yıldızlar ve rüyalar dünyasına hoş geldin',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Kayıt linki bileşeni
  Widget _buildRegisterLink(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: TextButton.icon(
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/register'),
        icon: const Icon(Icons.star, color: Colors.amber),
        label: const Text(
          'Henüz yıldız haritanı oluşturmadın mı? Kayıt Ol',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
}
