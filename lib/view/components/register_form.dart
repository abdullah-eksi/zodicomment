import 'package:flutter/material.dart';
import 'package:zodicomment/viewmodel/register_viewmodel.dart';
import 'package:provider/provider.dart';

/// Kayıt formunu içeren bileşen
class RegisterForm extends StatelessWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);

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

            const SizedBox(height: 16),

            // Ad Soyad alanı
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.badge, color: Colors.purple),
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
              onSaved: (v) => viewModel.setFullname(v ?? ''),
              validator: viewModel.validateFullname,
            ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 20),

            // Burç dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Burç Seçimi',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.star, color: Colors.purple),
                  border: InputBorder.none,
                ),
                value: viewModel.zodiac,
                items: viewModel.zodiacList
                    .map(
                      (z) => DropdownMenuItem(
                        value: z,
                        child: Text(
                          z,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => viewModel.setZodiac(v ?? 'Koç'),
              ),
            ),

            const SizedBox(height: 20),

            // Mode dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Mod Seçimi',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.mood, color: Colors.purple),
                  border: InputBorder.none,
                ),
                value: viewModel.mode,
                items: viewModel.modeList
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => viewModel.setMode(v ?? 'eglenceli'),
              ),
            ),

            const SizedBox(height: 20),

            // Bildirim ayarı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Bildirimleri Aç',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                secondary: const Icon(
                  Icons.notifications_active,
                  color: Colors.purple,
                ),
                activeColor: Colors.purple,
                value: viewModel.notificationEnabled,
                onChanged: viewModel.setNotificationEnabled,
              ),
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

            // Kayıt butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.register();
                        if (success && context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
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
                        'Kayıt Ol',
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
