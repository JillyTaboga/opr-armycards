import 'package:flutter/material.dart';
import '../../domain/entities/selected_file.dart';
import '../themes/game_system_theme.dart';
import '../../data/services/file_picker/file_picker_stub.dart'
    if (dart.library.html) '../../data/services/file_picker/file_picker_web.dart'
    if (dart.library.io) '../../data/services/file_picker/file_picker_io.dart';

class BackgroundConfigSheet extends StatefulWidget {
  final GameSystemTheme theme;
  final String initialBgType;
  final double initialBgOpacity;
  final SelectedFile? initialCustomBgFile;
  final double initialCardWidth;
  final double initialCardHeight;
  final void Function(
    String bgType,
    double bgOpacity,
    SelectedFile? customBgFile,
    double cardWidth,
    double cardHeight,
  ) onConfigChanged;

  const BackgroundConfigSheet({
    super.key,
    required this.theme,
    required this.initialBgType,
    required this.initialBgOpacity,
    required this.initialCustomBgFile,
    required this.initialCardWidth,
    required this.initialCardHeight,
    required this.onConfigChanged,
  });

  static void show(
    BuildContext context, {
    required GameSystemTheme theme,
    required String initialBgType,
    required double initialBgOpacity,
    required SelectedFile? initialCustomBgFile,
    required double initialCardWidth,
    required double initialCardHeight,
    required void Function(
      String bgType,
      double bgOpacity,
      SelectedFile? customBgFile,
      double cardWidth,
      double cardHeight,
    ) onConfigChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BackgroundConfigSheet(
          theme: theme,
          initialBgType: initialBgType,
          initialBgOpacity: initialBgOpacity,
          initialCustomBgFile: initialCustomBgFile,
          initialCardWidth: initialCardWidth,
          initialCardHeight: initialCardHeight,
          onConfigChanged: onConfigChanged,
        );
      },
    );
  }

  @override
  State<BackgroundConfigSheet> createState() => _BackgroundConfigSheetState();
}

class _BackgroundConfigSheetState extends State<BackgroundConfigSheet> {
  late String _bgType;
  late double _bgOpacity;
  SelectedFile? _customBgFile;
  late double _cardWidth;
  late double _cardHeight;

  @override
  void initState() {
    super.initState();
    _bgType = widget.initialBgType;
    _bgOpacity = widget.initialBgOpacity;
    _customBgFile = widget.initialCustomBgFile;
    _cardWidth = widget.initialCardWidth;
    _cardHeight = widget.initialCardHeight;
  }

  void _notifyChange() {
    widget.onConfigChanged(_bgType, _bgOpacity, _customBgFile, _cardWidth, _cardHeight);
  }

  Widget _buildBgOption({
    required String label,
    required String value,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 95,
        height: 70,
        decoration: BoxDecoration(
          color: selected ? widget.theme.primary.withValues(alpha: 0.15) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? widget.theme.primary : Colors.white.withValues(alpha: 0.05),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? widget.theme.primary : Colors.white60,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? widget.theme.primary : Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wallpaper_rounded, color: widget.theme.accent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Configurar Fundo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 16),
              const SizedBox(height: 8),
              
              const Text(
                'ESCOLHA O FUNDO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBgOption(
                      label: 'Nenhum',
                      value: 'none',
                      icon: Icons.block_rounded,
                      selected: _bgType == 'none',
                      onTap: () {
                        setState(() => _bgType = 'none');
                        _notifyChange();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildBgOption(
                      label: 'Fantasia',
                      value: 'fantasy',
                      icon: Icons.shield_rounded,
                      selected: _bgType == 'fantasy',
                      onTap: () {
                        setState(() => _bgType = 'fantasy');
                        _notifyChange();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildBgOption(
                      label: 'Grimdark',
                      value: 'grimdark',
                      icon: Icons.rocket_launch_rounded,
                      selected: _bgType == 'grimdark',
                      onTap: () {
                        setState(() => _bgType = 'grimdark');
                        _notifyChange();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildBgOption(
                      label: 'Personalizado',
                      value: 'custom',
                      icon: Icons.upload_file_rounded,
                      selected: _bgType == 'custom',
                      onTap: () {
                        setState(() => _bgType = 'custom');
                        _notifyChange();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              if (_bgType == 'custom') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final file = await pickImageFile();
                          if (file != null) {
                            setState(() {
                              _customBgFile = file;
                              _bgType = 'custom';
                            });
                            _notifyChange();
                          }
                        },
                        icon: const Icon(Icons.folder_open_rounded),
                        label: const Text('Selecionar Imagem'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.theme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _customBgFile != null
                            ? 'Arquivo: ${_customBgFile!.name}'
                            : 'Nenhuma imagem selecionada.',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              if (_bgType != 'none') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'OPACIDADE DO FUNDO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${(_bgOpacity * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Slider(
                  value: _bgOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: widget.theme.accent,
                  inactiveColor: Colors.white10,
                  onChanged: (val) {
                    setState(() => _bgOpacity = val);
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 8),
              ],

              const Divider(color: Colors.white10, height: 16),
              const SizedBox(height: 8),

              // Card Width Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LARGURA DA CARTA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${_cardWidth.toInt()}px',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Slider(
                value: _cardWidth,
                min: 100.0,
                max: 1000.0,
                divisions: 90, // steps of 10
                activeColor: widget.theme.primary,
                inactiveColor: Colors.white10,
                onChanged: (val) {
                  setState(() => _cardWidth = val);
                  _notifyChange();
                },
              ),
              const SizedBox(height: 12),

              // Card Height Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALTURA DA CARTA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${_cardHeight.toInt()}px',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Slider(
                value: _cardHeight,
                min: 100.0,
                max: 1000.0,
                divisions: 90, // steps of 10
                activeColor: widget.theme.accent,
                inactiveColor: Colors.white10,
                onChanged: (val) {
                  setState(() => _cardHeight = val);
                  _notifyChange();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
