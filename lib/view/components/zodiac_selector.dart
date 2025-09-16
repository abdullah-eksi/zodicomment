import 'package:flutter/material.dart';

class ZodiacSelector extends StatelessWidget {
  final String selectedZodiac;
  final List<String> zodiacList;
  final Function(String) onZodiacChanged;

  const ZodiacSelector({
    super.key,
    required this.selectedZodiac,
    required this.zodiacList,
    required this.onZodiacChanged,
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
            'Burç Seçimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildZodiacSelector(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildZodiacSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Burcunuzu Seçin',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF16213E),
        style: const TextStyle(color: Colors.white),
        value: selectedZodiac,
        items: zodiacList.map((String zodiac) {
          return DropdownMenuItem<String>(value: zodiac, child: Text(zodiac));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onZodiacChanged(newValue);
          }
        },
      ),
    );
  }
}
