import 'package:flutter/material.dart';
import '../../domain/services/rule_resolver.dart';
import '../themes/game_system_theme.dart';
import 'rule_detail_sheet.dart';

class WeaponRow extends StatelessWidget {
  final Map<String, dynamic> weapon;
  final GameSystemTheme theme;
  final RuleResolver ruleResolver;
  final bool showFullRules;

  const WeaponRow({
    super.key,
    required this.weapon,
    required this.theme,
    required this.ruleResolver,
    required this.showFullRules,
  });

  @override
  Widget build(BuildContext context) {
    final name = weapon['name'] ?? 'Arma';
    final count = weapon['count'] ?? 1;
    final range = weapon['range'];
    final attacks = weapon['attacks'] ?? 1;
    final List specialRules = weapon['specialRules'] ?? [];

    String rangeText = 'Melee';
    IconData weaponIcon = Icons.gavel_rounded;
    if (range != null && range > 0) {
      rangeText = '$range"';
      weaponIcon = Icons.gps_fixed_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(weaponIcon,
                    size: 14,
                    color: range != null && range > 0
                        ? theme.primary
                        : theme.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        if (count > 1)
                          TextSpan(
                            text: '${count}x ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.accent,
                              fontSize: 13,
                            ),
                          ),
                        TextSpan(
                          text: name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$rangeText | A$attacks',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
            if (specialRules.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (showFullRules)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: specialRules.map<Widget>((r) {
                    final String rName = r['name'] ?? '';
                    final dynamic rRating = r['rating'];
                    final String displayLabel =
                        rName + (rRating != null ? '($rRating)' : '');
                    final detail = ruleResolver.findRuleDetail(r);
                    final String description =
                        detail?['description'] ?? 'Sem descrição.';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$displayLabel: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primary,
                                fontSize: 11,
                              ),
                            ),
                            TextSpan(
                              text: description,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: specialRules.map<Widget>((r) {
                    final String rName = r['name'] ?? '';
                    final dynamic rRating = r['rating'];
                    final String displayLabel =
                        rName + (rRating != null ? '($rRating)' : '');
                    return InkWell(
                      onTap: () => RuleDetailSheet.show(
                        context,
                        rule: r,
                        ruleResolver: ruleResolver,
                        theme: theme,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: theme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          displayLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
