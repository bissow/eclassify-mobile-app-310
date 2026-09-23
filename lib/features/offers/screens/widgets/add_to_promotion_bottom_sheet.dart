import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/offers/cubits/seller_ad_promote_cubit.dart';
import 'package:eClassify/features/offers/models/promotion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddToPromotionBottomSheet extends StatefulWidget {
  const AddToPromotionBottomSheet({
    required this.itemId,
    required this.originalPrice,
    super.key,
  });

  final int itemId;
  final double originalPrice;

  static Future<void> show(
    BuildContext context, {
    required int itemId,
    required double originalPrice,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => SellerAdPromoteCubit()..fetchAvailablePromotions(itemId: itemId),
        child: AddToPromotionBottomSheet(
          itemId: itemId,
          originalPrice: originalPrice,
        ),
      ),
    );
  }

  @override
  State<AddToPromotionBottomSheet> createState() => _AddToPromotionBottomSheetState();
}

class _AddToPromotionBottomSheetState extends State<AddToPromotionBottomSheet> {
  int? _selectedPromoId;
  String _discountType = 'percentage';
  double _discountValue = 10.0;
  int _stockQuantity = 5;

  final TextEditingController _discountController = TextEditingController(text: '10');
  final TextEditingController _stockController = TextEditingController(text: '5');

  @override
  void dispose() {
    _discountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  double get _calculatedPromoPrice {
    if (_discountType == 'percentage') {
      final markdown = (widget.originalPrice * _discountValue) / 100;
      return (widget.originalPrice - markdown).clamp(0.0, widget.originalPrice);
    }
    return (widget.originalPrice - _discountValue).clamp(0.0, widget.originalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerAdPromoteCubit, SellerAdPromoteState>(
      listener: (context, state) {
        if (state is SellerAdPromoteActionSuccess) {
          HelperUtils.showSnackBarMessage(context, state.message);
          Navigator.of(context).pop();
        } else if (state is SellerAdPromoteFailure) {
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final bool isAlreadySubmitted = (state is SellerAvailablePromotionsSuccess) &&
            state.alreadySubmittedPromotionIds.contains(_selectedPromoId);

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(AppIcons.fireFill, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'joinSalePromotion'.translate(context),
                    style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'joinSalePromotionSubtitle'.translate(context),
                style: context.bodyMedium.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),

              if (state is SellerAdPromoteLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: LoadingIndicator()))
              else if (state is SellerAvailablePromotionsSuccess) ...[
                if (state.requiresVerification)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final bool isUnderReview = state.verificationStatus == 'pending' || state.verificationStatus == 'resubmitted';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isUnderReview ? Icons.schedule_rounded : Icons.verified_user_outlined,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isUnderReview
                                            ? 'verificationUnderReviewTitle'.translate(context)
                                            : 'verificationRequiredTitle'.translate(context),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  state.eligibilityMsg ??
                                      (isUnderReview
                                          ? 'verificationUnderReviewNotice'.translate(context)
                                          : 'verificationRequiredDesc'.translate(context)),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AppButton(
                                  variant: AppButtonVariant.filled,
                                  size: AppButtonSize.compact,
                                  title: isUnderReview
                                      ? 'checkVerificationStatus'.translate(context)
                                      : 'verifyNow'.translate(context),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushNamed(Routes.verification);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else if (state.requiresPackage)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.card_membership_outlined, color: context.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'packageRequiredTitle'.translate(context),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.eligibilityMsg ?? 'packageRequiredDesc'.translate(context),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          variant: AppButtonVariant.filled,
                          size: AppButtonSize.compact,
                          title: 'subscribePackage'.translate(context),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed(Routes.subscriptionPackageScreen);
                          },
                        ),
                      ],
                    ),
                  ),
                _buildForm(context, state.promotions, state.alreadySubmittedPromotionIds),
              ] else
                const SizedBox.shrink(),

              const SizedBox(height: 24),
              AppButton(
                variant: AppButtonVariant.filled,
                onPressed: (state is! SellerAvailablePromotionsSuccess ||
                        state.requiresVerification ||
                        (state.requiresPackage && !isAlreadySubmitted) ||
                        state.promotions.isEmpty)
                    ? null
                    : () {
                        if (_selectedPromoId == null) {
                          HelperUtils.showSnackBarMessage(context, 'pleaseSelectPromotion'.translate(context));
                          return;
                        }
                        context.read<SellerAdPromoteCubit>().joinPromotion(
                          promotionId: _selectedPromoId!,
                          itemId: widget.itemId,
                          discountType: _discountType,
                          discountValue: _discountValue,
                          stockQuantity: _stockQuantity,
                          replace: isAlreadySubmitted,
                        );
                      },
                title: isAlreadySubmitted
                    ? 'replacePromotionOffer'.translate(context)
                    : 'submitToPromotion'.translate(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildForm(BuildContext context, List<PromotionModel> promotions, [List<int> alreadySubmittedIds = const []]) {
    if (promotions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('noActivePromotions'.translate(context)),
        ),
      );
    }

    _selectedPromoId ??= promotions.first.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (alreadySubmittedIds.contains(_selectedPromoId)) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'adAlreadySubmittedNotice'.translate(context),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Promotion Selector Dropdown
        Text('selectEvent'.translate(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedPromoId,
              items: promotions.map((p) {
                return DropdownMenuItem<int>(
                  value: p.id,
                  child: Text(
                    '${p.title} (${p.promotionType.replaceAll('_', ' ').toUpperCase()})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPromoId = val;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Price Preview Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Original Price', style: TextStyle(fontSize: 11, color: context.colorScheme.onSurface.withValues(alpha: 0.6))),
                  Text('\$${widget.originalPrice}', style: const TextStyle(decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sale Promotional Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
                  Text(
                    '\$${_calculatedPromoPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Discount Type & Value Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discount (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixText: '%',
                    ),
                    onChanged: (val) {
                      setState(() {
                        _discountValue = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stock on Sale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixText: 'units',
                    ),
                    onChanged: (val) {
                      setState(() {
                        _stockQuantity = int.tryParse(val) ?? 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
