import 'package:flutter/material.dart';
import 'package:zodicomment/viewmodel/login_viewmodel.dart';
import 'package:provider/provider.dart';

/// Giriş formunu içeren bileşen
class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            // Kullanıcı adı alanı
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.person, color: Colors.purple),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
              onSaved: (v) => viewModel.setNickname(v ?? ''),
              validator: viewModel.validateNickname,
            ),

            const SizedBox(height: 20),

            // Şifre alanı
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Şifre',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.vpn_key, color: Colors.purple),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
              obscureText: true,
              onSaved: (v) => viewModel.setPassword(v ?? ''),
              validator: viewModel.validatePassword,
            ),

            const SizedBox(height: 30),

            // Hata mesajı (varsa)
            if (viewModel.errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  viewModel.errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Giriş butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.login();
                        if (success && context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: Colors.purple.withOpacity(0.5),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
