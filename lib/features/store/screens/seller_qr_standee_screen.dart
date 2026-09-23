import 'dart:convert';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/store/cubits/seller_qr_standee_cubit.dart';
import 'package:eClassify/features/store/models/seller_qr_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerQrStandeeScreen extends StatefulWidget {
  const SellerQrStandeeScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => SellerQrStandeeCubit()..loadStandeeData(),
        child: const SellerQrStandeeScreen(),
      ),
    );
  }

  @override
  State<SellerQrStandeeScreen> createState() => _SellerQrStandeeScreenState();
}

class _SellerQrStandeeScreenState extends State<SellerQrStandeeScreen> {
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  String _selectedColor = '#0b57d0';
  String _selectedSize = 'standee';
  String _selectedFormat = 'pdf';
  bool _initialized = false;

  final List<({String label, String hex})> _colorPresets = const [
    (label: 'Blue', hex: '#0b57d0'),
    (label: 'Teal', hex: '#0f766e'),
    (label: 'Purple', hex: '#6b21a8'),
    (label: 'Red', hex: '#b91c1c'),
    (label: 'Navy', hex: '#1e293b'),
    (label: 'Gold', hex: '#b45309'),
  ];

  @override
  void dispose() {
    _slugController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  void _initFields(SellerQrCodeModel? qr) {
    if (_initialized || qr == null) return;
    _initialized = true;
    if (qr.customSlug != null && qr.customSlug!.isNotEmpty) {
      _slugController.text = qr.customSlug!;
    } else if (qr.token != null) {
      _slugController.text = qr.token!;
    }
    if (qr.customTagline != null) {
      _taglineController.text = qr.customTagline!;
    }
    if (qr.customColor != null) {
      _selectedColor = qr.customColor!;
    }
    if (qr.size != null) {
      _selectedSize = qr.size!;
    }
    if (qr.format != null) {
      _selectedFormat = qr.format!;
    }
  }

  Color _parseHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF0B57D0);
    }
  }

  Future<void> _handleSave() async {
    final success = await context.read<SellerQrStandeeCubit>().updateStandee(
          customSlug: _slugController.text.trim().toLowerCase(),
          customTagline: _taglineController.text.trim(),
          customColor: _selectedColor,
          size: _selectedSize,
          format: _selectedFormat,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Standee configuration updated successfully!'
                : 'Failed to update standee.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadStandee(String? token) async {
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please save standee first to generate your QR code.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    final downloadUrl =
        '${Api.baseUrl}${ApiEndpoints.sellerQrDownload}?token=$token&format=$_selectedFormat&size=$_selectedSize';
    final uri = Uri.parse(downloadUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initiate standee download: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Store QR Standee'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.shareNetwork),
            tooltip: 'Share QR Link',
            onPressed: () {
              final state = context.read<SellerQrStandeeCubit>().state;
              if (state is SellerQrStandeeLoaded && state.qrCode != null) {
                final url = state.qrCode!.qrUrl ?? '';
                SharePlus.instance.share(
                  ShareParams(
                    text: 'Visit our digital catalog on Bissow: $url',
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<SellerQrStandeeCubit, SellerQrStandeeState>(
        builder: (context, state) {
          if (state is SellerQrStandeeLoaded || state is SellerQrStandeeUpdating) {
            final eligibility = state is SellerQrStandeeLoaded
                ? state.eligibility
                : (state as SellerQrStandeeUpdating).eligibility;
            final qrCode = state is SellerQrStandeeLoaded
                ? state.qrCode
                : (state as SellerQrStandeeUpdating).currentQrCode;

            if (!eligibility.hasStore || !eligibility.isEligible) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: context.colorScheme.surfaceContainerHigh,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadStandee(qrCode?.token ?? qrCode?.qrCodeToken),
                        icon: const Icon(AppIcons.downloadSimple),
                        label: Text('Download ${_selectedFormat.toUpperCase()}'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            state is SellerQrStandeeUpdating ? null : _handleSave,
                        icon: state is SellerQrStandeeUpdating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Save Standee'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<SellerQrStandeeCubit, SellerQrStandeeState>(
          listener: (context, state) {
            if (state is SellerQrStandeeLoaded) {
              _initFields(state.qrCode);
            }
          },
          builder: (context, state) {
            if (state is SellerQrStandeeLoading) {
              return const Center(child: LoadingIndicator());
            }

            if (state is SellerQrStandeeLoaded || state is SellerQrStandeeUpdating) {
              final eligibility = state is SellerQrStandeeLoaded
                  ? state.eligibility
                  : (state as SellerQrStandeeUpdating).eligibility;
              final qrCode = state is SellerQrStandeeLoaded
                  ? state.qrCode
                  : (state as SellerQrStandeeUpdating).currentQrCode;

              // Case 1: No store created yet
              if (!eligibility.hasStore) {
                return _buildNoStoreState(context);
              }

              // Case 2: Package does not include QR feature
              if (!eligibility.isEligible) {
                return _buildUpgradeRequiredState(context, eligibility.message);
              }

              final store = eligibility.store ?? qrCode?.store;
              final accentColor = _parseHex(_selectedColor);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Scans Counter
                    if (qrCode != null) _buildKpiRow(context, qrCode),
                    const SizedBox(height: 16),

                    // Standee Mockup Card
                    _buildStandeePreview(context, store, qrCode, accentColor),
                    const SizedBox(height: 24),

                    // Customization Controls
                    _buildCustomizerControls(context, isDark, qrCode),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, SellerQrCodeModel qr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorScheme.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Total Scans',
                  style: context.bodySmall.withColor(context.mutedColor)),
              const SizedBox(height: 4),
              Text(
                '${qr.scansCount}',
                style: context.bodyLarge.bold.copyWith(fontSize: 20),
              ),
            ],
          ),
          Container(
            height: 32,
            width: 1,
            color: context.colorScheme.surfaceContainerHigh,
          ),
          Column(
            children: [
              Text('Status',
                  style: context.bodySmall.withColor(context.mutedColor)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: qr.isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    qr.isActive ? 'Active' : 'Inactive',
                    style: context.bodyMedium.bold,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandeePreview(
    BuildContext context,
    dynamic store,
    SellerQrCodeModel? qrCode,
    Color accentColor,
  ) {
    final storeName = store?.name ?? 'Your Store';
    final storeLoc = [store?.city, store?.state]
        .where((s) => s != null && s.toString().isNotEmpty)
        .join(', ');

    return Center(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Column(
            children: [
              // Top Accent Strip
              Container(
                height: 8,
                width: double.infinity,
                color: accentColor,
              ),

              // Top Pill Badge
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  qrCode?.badgeText ?? 'DIGITAL STORE & CATALOG',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Standee Header Title
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: Text(
                  qrCode?.title?.isNotEmpty == true
                      ? qrCode!.title!
                      : (storeName.isNotEmpty ? storeName : 'Scan to Browse Store & Catalog'),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Tagline
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 16, right: 16, bottom: 8),
                child: Text(
                  _taglineController.text.isNotEmpty
                      ? _taglineController.text
                      : 'Explore all verified ads, items and exclusive offers',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
              ),

              // QR Box Wrapper
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor, width: 2.2),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: _buildQrCodeWidget(qrCode, accentColor),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SCAN TO VIEW ALL ADS & OFFERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Store Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: store?.logo != null && store.logo.toString().isNotEmpty
                            ? CustomImage(src: store.logo.toString(), fit: BoxFit.cover)
                            : Icon(AppIcons.storefront, color: accentColor, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  storeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('✓', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          if (storeLoc.isNotEmpty)
                            Text(
                              storeLoc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 9.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Standee Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      qrCode?.defaultFooterText ?? 'Powered by Bissow.com',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (qrCode?.footerLogoUrl != null && qrCode!.footerLogoUrl!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 14,
                        child: CustomImage(
                          src: qrCode.footerLogoUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCodeWidget(SellerQrCodeModel? qrCode, Color accentColor) {
    if (qrCode?.svgRaw != null && qrCode!.svgRaw!.trim().isNotEmpty) {
      String svg = qrCode.svgRaw!.trim();
      if (svg.startsWith('data:image/svg+xml;base64,')) {
        try {
          svg = utf8.decode(
            base64.decode(svg.substring('data:image/svg+xml;base64,'.length)),
          );
        } catch (_) {}
      }
      return SvgPicture.string(
        svg,
        width: 140,
        height: 140,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.qr_code_2,
          size: 110,
          color: accentColor,
        ),
      );
    }
    return Icon(
      Icons.qr_code_2,
      size: 110,
      color: accentColor,
    );
  }

  Widget _buildCustomizerControls(
    BuildContext context,
    bool isDark,
    SellerQrCodeModel? qrCode,
  ) {
    final canCustomizeColors = qrCode?.canCustomizeColors ?? true;
    final canCustomizeSlug = qrCode?.canCustomizeSlug ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Standee Studio',
            style: context.bodyLarge.bold,
          ),
          const SizedBox(height: 4),
          Text(
            'Personalize your shop counter acrylic standee flyer.',
            style: context.bodySmall.withColor(context.mutedColor),
          ),
          const SizedBox(height: 16),

          // Custom SEO URL Slug
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Store QR Slug (SEO URL)', style: context.bodyMedium.bold),
              if (!canCustomizeSlug)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Locked by Admin',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _slugController,
            enabled: canCustomizeSlug,
            onChanged: (_) => setState(() {}),
            maxLength: 64,
            decoration: InputDecoration(
              prefixText: '/store-qr/',
              prefixStyle: TextStyle(
                color: context.mutedColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              hintText: 'my-store-name',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Custom Tagline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Custom Tagline', style: context.bodyMedium.bold),
              if (!canCustomizeColors)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Managed by Admin',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _taglineController,
            enabled: canCustomizeColors,
            onChanged: (_) => setState(() {}),
            maxLength: 90,
            decoration: InputDecoration(
              hintText: 'e.g. Scan to check our fresh arrivals & deals!',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Accent Color
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Theme Accent Color', style: context.bodyMedium.bold),
              if (!canCustomizeColors)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Managed by Admin',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (canCustomizeColors)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _colorPresets.map((c) {
                  final isSelected = _selectedColor == c.hex;
                  final col = _parseHex(c.hex);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c.hex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? col.withValues(alpha: 0.15)
                            : context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? col
                              : context.colorScheme.surfaceContainerHigh,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: col,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Print Size
          Text('Print Size', style: context.bodyMedium.bold),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedSize,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'standee',
                child: Text('UPI Standee (148 x 210 mm)'),
              ),
              DropdownMenuItem(
                value: 'a4',
                child: Text('Standard A4 Poster'),
              ),
              DropdownMenuItem(
                value: 'a5',
                child: Text('Table Flyer (A5)'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedSize = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoStoreState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.storefront, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Store Profile Required', style: context.bodyLarge.bold),
            const SizedBox(height: 8),
            Text(
              'You need an active Store profile to generate your unique store QR code standee.',
              textAlign: TextAlign.center,
              style: context.bodyMedium.withColor(context.mutedColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.storeSetup),
              child: const Text('Set Up Your Store'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeRequiredState(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Subscription Upgrade Required', style: context.bodyLarge.bold),
            const SizedBox(height: 8),
            Text(
              message ??
                  'Your current subscription does not include the Seller QR Standee feature. Upgrade to a business plan to download printable QR counter standees.',
              textAlign: TextAlign.center,
              style: context.bodyMedium.withColor(context.mutedColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.subscriptionPackageScreen),
              child: const Text('View Subscription Plans'),
            ),
          ],
        ),
      ),
    );
  }
}
