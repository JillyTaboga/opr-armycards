import 'package:flutter/material.dart';
import '../../domain/services/rule_resolver.dart';
import '../themes/game_system_theme.dart';
import 'rule_detail_sheet.dart';

class RuleChip extends StatelessWidget {
  final Map<String, dynamic> rule;
  final GameSystemTheme theme;
  final RuleResolver ruleResolver;

  const RuleChip({
    super.key,
    required this.rule,
    required this.theme,
    required this.ruleResolver,
  });

  @override
  Widget build(BuildContext context) {
    final String label = rule['label'] ?? rule['name'] ?? 'Regra';
    return GestureDetector(
      onTap: () => RuleDetailSheet.show(
        context,
        rule: rule,
        ruleResolver: ruleResolver,
        theme: theme,
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: theme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.info_outline_rounded,
              size: 11,
              color: theme.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
