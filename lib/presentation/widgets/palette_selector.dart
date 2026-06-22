import 'package:flutter/material.dart';
import '../themes/game_system_theme.dart';

class PaletteSelector extends StatelessWidget {
  final GameSystemTheme currentTheme;
  final ValueChanged<String> onPaletteSelected;

  const PaletteSelector({
    super.key,
    required this.currentTheme,
    required this.onPaletteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> palettes = [
      {
        'id': 'grimdark',
        'name': 'Grimdark',
        'primary': const Color(0xFF38BDF8),
        'accent': const Color(0xFFF97316),
      },
      {
        'id': 'fantasy',
        'name': 'Fantasia',
        'primary': const Color(0xFF10B981),
        'accent': const Color(0xFFF59E0B),
      },
      {
        'id': 'cyber',
        'name': 'Cibernético',
        'primary': const Color(0xFF8B5CF6),
        'accent': const Color(0xFF06B6D4),
      },
      {
        'id': 'hive',
        'name': 'Colmeia',
        'primary': const Color(0xFF84CC16),
        'accent': const Color(0xFFD946EF),
      },
      {
        'id': 'volcanic',
        'name': 'Vulcânico',
        'primary': const Color(0xFFEF4444),
        'accent': const Color(0xFFFBBF24),
      },
      {
        'id': 'noir',
        'name': 'Noir',
        'primary': const Color(0xFF888888),
        'accent': const Color(0xFFCCCCCC),
      },
      {
        'id': 'obsidian',
        'name': 'Obsidian',
        'primary': const Color(0xFF6E6E6E),
        'accent': const Color(0xFFAAAAAA),
      },
    ];

    return PopupMenuButton<String>(
      icon: const Icon(Icons.palette_rounded, color: Colors.white),
      tooltip: 'Selecionar Paleta de Cores',
      onSelected: onPaletteSelected,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      itemBuilder: (BuildContext context) {
        return palettes.map((p) {
          final isSelected = currentTheme.id == p['id'];
          return PopupMenuItem<String>(
            value: p['id'],
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: p['primary'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: p['accent'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  p['name'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? p['primary'] : Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: p['primary'],
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
