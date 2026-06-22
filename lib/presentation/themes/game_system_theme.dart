import 'package:flutter/material.dart';

class GameSystemTheme {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final Color background;
  final Color cardBg;
  final IconData icon;

  const GameSystemTheme({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.background,
    required this.cardBg,
    required this.icon,
  });

  // Get dynamic theme styling based on OPR Game System or manual selection
  static GameSystemTheme getTheme(String? code, String selectedPalette) {
    String palette = selectedPalette;
    
    // Auto-detect default palette based on loaded list system if no manual override
    if (palette == 'auto') {
      final c = code?.toLowerCase();
      if (c == 'gf' || c == 'gff') {
        palette = 'grimdark';
      } else if (c == 'aof' || c == 'aofs' || c == 'aofr') {
        palette = 'fantasy';
      } else {
        palette = 'grimdark'; // default
      }
    }

    switch (palette) {
      case 'grimdark':
        return const GameSystemTheme(
          id: 'grimdark',
          name: 'Grimdark Future',
          primary: Color(0xFF38BDF8), // Light Blue 400
          accent: Color(0xFFF97316),  // Amber/Orange 500
          background: Color(0xFF0F172A), // Slate 900
          cardBg: Color(0xFF1E293B),   // Slate 800
          icon: Icons.rocket_launch_rounded,
        );
      case 'fantasy':
        return const GameSystemTheme(
          id: 'fantasy',
          name: 'Age of Fantasy',
          primary: Color(0xFF10B981), // Emerald 500
          accent: Color(0xFFF59E0B),  // Gold/Amber 500
          background: Color(0xFF062F24), // Dark Forest
          cardBg: Color(0xFF064E3B),   // Forest Green
          icon: Icons.shield_rounded,
        );
      case 'cyber':
        return const GameSystemTheme(
          id: 'cyber',
          name: 'Cyber Alliance',
          primary: Color(0xFF8B5CF6), // Violet Purple
          accent: Color(0xFF06B6D4),  // Neon Cyan
          background: Color(0xFF0B0F19), // Deep Cyber Black
          cardBg: Color(0xFF161F30),   // Cyber Slate Card
          icon: Icons.electrical_services_rounded,
        );
      case 'hive':
        return const GameSystemTheme(
          id: 'hive',
          name: 'Alien Hive',
          primary: Color(0xFF84CC16), // Lime Green
          accent: Color(0xFFD946EF),  // Pink Magenta
          background: Color(0xFF170C2A), // Dark Purple
          cardBg: Color(0xFF2C164D),   // Xenon Purple Card
          icon: Icons.pest_control_rounded,
        );
      case 'volcanic':
        return const GameSystemTheme(
          id: 'volcanic',
          name: 'Volcanic Wasteland',
          primary: Color(0xFFEF4444), // Rust Red
          accent: Color(0xFFFBBF24),  // Ash Yellow
          background: Color(0xFF1A0A0A), // Ash Black
          cardBg: Color(0xFF2E1212),   // Obsidian Card
          icon: Icons.local_fire_department_rounded,
        );
      case 'noir':
        return const GameSystemTheme(
          id: 'noir',
          name: 'Noir / Charcoal',
          primary: Color(0xFF888888), // Medium Gray
          accent: Color(0xFFCCCCCC),  // Light Gray
          background: Color(0xFF000000), // Pure Black
          cardBg: Color(0xFF121212),   // Dark Charcoal
          icon: Icons.brightness_3_rounded,
        );
      case 'obsidian':
        return const GameSystemTheme(
          id: 'obsidian',
          name: 'Obsidian / Onyx',
          primary: Color(0xFF6E6E6E), // Steel Gray
          accent: Color(0xFFAAAAAA),  // Silver Gray
          background: Color(0xFF080808), // Pitch Black
          cardBg: Color(0xFF1F1F1F),   // Dark Obsidian
          icon: Icons.nightlight_round,
        );
      default:
        return const GameSystemTheme(
          id: 'grimdark',
          name: 'Grimdark Future',
          primary: Color(0xFF38BDF8),
          accent: Color(0xFFF97316),
          background: Color(0xFF0F172A),
          cardBg: Color(0xFF1E293B),
          icon: Icons.rocket_launch_rounded,
        );
    }
  }
}
