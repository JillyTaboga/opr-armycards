import 'package:flutter/material.dart';
import '../../domain/services/rule_resolver.dart';
import '../themes/game_system_theme.dart';

class RuleDetailSheet {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> rule,
    required RuleResolver ruleResolver,
    required GameSystemTheme theme,
  }) {
    final detail = ruleResolver.findRuleDetail(rule);
    final String ruleName = rule['label'] ?? rule['name'] ?? 'Regra Especial';
    final String description = detail?['description'] ??
        'Sem descrição detalhada disponível para esta regra especial no momento.';

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: theme.accent, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ruleName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white60),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 16),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xDDFFFFFF),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
