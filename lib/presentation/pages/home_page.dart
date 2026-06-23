import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../data/services/army_api_service.dart';
import '../../data/services/file_saver/file_saver_stub.dart'
    if (dart.library.html) '../../data/services/file_saver/file_saver_web.dart'
    if (dart.library.io) '../../data/services/file_saver/file_saver_io.dart';
import '../../data/services/printer/printer_stub.dart'
    if (dart.library.html) '../../data/services/printer/printer_web.dart'
    if (dart.library.io) '../../data/services/printer/printer_io.dart';
import '../../domain/entities/selected_file.dart';
import '../../domain/services/rule_resolver.dart';
import '../themes/game_system_theme.dart';
import '../widgets/background_config_sheet.dart';
import '../widgets/palette_selector.dart';
import '../widgets/unit_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _idController = TextEditingController(
    text: 'o7SWLk3iXtSY',
  );
  final _formKey = GlobalKey<FormState>();
  final _apiService = ArmyApiService();

  bool _isLoading = false;
  bool _isProcessing = false;
  String _processingMessage = '';
  String? _responseJson;
  String? _errorMessage;

  // Parsed army forge list data
  Map<String, dynamic>? _armyData;
  // Controls if JSON is displayed instead of the cards
  bool _showJson = false;
  // Controls manually selected theme palette ('auto', 'grimdark', 'fantasy', 'cyber', 'hive', 'volcanic')
  String _selectedPalette = 'auto';
  // Controls if special rules are displayed in full details inside the card
  bool _showFullRules = false;

  // Card background configuration
  String _bgType = 'none'; // 'none', 'fantasy', 'grimdark', 'custom'
  double _bgOpacity = 0.1; // Default 10%
  SelectedFile? _customBgFile;
  double _cardWidth = 400.0;
  double _cardHeight = 520.0;

  // Print & Export configuration
  final List<GlobalKey> _cardKeys = [];
  bool _isLandscape = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _capturePng(GlobalKey key) async {
    try {
      debugPrint("[CapturePNG] Step 1: Getting context");
      final context = key.currentContext;
      if (context == null) {
        debugPrint("[CapturePNG] Context is null");
        return null;
      }

      debugPrint("[CapturePNG] Step 2: Getting renderObject");
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint("[CapturePNG] renderObject is not RenderRepaintBoundary");
        return null;
      }

      debugPrint("[CapturePNG] Step 3: Check debugNeedsPaint");
      final boundary = renderObject;
      bool needsPaint = false;
      assert(() {
        needsPaint = boundary.debugNeedsPaint;
        return true;
      }());
      if (needsPaint) {
        debugPrint("[CapturePNG] Awaiting paint frame");
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint("[CapturePNG] Step 4: Check mounted");
      if (!context.mounted) {
        debugPrint("[CapturePNG] Context is not mounted");
        return null;
      }

      debugPrint("[CapturePNG] Step 5: Calling toImage");
      ui.Image? image;
      try {
        image = await boundary.toImage(pixelRatio: 3.0);
        debugPrint("[CapturePNG] toImage returned: $image");
      } catch (e) {
        debugPrint("[CapturePNG] Error in toImage: $e");
        return null;
      }

      debugPrint("[CapturePNG] Step 6: Calling toByteData");
      ByteData? byteData;
      try {
        byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        debugPrint("[CapturePNG] toByteData returned: $byteData");
      } catch (e) {
        debugPrint("[CapturePNG] Error in toByteData: $e");
        return null;
      }

      if (byteData == null) {
        debugPrint("[CapturePNG] ByteData is null");
        return null;
      }

      debugPrint("[CapturePNG] Step 7: Converting to Uint8List");
      final bytes = byteData.buffer.asUint8List();
      debugPrint("[CapturePNG] Success! Bytes length: ${bytes.length}");
      return bytes;
    } catch (e) {
      debugPrint("[CapturePNG] General Error: $e");
      return null;
    }
  }

  Future<void> _exportSingleCard(int index, String name) async {
    if (index >= _cardKeys.length) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Exportando carta "$name"...';
    });
    try {
      final bytes = await _capturePng(_cardKeys[index]);
      if (bytes != null) {
        await saveFile(bytes, '${name.replaceAll(' ', '_')}.png');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Carta "$name" exportada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Não foi possível gerar a imagem");
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar carta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportAllCards() async {
    final List units = _armyData?['units'] ?? [];
    if (units.isEmpty || _cardKeys.length != units.length) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Exportando todas as cartas...';
    });
    try {
      for (int i = 0; i < units.length; i++) {
        final unit = units[i];
        final String name = unit['name'] ?? 'Unidade';
        setState(() {
          _processingMessage =
              'Exportando carta ${i + 1} de ${units.length} ("$name")...';
        });
        final bytes = await _capturePng(_cardKeys[i]);
        if (bytes != null) {
          await saveFile(bytes, '${name.replaceAll(' ', '_')}.png');
        }
      }
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Todas as cartas foram exportadas!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar cartas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePrintSetupConfirmed(double paperWidth) async {
    final List units = _armyData?['units'] ?? [];
    if (units.isEmpty || _cardKeys.length != units.length) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Preparando impressão (capturando cartas)...';
    });
    try {
      final List<Uint8List> images = [];
      for (int i = 0; i < units.length; i++) {
        final unit = units[i];
        final String name = unit['name'] ?? 'Unidade';
        setState(() {
          _processingMessage =
              'Capturando carta ${i + 1} de ${units.length} ("$name")...';
        });
        final bytes = await _capturePng(_cardKeys[i]);
        if (bytes != null) {
          images.add(bytes);
        }
      }
      if (images.isNotEmpty) {
        double cardWidth = _cardWidth;
        if (paperWidth - 48 < _cardWidth) {
          cardWidth = paperWidth - 48;
        }
        setState(() {
          _processingMessage = 'Gerando página de impressão...';
        });
        await printImages(images, paperWidth, cardWidth, _cardHeight);
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao preparar impressão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPrintSetupDialog(GameSystemTheme theme) {
    String selectedPaper = 'a4'; // 'a4', 'letter', 'custom'
    final customWidthController = TextEditingController(text: '800');
    final customHeightController = TextEditingController(text: '600');
    bool isLandscape = _isLandscape;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.print_rounded, color: theme.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Configurar Impressão',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ESCOLHA O TAMANHO DO PAPEL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<String>(
                      title: const Text(
                        'A4 (210mm)',
                        style: TextStyle(color: Colors.white70),
                      ),
                      subtitle: const Text(
                        'Retrato: 794px | Paisagem: 1123px',
                        style: TextStyle(color: Colors.white38),
                      ),
                      value: 'a4',
                      groupValue: selectedPaper,
                      activeColor: theme.primary,
                      onChanged: (val) =>
                          setDialogState(() => selectedPaper = val!),
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Carta / Letter (216mm)',
                        style: TextStyle(color: Colors.white70),
                      ),
                      subtitle: const Text(
                        'Retrato: 816px | Paisagem: 1056px',
                        style: TextStyle(color: Colors.white38),
                      ),
                      value: 'letter',
                      groupValue: selectedPaper,
                      activeColor: theme.primary,
                      onChanged: (val) =>
                          setDialogState(() => selectedPaper = val!),
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Personalizado',
                        style: TextStyle(color: Colors.white70),
                      ),
                      subtitle: const Text(
                        'Defina as dimensões da folha',
                        style: TextStyle(color: Colors.white38),
                      ),
                      value: 'custom',
                      groupValue: selectedPaper,
                      activeColor: theme.primary,
                      onChanged: (val) =>
                          setDialogState(() => selectedPaper = val!),
                    ),
                    if (selectedPaper == 'custom') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customWidthController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Largura (px)',
                                labelStyle: TextStyle(color: theme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: customHeightController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Altura (px)',
                                labelStyle: TextStyle(color: theme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'ORIENTAÇÃO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.crop_portrait_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Retrato',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            selected: !isLandscape,
                            selectedColor: theme.primary.withValues(alpha: 0.3),
                            backgroundColor: const Color(0xFF0F172A),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  isLandscape = false;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.crop_landscape_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Paisagem',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            selected: isLandscape,
                            selectedColor: theme.primary.withValues(alpha: 0.3),
                            backgroundColor: const Color(0xFF0F172A),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  isLandscape = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    double width = 794.0;
                    if (selectedPaper == 'a4') {
                      width = isLandscape ? 1123.0 : 794.0;
                    } else if (selectedPaper == 'letter') {
                      width = isLandscape ? 1056.0 : 816.0;
                    } else if (selectedPaper == 'custom') {
                      double w =
                          double.tryParse(customWidthController.text) ?? 800.0;
                      double h =
                          double.tryParse(customHeightController.text) ?? 600.0;
                      if (w < 100) w = 100;
                      if (w > 3000) w = 3000;
                      if (h < 100) h = 100;
                      if (h > 3000) h = 3000;
                      width = isLandscape ? (w > h ? w : h) : (w < h ? w : h);
                    }
                    Navigator.pop(context);

                    setState(() {
                      _isLandscape = isLandscape;
                    });

                    _handlePrintSetupConfirmed(width);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _fetchArmyData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _responseJson = null;
      _armyData = null;
    });

    final armyId = _idController.text.trim();

    try {
      final decoded = await _apiService.fetchArmyData(armyId);
      final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
      setState(() {
        _responseJson = formatted;
        _armyData = decoded;
        _showJson = false; // Show card list by default on success
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_responseJson != null) {
      Clipboard.setData(ClipboardData(text: _responseJson!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('JSON copiado para a área de transferência!'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildResultWidget() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6366F1)),
                  SizedBox(height: 16),
                  Text(
                    'Carregando dados da API...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
        color: const Color(0xFF7F1D1D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFCA5A5),
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Ocorreu um erro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFCA5A5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFFFEE2E2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_armyData != null) {
      final theme = GameSystemTheme.getTheme(
        _armyData!['gameSystem'],
        _selectedPalette,
      );

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRosterHeader(_armyData!, theme),
            const SizedBox(height: 12),
            _buildToggleControls(theme),
            const SizedBox(height: 12),
            if (!_showJson) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'MOSTRAR REGRAS DETALHADAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 24,
                      child: Switch(
                        value: _showFullRules,
                        onChanged: (val) =>
                            setState(() => _showFullRules = val),
                        activeThumbColor: theme.accent,
                        activeTrackColor: theme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_showJson)
              Card(
                elevation: 4,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.data_object,
                                color: theme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Retorno JSON Formatado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _copyToClipboard,
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: theme.primary,
                            ),
                            label: Text(
                              'Copiar',
                              style: TextStyle(color: theme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _responseJson!,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: theme.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildCardsView(_armyData!, theme),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.data_array_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum dado carregado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Insira o ID e clique em enviar para ver o retorno.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleControls(GameSystemTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showJson = false),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_showJson
                      ? theme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: !_showJson
                      ? Border.all(color: theme.primary.withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.layers_rounded,
                      size: 18,
                      color: !_showJson ? theme.primary : Colors.white60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CARTAS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: !_showJson ? theme.primary : Colors.white60,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showJson = true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _showJson
                      ? theme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _showJson
                      ? Border.all(color: theme.primary.withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.code_rounded,
                      size: 18,
                      color: _showJson ? theme.primary : Colors.white60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CÓDIGO JSON',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _showJson ? theme.primary : Colors.white60,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterHeader(Map<String, dynamic> data, GameSystemTheme theme) {
    final name = data['name'] ?? 'Exército sem Nome';
    final modelCount = data['modelCount'] ?? 0;
    final listPoints = data['listPoints'] ?? 0;
    final pointsLimit = data['pointsLimit'] ?? 0;
    final activationCount = data['activationCount'] ?? 0;

    return Card(
      elevation: 4,
      color: theme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(theme.icon, color: theme.accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        theme.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(
                  'PONTOS',
                  '$listPoints / $pointsLimit',
                  theme.accent,
                ),
                _buildHeaderStat('MODELOS', '$modelCount', theme.primary),
                _buildHeaderStat(
                  'ATIVAÇÕES',
                  '$activationCount',
                  theme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCardsView(Map<String, dynamic> data, GameSystemTheme theme) {
    final List units = data['units'] ?? [];

    if (units.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Nenhuma unidade encontrada nesta lista.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    // Synchronize keys length
    if (_cardKeys.length != units.length) {
      _cardKeys.clear();
      for (int i = 0; i < units.length; i++) {
        _cardKeys.add(GlobalKey());
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = _cardWidth;
        if (constraints.maxWidth < _cardWidth) {
          cardWidth = constraints.maxWidth;
        }

        final ruleResolver = RuleResolver(data);

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(units.length, (i) {
            final unit = units[i];
            final String name = unit['name'] ?? 'Unidade';
            return RepaintBoundary(
              key: _cardKeys[i],
              child: SizedBox(
                width: cardWidth,
                child: UnitCard(
                  unit: unit,
                  theme: theme,
                  ruleResolver: ruleResolver,
                  bgType: _bgType,
                  bgOpacity: _bgOpacity,
                  customBgFile: _customBgFile,
                  showFullRules: _showFullRules,
                  cardHeight: _cardHeight,
                  onExport: () => _exportSingleCard(i, name),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameSystemTheme.getTheme(
      _armyData?['gameSystem'],
      _selectedPalette,
    );

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.cardBg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(theme.icon, color: theme.accent),
            const SizedBox(width: 10),
            Text(
              _armyData != null ? 'OPR Army Card' : 'OPR Army Forge API',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper_rounded, color: Colors.white),
            tooltip: 'Configurar Fundo das Cartas',
            onPressed: () => BackgroundConfigSheet.show(
              context,
              theme: theme,
              initialBgType: _bgType,
              initialBgOpacity: _bgOpacity,
              initialCustomBgFile: _customBgFile,
              initialCardWidth: _cardWidth,
              initialCardHeight: _cardHeight,
              onConfigChanged:
                  (bgType, bgOpacity, customBgFile, cardWidth, cardHeight) {
                    setState(() {
                      _bgType = bgType;
                      _bgOpacity = bgOpacity;
                      _customBgFile = customBgFile;
                      _cardWidth = cardWidth;
                      _cardHeight = cardHeight;
                    });
                  },
            ),
          ),
          PaletteSelector(
            currentTheme: theme,
            onPaletteSelected: (value) {
              setState(() {
                _selectedPalette = value;
              });
            },
          ),
          if (_armyData != null) ...[
            IconButton(
              icon: const Icon(
                Icons.download_for_offline_rounded,
                color: Colors.white,
              ),
              tooltip: 'Exportar todas as cartas em PNG',
              onPressed: _exportAllCards,
            ),
            IconButton(
              icon: const Icon(Icons.print_rounded, color: Colors.white),
              tooltip: 'Imprimir Cartas',
              onPressed: () => _showPrintSetupDialog(theme),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main search card
                  Card(
                    elevation: 4,
                    color: theme.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Buscar Exército',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Insira o Army ID para obter o retorno estruturado e as fichas temáticas.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _idController,
                              decoration: InputDecoration(
                                labelText: 'Army ID',
                                hintText:
                                    'Digite o ID do exército (ex: n3t4xQ...)',
                                prefixIcon: Icon(
                                  Icons.fingerprint,
                                  color: theme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, insira o Army ID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _fetchArmyData,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                _isLoading
                                    ? 'Buscando...'
                                    : 'Enviar Requisição',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Result Section
                  Expanded(child: _buildResultWidget()),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _processingMessage,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
