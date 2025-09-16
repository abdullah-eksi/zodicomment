import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:zodicomment/viewmodel/register_viewmodel.dart';
import 'package:zodicomment/view/components/animated_background.dart';
import 'package:zodicomment/view/components/register_form.dart';

/// Modüler yapıda Register sayfası
class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterPageContent(),
    );
  }
}

/// Register sayfasının içeriği
class _RegisterPageContent extends StatelessWidget {
  const _RegisterPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Maskot
                _buildLogo(),

                const SizedBox(height: 16),

                // Başlık
                _buildTitle(),

                const SizedBox(height: 8),

                // Alt başlık
                _buildSubtitle(),

                const SizedBox(height: 32),

                // Form
                const RegisterForm(),

                const SizedBox(height: 24),

                // Giriş linki
                _buildLoginLink(context),
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
          height: 100,
          width: 100,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.auto_awesome,
              size: 80,
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
        'ZodiComment\'e katıl',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: Color(0xAABB00FF),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Alt başlık bileşeni
  Widget _buildSubtitle() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: const Text(
        'Yıldızlar ve rüyalar dünyasında kendi yolculuğunu başlat',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Giriş linki bileşeni
  Widget _buildLoginLink(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        icon: const Icon(Icons.login, color: Colors.amber),
        label: const Text(
          'Zaten hesabın var mı? Giriş Yap',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
}
