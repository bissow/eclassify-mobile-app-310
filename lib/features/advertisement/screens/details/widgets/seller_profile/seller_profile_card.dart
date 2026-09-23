import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/share_utility.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/seller_profile/verified_badge.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/seller/models/seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerProfileCard extends StatefulWidget {
  const SellerProfileCard({
    required this.seller,
    required this.contact,
    required this.itemName,
    required this.itemSlug,
    super.key,
  });

  final String? itemName;
  final String? itemSlug;
  final Seller? seller;
  final Contact? contact;

  @override
  State<SellerProfileCard> createState() => _SellerProfileCardState();
}

class _SellerProfileCardState extends State<SellerProfileCard> {
  late String? formattedNumber;
  late String phoneCode;

  @override
  void initState() {
    super.initState();
    _processContact();
  }

  @override
  void didUpdateWidget(covariant SellerProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _processContact();
  }

  void _processContact() {
    if (widget.contact != null && !widget.contact!.isEmpty) {
      final contact = widget.contact!;
      phoneCode = contact.callingCode.isNotEmpty
          ? contact.callingCode
          : HelperUtils.getPhoneCodeFromRegionCode(contact.regionCode) ??
                AppConfig.defaultPhoneCode;
      formattedNumber = HelperUtils.getFormattedNumber(contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsetsDirectional.fromSTEB(
      Constant.horizontalPadding,
      0,
      Constant.horizontalPadding,
      8,
    );

    if (widget.seller == null) {
      return Padding(
        padding: padding,
        child: CustomShimmer(
          width: double.maxFinite,
          height: 100,
          borderRadius: 16,
        ),
      );
    }

    final seller = widget.seller;

    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.sellerProfileScreen,
            arguments: {
              'seller_id': seller.id,
              'review_cubit': context.read<SellerReviewsCubit>(),
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CustomImage(
                src: seller?.profile,
                size: Size.square(70),
                radius: 16,
                fit: BoxFit.cover,
                errorImage: UserPlaceholderImage(
                  size: Size.square(70),
                  radius: 16,
                  placeholder: seller?.placeholder,
                ),
              ),
              10.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (seller?.isVerified ?? false) VerifiedBadge(),
                    Text(
                      seller?.name ?? 'Anonymous User',
                      style: context.bodyLarge,
                    ),
                    if (seller != null)
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(AppIcons.starFill, size: 16),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: seller.averageRating.toStringAsFixed(1),
                                  style: context.labelLarge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10, child: VerticalDivider()),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: seller.reviewsCount.compact,
                                  style: context.labelLarge.withColor(
                                    context.mutedColor,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: 'ratings'.translate(context),
                                  style: context.labelLarge.withColor(
                                    context.mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (seller!.email.isNotNullAndNotEmpty &&
                        seller.showPersonalDetails)
                      Text(
                        seller.email,
                        style: context.labelSmall.withColor(context.mutedColor),
                      ),
                  ],
                ),
              ),
              if (widget.contact != null &&
                  !widget.contact!.isEmpty &&
                  AppSession.isAuthenticated) ...[
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: .05,
                        ),
                      ),
                    ),
                    fixedSize: const Size(40, 40),
                    iconSize: 24,
                  ),
                  onPressed: _showContactBottomSheet,
                  icon: CustomImage(
                    src: AppAssets.profile.contactUs,
                    size: const Size.square(24),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    final uri = Uri.parse(
                      'tel:${_normalizePhoneNumber(widget.contact!.number, phoneCode)}',
                    );
                    launchUrl(uri);
                  },
                  leading: Icon(
                    AppIcons.phone,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(formattedNumber!),
                ),
                ListTile(
                  onTap: () {
                    final uri = Uri.parse(
                      'sms:${_normalizePhoneNumber(widget.contact!.number, phoneCode)}',
                    );
                    launchUrl(uri);
                  },
                  leading: Icon(
                    AppIcons.chatDots,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(formattedNumber!),
                ),
                ListTile(
                  onTap: () {
                    final whatsappLink = _generateWhatsappLink(
                      _normalizePhoneNumber(widget.contact!.number, phoneCode),
                    );
                    launchUrl(whatsappLink);
                  },
                  leading: CustomImage(
                    src: AppAssets.social.whatsapp,
                    size: Size.square(24),
                  ),
                  title: Text(formattedNumber!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _normalizePhoneNumber(String mobile, String phoneCode) =>
      HelperUtils.normalizeNumber('$phoneCode$mobile');

  Uri _generateWhatsappLink(String normalizedNumber) {
    final message =
        'Hi! I saw your advertisement for ${widget.itemName} on ${AppConfig.applicationName} '
        'and I’m interested in buying it. Is it still available?'
        '${ItemDeepLink(widget.itemSlug!).shareUrl}';

    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse(
      'https://wa.me/$normalizedNumber?text=$encodedMessage',
    );
    return uri;
  }
}
