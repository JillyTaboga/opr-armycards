import 'package:flutter/material.dart';
import '../../domain/entities/selected_file.dart';
import '../../domain/services/rule_resolver.dart';
import '../themes/game_system_theme.dart';
import 'rule_chip.dart';
import 'special_item_row.dart';
import 'weapon_row.dart';

class UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  final GameSystemTheme theme;
  final RuleResolver ruleResolver;
  final String bgType;
  final double bgOpacity;
  final SelectedFile? customBgFile;
  final bool showFullRules;
  final double cardHeight;
  final VoidCallback? onExport;

  const UnitCard({
    super.key,
    required this.unit,
    required this.theme,
    required this.ruleResolver,
    required this.bgType,
    required this.bgOpacity,
    required this.customBgFile,
    required this.showFullRules,
    required this.cardHeight,
    this.onExport,
  });

  ImageProvider? _getBgImageProvider() {
    if (bgType == 'fantasy') {
      return const AssetImage('assets/fantasy_bg.jpg');
    } else if (bgType == 'grimdark') {
      return const AssetImage('assets/grimdark_bg.jpg');
    } else if (bgType == 'custom' && customBgFile != null) {
      if (customBgFile!.bytes != null) {
        return MemoryImage(customBgFile!.bytes!);
      }
    }
    return null;
  }

  Widget _buildBaseColumn(String baseLabel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'BASE',
          style: TextStyle(
              fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          baseLabel.split(' ').first,
          style: const TextStyle(
              fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatGauge(String label, String value, Color color) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const VerticalDivider(color: Colors.white10, width: 1),
          Expanded(
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = unit['name'] ?? 'Unidade Sem Nome';
    final genericName = unit['genericName'] ?? '';
    final cost = unit['cost'] ?? 0;
    final size = unit['size'] ?? 1;
    final defense = unit['defense'] ?? 5;
    final quality = unit['quality'] ?? 5;
    final bases = unit['bases'] as Map?;
    final isCombined = unit['combined'] == true;

    final List loadout = unit['loadout'] ?? unit['weapons'] ?? [];

    final weaponsList = loadout
        .where((item) =>
            item['type'] == 'ArmyBookWeapon' || item['range'] != null)
        .toList();

    final itemsList = loadout
        .where((item) =>
            item['type'] == 'ArmyBookItem' && item['range'] == null)
        .toList();

    final List rules = unit['rules'] ?? [];

    String baseLabel = '';
    if (bases != null) {
      final round = bases['round'];
      final square = bases['square'];
      if (round != null) {
        baseLabel = '${round}mm redonda';
      } else if (square != null) {
        baseLabel = '${square}mm quadrada';
      }
    }

    final bgImage = _getBgImageProvider();

    return Card(
      elevation: 3,
      color: theme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCombined
              ? theme.accent.withValues(alpha: 0.5)
              : theme.primary.withValues(alpha: 0.2),
          width: isCombined ? 2.0 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: cardHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.cardBg,
                        const Color(0xFF0F172A).withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              if (bgType != 'none' && bgImage != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: bgOpacity,
                    child: Image(
                      image: bgImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (genericName.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  genericName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (onExport != null) ...[
                                  IconButton(
                                    icon: const Icon(Icons.download_rounded, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: theme.accent,
                                    tooltip: 'Exportar PNG',
                                    onPressed: onExport,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: theme.accent.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    '$cost pts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              size == 1 ? '1 Modelo' : '$size Modelos',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildStatGauge('QUA', '$quality+', theme.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              _buildStatGauge('DEF', '$defense+', theme.accent),
                        ),
                        if (baseLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 42,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Center(
                                child: _buildBaseColumn(baseLabel),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (weaponsList.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Text(
                                        'EQUIPAMENTO / ARMAS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Divider(
                                              color: Colors.white10, height: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...weaponsList.map((w) => WeaponRow(
                                        weapon: w,
                                        theme: theme,
                                        ruleResolver: ruleResolver,
                                        showFullRules: showFullRules,
                                      )),
                                ],
                                if (itemsList.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Text(
                                        'ITENS ESPECIAIS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white38,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Divider(
                                              color: Colors.white10, height: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...itemsList.map((item) => SpecialItemRow(
                                        item: item,
                                        theme: theme,
                                        ruleResolver: ruleResolver,
                                        showFullRules: showFullRules,
                                      )),
                                ],
                                if (rules.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Text(
                                        'REGRAS ESPECIAIS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white38,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Divider(
                                              color: Colors.white10, height: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (showFullRules)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: rules.map<Widget>((r) {
                                        final detail =
                                            ruleResolver.findRuleDetail(r);
                                        final String ruleName = r['label'] ??
                                            r['name'] ??
                                            'Regra';
                                        final String description =
                                            detail?['description'] ??
                                                'Sem descrição detalhada.';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ruleName,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                description,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white60,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  else
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: rules
                                          .map<Widget>((r) => RuleChip(
                                                rule: r,
                                                theme: theme,
                                                ruleResolver: ruleResolver,
                                              ))
                                          .toList(),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
