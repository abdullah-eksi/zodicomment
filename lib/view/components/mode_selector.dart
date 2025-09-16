import 'package:flutter/material.dart';

class ModeSelector extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeChanged;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Kişilik Modu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildModeSelector(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Column(
      children: [
        _buildModeOption(
          title: 'Eğlenceli',
          description: 'Sohbetlerinde bol espri ve neşe!',
          value: 'eglenceli',
        ),
        _buildModeOption(
          title: 'Romantik',
          description: 'Duygusal ve romantik bir yaklaşım',
          value: 'romantik',
        ),
        _buildModeOption(
          title: 'Bilge',
          description: 'Derin ve felsefi bir bakış açısı',
          value: 'bilge',
        ),
        _buildModeOption(
          title: 'Eleştirel',
          description: 'Analitik ve sorgulayıcı bir yaklaşım',
          value: 'elestirel',
        ),
      ],
    );
  }

  Widget _buildModeOption({
    required String title,
    required String description,
    required String value,
  }) {
    final isSelected = selectedMode == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.white30,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? const Color(0xFF9C27B0).withOpacity(0.2)
            : Colors.black26,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Theme(
        data: ThemeData(unselectedWidgetColor: Colors.white54),
        child: RadioListTile<String>(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
          value: value,
          groupValue: selectedMode,
          onChanged: (val) {
            if (val != null) {
              onModeChanged(val);
            }
          },
          activeColor: const Color(0xFFAB47BC),
          selected: isSelected,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
