import 'dart:io';
import 'dart:ui' as ui;
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

enum EditorTab { crop, rotate, filters, text, badges }

class TextLayer {
  TextLayer({
    required this.id,
    required this.text,
    this.offset = const Offset(60, 60),
    this.fontSize = 24.0,
    this.color = Colors.white,
    this.backgroundColor = Colors.black87,
    this.isBold = true,
  });

  final String id;
  String text;
  Offset offset;
  double fontSize;
  Color color;
  Color? backgroundColor;
  bool isBold;
}

class BadgeLayer {
  BadgeLayer({
    required this.id,
    required this.text,
    this.offset = const Offset(20, 20),
    this.backgroundColor = const Color(0xFFDC2626),
    this.textColor = Colors.white,
  });

  final String id;
  final String text;
  Offset offset;
  Color backgroundColor;
  Color textColor;
}

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({required this.imageResource, super.key});

  final FileResource imageResource;

  static Route<FileResource?> route(FileResource resource) {
    return MaterialPageRoute<FileResource?>(
      builder: (_) => ImageEditorScreen(imageResource: resource),
    );
  }

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  EditorTab _currentTab = EditorTab.crop;
  bool _isSaving = false;
  bool _isCroppingAction = false;

  // Active working image file (updated when cropped)
  File? _activeImageFile;

  // Aspect ratio (width / height). Null means original / free.
  double? _aspectRatio;
  double _naturalAspectRatio = 4 / 3;

  // Effective canvas aspect ratio taking quarter-turn rotation into account
  double get _effectiveAspectRatio {
    final base = _aspectRatio ?? _naturalAspectRatio;
    if (_rotationQuarterTurns % 2 == 1) {
      return 1.0 / (base <= 0 ? 1.0 : base);
    }
    return base;
  }

  // Interactive crop selection box in canvas coordinates
  Rect? _cropRect;

  // Transformation states
  int _rotationQuarterTurns = 0; // 0, 1, 2, 3
  bool _flipHorizontal = false;
  bool _flipVertical = false;

  // Adjustments
  double _brightness = 0.0; // -0.5 to 0.5
  double _contrast = 1.0; // 0.5 to 1.5
  double _saturation = 1.0; // 0.0 to 2.0
  String _selectedFilter = 'Original';

  // Layers
  final List<TextLayer> _textLayers = [];
  final List<BadgeLayer> _badgeLayers = [];
  String? _selectedLayerId;

  // Predefined color palettes
  final List<Color> _swatchColors = const [
    Colors.white,
    Colors.black,
    Color(0xFFEF4444), // Red
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ];

  final List<Color?> _bgSwatchColors = const [
    null,
    Colors.black87,
    Colors.white,
    Color(0xFFDC2626),
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFFD97706),
  ];

  final List<String> _presetBadges = const [
    'URGENT',
    'BEST OFFER',
    'VERIFIED',
    'FEATURED',
    'SALE',
    'NEGOTIABLE',
    'NEW',
  ];

  @override
  void initState() {
    super.initState();
    final path = widget.imageResource.filePath;
    if (!path.startsWith('http://') && !path.startsWith('https://')) {
      _activeImageFile = File(path);
    }
    _resolveImageDimensions();
  }

  void _resolveImageDimensions() {
    ImageProvider provider;
    if (_activeImageFile != null) {
      provider = FileImage(_activeImageFile!);
    } else {
      final path = widget.imageResource.filePath;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        provider = NetworkImage(path);
      } else {
        provider = FileImage(File(path));
      }
    }
    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        if (mounted && info.image.width > 0 && info.image.height > 0) {
          setState(() {
            _naturalAspectRatio = info.image.width / info.image.height;
          });
        }
      }),
    );
  }

  void _resetAll() {
    setState(() {
      _aspectRatio = null;
      _cropRect = null;
      _rotationQuarterTurns = 0;
      _flipHorizontal = false;
      _flipVertical = false;
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
      _selectedFilter = 'Original';
      _textLayers.clear();
      _badgeLayers.clear();
      _selectedLayerId = null;
    });
    _resolveImageDimensions();
  }

  void _applyFilter(String name) {
    setState(() {
      _selectedFilter = name;
      switch (name) {
        case 'Vivid':
          _contrast = 1.2;
          _saturation = 1.4;
          _brightness = 0.05;
          break;
        case 'Warm':
          _contrast = 1.05;
          _saturation = 1.1;
          _brightness = 0.05;
          break;
        case 'Cool':
          _contrast = 1.1;
          _saturation = 0.95;
          _brightness = 0.0;
          break;
        case 'Mono':
          _contrast = 1.15;
          _saturation = 0.0;
          _brightness = 0.0;
          break;
        case 'Vintage':
          _contrast = 0.9;
          _saturation = 0.8;
          _brightness = 0.08;
          break;
        case 'Dramatic':
          _contrast = 1.4;
          _saturation = 0.7;
          _brightness = -0.05;
          break;
        case 'Original':
        default:
          _contrast = 1.0;
          _saturation = 1.0;
          _brightness = 0.0;
          break;
      }
    });
  }

  List<double> _buildColorMatrix() {
    // 4x5 Color Matrix for Brightness, Contrast, and Saturation
    final c = _contrast;
    final b = _brightness * 255;
    final s = _saturation;

    final invSat = 1.0 - s;
    final r = 0.2126 * invSat;
    final g = 0.7152 * invSat;
    final bl = 0.0722 * invSat;

    // Filter adjustments for Warm / Cool tints
    double rOffset = 0;
    double bOffset = 0;
    if (_selectedFilter == 'Warm') {
      rOffset = 15.0;
      bOffset = -15.0;
    } else if (_selectedFilter == 'Cool') {
      rOffset = -15.0;
      bOffset = 20.0;
    }

    return <double>[
      c * (r + s), c * g, c * bl, 0, b + rOffset,
      c * r, c * (g + s), c * bl, 0, b,
      c * r, c * g, c * (bl + s), 0, b + bOffset,
      0, 0, 0, 1, 0,
    ];
  }

  Future<void> _saveAndReturn() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Clear selection so bounding box handles are not rendered into final image
      setState(() => _selectedLayerId = null);
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas boundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate image bytes');
      }

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      if (mounted) {
        Navigator.of(context).pop(LocalFileResource(file));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addTextLayer() {
    final textController = TextEditingController(text: 'Sample Text');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('addText'.translate(context)),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'enterText'.translate(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('cancel'.translate(context)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(80, 38)),
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                final id = 'text_${DateTime.now().millisecondsSinceEpoch}';
                setState(() {
                  _textLayers.add(
                    TextLayer(
                      id: id,
                      text: text,
                      offset: const Offset(40, 80),
                    ),
                  );
                  _selectedLayerId = id;
                });
              }
              Navigator.of(dialogCtx).pop();
            },
            child: Text('apply'.translate(context)),
          ),
        ],
      ),
    );
  }

  void _addBadgeLayer(String badgeText) {
    final id = 'badge_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _badgeLayers.add(
        BadgeLayer(
          id: id,
          text: badgeText,
          offset: Offset(20.0 + (_badgeLayers.length * 10), 20.0 + (_badgeLayers.length * 10)),
        ),
      );
      _selectedLayerId = id;
    });
  }

  Size _measureTextLayer(TextLayer layer) {
    final tp = TextPainter(
      text: TextSpan(
        text: layer.text,
        style: TextStyle(
          fontSize: layer.fontSize,
          fontWeight: layer.isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: Directionality.of(context),
    )..layout();
    return Size(tp.width + 24, tp.height + 12);
  }

  void _resizeTextLayer(
    TextLayer layer,
    double deltaFontSize, {
    required Offset anchorRatio,
  }) {
    final oldSize = _measureTextLayer(layer);
    final oldFontSize = layer.fontSize;
    final newFontSize = (oldFontSize + deltaFontSize).clamp(12.0, 72.0);
    if (newFontSize == oldFontSize) return;

    setState(() {
      layer.fontSize = newFontSize;
      final newSize = _measureTextLayer(layer);

      final deltaW = newSize.width - oldSize.width;
      final deltaH = newSize.height - oldSize.height;

      final shiftX = -deltaW * anchorRatio.dx;
      final shiftY = -deltaH * anchorRatio.dy;

      layer.offset += Offset(shiftX, shiftY);
    });
  }

  Future<void> _executeCrop() async {
    if (_cropRect == null || _cropRect!.width < 10 || _cropRect!.height < 10) return;
    setState(() {
      _isCroppingAction = true;
      _selectedLayerId = null;
    });

    try {
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final fullImage = await boundary.toImage(pixelRatio: 2.0);
      final canvasSize = boundary.paintBounds.size;
      final scale = fullImage.width / canvasSize.width;

      final srcX = (_cropRect!.left * scale).clamp(0.0, fullImage.width.toDouble());
      final srcY = (_cropRect!.top * scale).clamp(0.0, fullImage.height.toDouble());
      final srcW = (_cropRect!.width * scale).clamp(1.0, fullImage.width - srcX);
      final srcH = (_cropRect!.height * scale).clamp(1.0, fullImage.height - srcY);

      final srcRect = Rect.fromLTWH(srcX, srcY, srcW, srcH);
      final dstRect = Rect.fromLTWH(0, 0, srcW, srcH);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, dstRect);
      canvas.drawImageRect(fullImage, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);

      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(srcW.round(), srcH.round());
      final byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final newFilePath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final newFile = File(newFilePath);
      await newFile.writeAsBytes(bytes);

      setState(() {
        _activeImageFile = newFile;
        _cropRect = null;
        _rotationQuarterTurns = 0;
        _flipHorizontal = false;
        _flipVertical = false;
        _textLayers.clear();
        _badgeLayers.clear();
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      });
      _resolveImageDimensions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('imageSavedSuccessfully'.translate(context)),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCroppingAction = false);
      }
    }
  }

  void _handleCropResizeNW(Offset delta, BoxConstraints constraints) {
    if (_cropRect == null) return;
    setState(() {
      final anchorX = _cropRect!.right;
      final anchorY = _cropRect!.bottom;
      double newW = (anchorX - (_cropRect!.left + delta.dx)).clamp(40.0, anchorX);
      double newH;
      if (_aspectRatio != null) {
        newH = newW / _aspectRatio!;
        if (newH > anchorY) {
          newH = anchorY;
          newW = newH * _aspectRatio!;
        }
      } else {
        newH = (anchorY - (_cropRect!.top + delta.dy)).clamp(40.0, anchorY);
      }
      _cropRect = Rect.fromLTRB(anchorX - newW, anchorY - newH, anchorX, anchorY);
    });
  }

  void _handleCropResizeNE(Offset delta, BoxConstraints constraints) {
    if (_cropRect == null) return;
    setState(() {
      final anchorX = _cropRect!.left;
      final anchorY = _cropRect!.bottom;
      double newW = (_cropRect!.width + delta.dx).clamp(40.0, constraints.maxWidth - anchorX);
      double newH;
      if (_aspectRatio != null) {
        newH = newW / _aspectRatio!;
        if (newH > anchorY) {
          newH = anchorY;
          newW = newH * _aspectRatio!;
        }
      } else {
        newH = (anchorY - (_cropRect!.top + delta.dy)).clamp(40.0, anchorY);
      }
      _cropRect = Rect.fromLTRB(anchorX, anchorY - newH, anchorX + newW, anchorY);
    });
  }

  void _handleCropResizeSW(Offset delta, BoxConstraints constraints) {
    if (_cropRect == null) return;
    setState(() {
      final anchorX = _cropRect!.right;
      final anchorY = _cropRect!.top;
      double newW = (anchorX - (_cropRect!.left + delta.dx)).clamp(40.0, anchorX);
      double newH;
      if (_aspectRatio != null) {
        newH = newW / _aspectRatio!;
        if (newH > constraints.maxHeight - anchorY) {
          newH = constraints.maxHeight - anchorY;
          newW = newH * _aspectRatio!;
        }
      } else {
        newH = (_cropRect!.height + delta.dy).clamp(40.0, constraints.maxHeight - anchorY);
      }
      _cropRect = Rect.fromLTRB(anchorX - newW, anchorY, anchorX, anchorY + newH);
    });
  }

  void _handleCropResizeSE(Offset delta, BoxConstraints constraints) {
    if (_cropRect == null) return;
    setState(() {
      final anchorX = _cropRect!.left;
      final anchorY = _cropRect!.top;
      double newW = (_cropRect!.width + delta.dx).clamp(40.0, constraints.maxWidth - anchorX);
      double newH;
      if (_aspectRatio != null) {
        newH = newW / _aspectRatio!;
        if (newH > constraints.maxHeight - anchorY) {
          newH = constraints.maxHeight - anchorY;
          newW = newH * _aspectRatio!;
        }
      } else {
        newH = (_cropRect!.height + delta.dy).clamp(40.0, constraints.maxHeight - anchorY);
      }
      _cropRect = Rect.fromLTWH(anchorX, anchorY, newW, newH);
    });
  }

  Widget _buildCropCornerHandle({required void Function(Offset delta) onPan}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => onPan(details.delta),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: context.colorScheme.primary, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBase() {
    if (_activeImageFile != null) {
      return Image.file(
        _activeImageFile!,
        key: ValueKey(_activeImageFile!.path),
        fit: BoxFit.contain,
      );
    }
    final path = widget.imageResource.filePath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'imageEditor'.translate(context),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'reset'.translate(context),
            onPressed: _resetAll,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Center(
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _saveAndReturn,
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'saveChanges'.translate(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center Canvas Viewport
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_selectedLayerId != null) {
                    setState(() => _selectedLayerId = null);
                  }
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          aspectRatio: _effectiveAspectRatio,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Transformed & Filtered Image
                                  RotatedBox(
                                    quarterTurns: _rotationQuarterTurns,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..scaleByDouble(
                                          _flipHorizontal ? -1.0 : 1.0,
                                          _flipVertical ? -1.0 : 1.0,
                                          1.0,
                                          1.0,
                                        ),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.matrix(_buildColorMatrix()),
                                        child: _buildImageBase(),
                                      ),
                                    ),
                                  ),

                                  // Badges
                                  for (final badge in _badgeLayers)
                                    Positioned(
                                      left: badge.offset.dx,
                                      top: badge.offset.dy,
                                      child: GestureDetector(
                                        onPanUpdate: (details) {
                                          setState(() {
                                            badge.offset += details.delta;
                                            _selectedLayerId = badge.id;
                                          });
                                        },
                                        onTap: () {
                                          setState(() => _selectedLayerId = badge.id);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: badge.backgroundColor,
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black38,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            border: _selectedLayerId == badge.id
                                                ? Border.all(color: Colors.white, width: 2)
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                badge.text,
                                                style: TextStyle(
                                                  color: badge.textColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                              if (_selectedLayerId == badge.id) ...[
                                                const SizedBox(width: 6),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _badgeLayers.removeWhere((b) => b.id == badge.id);
                                                      _selectedLayerId = null;
                                                    });
                                                  },
                                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Text Layers with 8-Handle Resizing
                                  for (final textLayer in _textLayers)
                                    Positioned(
                                      left: textLayer.offset.dx,
                                      top: textLayer.offset.dy,
                                      child: _buildResizableTextWidget(textLayer),
                                    ),

                                  // Interactive Crop Selection Box Overlay
                                  if (_currentTab == EditorTab.crop && !_isCroppingAction) ...[
                                    Builder(
                                      builder: (ctx) {
                                        if (_cropRect == null) {
                                          final W = constraints.maxWidth;
                                          final H = constraints.maxHeight;
                                          double w = W * 0.85;
                                          double h = H * 0.85;
                                          if (_aspectRatio != null) {
                                            h = w / _aspectRatio!;
                                            if (h > H * 0.85) {
                                              h = H * 0.85;
                                              w = h * _aspectRatio!;
                                            }
                                          }
                                          _cropRect = Rect.fromLTWH((W - w) / 2, (H - h) / 2, w, h);
                                        }
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            CustomPaint(
                                              size: Size(constraints.maxWidth, constraints.maxHeight),
                                              painter: CropOverlayPainter(
                                                cropRect: _cropRect!,
                                                canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
                                                primaryColor: context.colorScheme.primary,
                                              ),
                                            ),
                                            // Draggable inside area
                                            Positioned(
                                              left: _cropRect!.left,
                                              top: _cropRect!.top,
                                              width: _cropRect!.width,
                                              height: _cropRect!.height,
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onPanUpdate: (details) {
                                                  setState(() {
                                                    final maxL = constraints.maxWidth - _cropRect!.width;
                                                    final maxT = constraints.maxHeight - _cropRect!.height;
                                                    final newL = (_cropRect!.left + details.delta.dx).clamp(0.0, maxL > 0 ? maxL : 0.0);
                                                    final newT = (_cropRect!.top + details.delta.dy).clamp(0.0, maxT > 0 ? maxT : 0.0);
                                                    _cropRect = Rect.fromLTWH(newL, newT, _cropRect!.width, _cropRect!.height);
                                                  });
                                                },
                                              ),
                                            ),
                                            // 4 Corner Handles
                                            Positioned(
                                              left: _cropRect!.left - 18,
                                              top: _cropRect!.top - 18,
                                              child: _buildCropCornerHandle(
                                                onPan: (delta) => _handleCropResizeNW(delta, constraints),
                                              ),
                                            ),
                                            Positioned(
                                              left: _cropRect!.right - 18,
                                              top: _cropRect!.top - 18,
                                              child: _buildCropCornerHandle(
                                                onPan: (delta) => _handleCropResizeNE(delta, constraints),
                                              ),
                                            ),
                                            Positioned(
                                              left: _cropRect!.left - 18,
                                              top: _cropRect!.bottom - 18,
                                              child: _buildCropCornerHandle(
                                                onPan: (delta) => _handleCropResizeSW(delta, constraints),
                                              ),
                                            ),
                                            Positioned(
                                              left: _cropRect!.right - 18,
                                              top: _cropRect!.bottom - 18,
                                              child: _buildCropCornerHandle(
                                                onPan: (delta) => _handleCropResizeSE(delta, constraints),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Controls Panel
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tab content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _buildTabContent(),
                  ),

                  const Divider(height: 1),

                  // Bottom Tab Navigation Bar
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(child: _buildTabButton(EditorTab.crop, AppIcons.crop, 'crop'.translate(context))),
                        Expanded(child: _buildTabButton(EditorTab.rotate, AppIcons.arrowClockwise, 'rotate'.translate(context))),
                        Expanded(child: _buildTabButton(EditorTab.filters, AppIcons.sliders, 'filter'.translate(context))),
                        Expanded(child: _buildTabButton(EditorTab.text, AppIcons.article, 'addText'.translate(context))),
                        Expanded(child: _buildTabButton(EditorTab.badges, AppIcons.tag, 'badges'.translate(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizableTextWidget(TextLayer layer) {
    final isSelected = _selectedLayerId == layer.id;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Text Box Container with Move GestureDetector
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _selectedLayerId = layer.id),
          onPanUpdate: (details) {
            setState(() {
              layer.offset += details.delta;
              _selectedLayerId = layer.id;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: layer.backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(color: context.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Text(
              layer.text,
              style: TextStyle(
                color: layer.color,
                fontSize: layer.fontSize,
                fontWeight: layer.isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),

        // 8-Handle Resizing Controls (NW, N, NE, E, SE, S, SW, W)
        if (isSelected) ...[
          // Top Left (NW) - Anchor is Bottom-Right (1.0, 1.0)
          Positioned(
            left: -16,
            top: -16,
            child: _buildHandle(
              onPan: (delta) {
                _resizeTextLayer(
                  layer,
                  -(delta.dx + delta.dy) * 0.3,
                  anchorRatio: const Offset(1.0, 1.0),
                );
              },
            ),
          ),
          // Top Center (N) - Anchor is Bottom-Center (0.5, 1.0)
          Positioned(
            left: 0,
            right: 0,
            top: -16,
            child: Center(
              child: _buildHandle(
                onPan: (delta) {
                  _resizeTextLayer(
                    layer,
                    -delta.dy * 0.3,
                    anchorRatio: const Offset(0.5, 1.0),
                  );
                },
              ),
            ),
          ),
          // Top Right (NE) - Anchor is Bottom-Left (0.0, 1.0)
          Positioned(
            right: -16,
            top: -16,
            child: _buildHandle(
              onPan: (delta) {
                _resizeTextLayer(
                  layer,
                  (delta.dx - delta.dy) * 0.3,
                  anchorRatio: const Offset(0.0, 1.0),
                );
              },
            ),
          ),
          // Right (E) - Anchor is Left-Center (0.0, 0.5)
          Positioned(
            right: -16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildHandle(
                onPan: (delta) {
                  _resizeTextLayer(
                    layer,
                    delta.dx * 0.3,
                    anchorRatio: const Offset(0.0, 0.5),
                  );
                },
              ),
            ),
          ),
          // Bottom Right (SE) - Anchor is Top-Left (0.0, 0.0)
          Positioned(
            right: -16,
            bottom: -16,
            child: _buildHandle(
              onPan: (delta) {
                _resizeTextLayer(
                  layer,
                  (delta.dx + delta.dy) * 0.3,
                  anchorRatio: const Offset(0.0, 0.0),
                );
              },
            ),
          ),
          // Bottom Center (S) - Anchor is Top-Center (0.5, 0.0)
          Positioned(
            left: 0,
            right: 0,
            bottom: -16,
            child: Center(
              child: _buildHandle(
                onPan: (delta) {
                  _resizeTextLayer(
                    layer,
                    delta.dy * 0.3,
                    anchorRatio: const Offset(0.5, 0.0),
                  );
                },
              ),
            ),
          ),
          // Bottom Left (SW) - Anchor is Top-Right (1.0, 0.0)
          Positioned(
            left: -16,
            bottom: -16,
            child: _buildHandle(
              onPan: (delta) {
                _resizeTextLayer(
                  layer,
                  (-delta.dx + delta.dy) * 0.3,
                  anchorRatio: const Offset(1.0, 0.0),
                );
              },
            ),
          ),
          // Left (W) - Anchor is Right-Center (1.0, 0.5)
          Positioned(
            left: -16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildHandle(
                onPan: (delta) {
                  _resizeTextLayer(
                    layer,
                    -delta.dx * 0.3,
                    anchorRatio: const Offset(1.0, 0.5),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHandle({required void Function(Offset delta) onPan}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => onPan(details.delta),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: context.colorScheme.primary, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(EditorTab tab, IconData icon, String label) {
    final isSelected = _currentTab == tab;
    final color = isSelected ? context.colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _currentTab = tab),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case EditorTab.crop:
        return _buildCropTab();
      case EditorTab.rotate:
        return _buildRotateTab();
      case EditorTab.filters:
        return _buildFiltersTab();
      case EditorTab.text:
        return _buildTextTab();
      case EditorTab.badges:
        return _buildBadgesTab();
    }
  }

  Widget _buildCropTab() {
    final ratios = [
      (null, 'aspectRatioFree'.translate(context)),
      (1.0, 'aspectRatioSquare'.translate(context)),
      (4 / 3, 'aspectRatioStandard'.translate(context)),
      (16 / 9, 'aspectRatioLandscape'.translate(context)),
      (9 / 16, 'aspectRatioStory'.translate(context)),
      (3 / 2, 'aspectRatioClassic'.translate(context)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ratios.map((item) {
              final isSelected = _aspectRatio == item.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item.$2),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _aspectRatio = item.$1;
                      _cropRect = null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _executeCrop,
                icon: const Icon(Icons.check, size: 18),
                label: Text('applyCrop'.translate(context)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _cropRect = null;
                  _aspectRatio = null;
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('resetCrop'.translate(context)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRotateTab() {
    return Row(
      children: [
        Expanded(
          child: _buildRotateButton(
            icon: AppIcons.arrowCounterClockwise,
            label: '-90°',
            onPressed: () {
              setState(() {
                _rotationQuarterTurns = (_rotationQuarterTurns + 3) % 4;
                _cropRect = null;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRotateButton(
            icon: AppIcons.arrowClockwise,
            label: '+90°',
            onPressed: () {
              setState(() {
                _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
                _cropRect = null;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRotateButton(
            icon: AppIcons.arrowsHorizontal,
            label: 'Flip H',
            isActive: _flipHorizontal,
            onPressed: () {
              setState(() => _flipHorizontal = !_flipHorizontal);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRotateButton(
            icon: AppIcons.arrowsVertical,
            label: 'Flip V',
            isActive: _flipVertical,
            onPressed: () {
              setState(() => _flipVertical = !_flipVertical);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRotateButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        backgroundColor: isActive ? primary.withValues(alpha: 0.12) : null,
        side: BorderSide(
          color: isActive ? primary : theme.dividerColor,
          width: isActive ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? primary : null),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersTab() {
    final filterNames = ['Original', 'Vivid', 'Warm', 'Cool', 'Mono', 'Vintage', 'Dramatic'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: filterNames.map((name) {
              final isSelected = _selectedFilter == name;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => _applyFilter(name),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                'brightness'.translate(context),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Slider(
                value: _brightness,
                min: -0.5,
                max: 0.5,
                onChanged: (v) => setState(() => _brightness = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                'contrast'.translate(context),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Slider(
                value: _contrast,
                min: 0.5,
                max: 1.5,
                onChanged: (v) => setState(() => _contrast = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextTab() {
    final selectedLayer = _textLayers.firstWhere(
      (l) => l.id == _selectedLayerId,
      orElse: () => TextLayer(id: '', text: ''),
    );
    final hasSelection = selectedLayer.id.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: FilledButton.icon(
                onPressed: _addTextLayer,
                icon: const Icon(Icons.add, size: 18),
                label: Text('addText'.translate(context), overflow: TextOverflow.ellipsis),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),
            if (hasSelection)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Layer',
                onPressed: () {
                  setState(() {
                    _textLayers.removeWhere((l) => l.id == selectedLayer.id);
                    _selectedLayerId = null;
                  });
                },
              ),
          ],
        ),
        if (hasSelection) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  'fontSize'.translate(context),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Slider(
                  value: selectedLayer.fontSize,
                  min: 12.0,
                  max: 72.0,
                  onChanged: (v) => setState(() => selectedLayer.fontSize = v),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: selectedLayer.isBold ? context.colorScheme.primary : Colors.grey,
                ),
                onPressed: () => setState(() => selectedLayer.isBold = !selectedLayer.isBold),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('textColor'.translate(context), style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                ..._swatchColors.map((c) => GestureDetector(
                      onTap: () => setState(() => selectedLayer.color = c),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedLayer.color == c ? Colors.blue : Colors.grey,
                            width: selectedLayer.color == c ? 2 : 1,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('bgColor'.translate(context), style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                ..._bgSwatchColors.map((c) => GestureDetector(
                      onTap: () => setState(() => selectedLayer.backgroundColor = c),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c ?? Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedLayer.backgroundColor == c ? Colors.blue : Colors.grey,
                            width: selectedLayer.backgroundColor == c ? 2 : 1,
                          ),
                        ),
                        child: c == null ? const Icon(Icons.block, size: 14, color: Colors.grey) : null,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadgesTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _presetBadges.map((badgeText) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.local_offer, size: 16),
              label: Text(badgeText, style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _addBadgeLayer(badgeText),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  CropOverlayPainter({
    required this.cropRect,
    required this.canvasSize,
    required this.primaryColor,
  });

  final Rect cropRect;
  final Size canvasSize;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark mask outside crop rect
    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    final cropPath = Path()..addRect(cropRect);
    final maskPath = Path.combine(PathOperation.difference, bgPath, cropPath);

    final maskPaint = Paint()..color = const Color(0x99000000);
    canvas.drawPath(maskPath, maskPaint);

    // 2. White border around crop rect
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(cropRect, borderPaint);

    // 3. Rule-of-thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;

    // Vertical grid lines
    canvas.drawLine(
      Offset(cropRect.left + thirdW, cropRect.top),
      Offset(cropRect.left + thirdW, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + thirdW * 2, cropRect.top),
      Offset(cropRect.left + thirdW * 2, cropRect.bottom),
      gridPaint,
    );

    // Horizontal grid lines
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdH),
      Offset(cropRect.right, cropRect.top + thirdH),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdH * 2),
      Offset(cropRect.right, cropRect.top + thirdH * 2),
      gridPaint,
    );

    // 4. Accent corner brackets
    final cornerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const cornerLen = 16.0;

    // Top-Left
    canvas.drawLine(cropRect.topLeft, cropRect.topLeft + const Offset(cornerLen, 0), cornerPaint);
    canvas.drawLine(cropRect.topLeft, cropRect.topLeft + const Offset(0, cornerLen), cornerPaint);

    // Top-Right
    canvas.drawLine(cropRect.topRight, cropRect.topRight + const Offset(-cornerLen, 0), cornerPaint);
    canvas.drawLine(cropRect.topRight, cropRect.topRight + const Offset(0, cornerLen), cornerPaint);

    // Bottom-Left
    canvas.drawLine(cropRect.bottomLeft, cropRect.bottomLeft + const Offset(cornerLen, 0), cornerPaint);
    canvas.drawLine(cropRect.bottomLeft, cropRect.bottomLeft + const Offset(0, -cornerLen), cornerPaint);

    // Bottom-Right
    canvas.drawLine(cropRect.bottomRight, cropRect.bottomRight + const Offset(-cornerLen, 0), cornerPaint);
    canvas.drawLine(cropRect.bottomRight, cropRect.bottomRight + const Offset(0, -cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.canvasSize != canvasSize ||
        oldDelegate.primaryColor != primaryColor;
  }
}
