import 'package:flutter/material.dart';
import '../../domain/services/rule_resolver.dart';
import '../themes/game_system_theme.dart';
import 'rule_detail_sheet.dart';

class SpecialItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final GameSystemTheme theme;
  final RuleResolver ruleResolver;
  final bool showFullRules;

  const SpecialItemRow({
    super.key,
    required this.item,
    required this.theme,
    required this.ruleResolver,
    required this.showFullRules,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? 'Item';
    final label = item['label'] ?? name;
    final List content = item['content'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xDDFFFFFF),
                  ),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  if (showFullRules)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: content.map<Widget>((r) {
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
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
                      children: content.map<Widget>((r) {
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
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Text(
                              displayLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white60,
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
        ],
      ),
    );
  }
}
