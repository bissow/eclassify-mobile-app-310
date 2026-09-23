import 'package:eClassify/features/advertisement/cubits/buyer_list_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/features/advertisement/screens/select_buyer/sold_out_confirmation_dialog.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectBuyerScreen extends StatefulWidget {
  const SelectBuyerScreen({
    required this.preview,
    required this.isJobItem,
    super.key,
  });

  final ItemPreview preview;
  final bool isJobItem;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    final preview = args['preview'] as ItemPreview;
    final isJobItem = args['is_job_item'] as bool;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                BuyerListCubit(itemId: preview.id, isJobItem: isJobItem),
          ),
          BlocProvider(create: (_) => ItemStatusCubit()),
        ],
        child: SelectBuyerScreen(preview: preview, isJobItem: isJobItem),
      ),
    );
  }

  @override
  State<SelectBuyerScreen> createState() => _SelectBuyerScreenState();
}

class _SelectBuyerScreenState extends State<SelectBuyerScreen> {
  final ValueNotifier<int?> userId = ValueNotifier(null);

  @override
  void dispose() {
    userId.dispose();
    super.dispose();
  }

  void _onSubmit(int? userId) async {
    final shouldSubmit =
        await SoldOutConfirmationDialog.show(context, widget.isJobItem) ??
        false;

    if (shouldSubmit) {
      context.read<ItemStatusCubit>().changeItemStatus(
        itemId: widget.preview.id,
        status: ItemStatus.soldOut,
        userId: userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemStatusCubit, ItemStatusState>(
      listener: (context, state) {
        if (state is ItemStatusLoading) {
          LoadingOverlay.show(context);
        }
        if (state is ItemStatusSuccess) {
          LoadingOverlay.hide();
          Navigator.pop(context, true);
        }
        if (state is ItemStatusFailure) {
          LoadingOverlay.hide();
          HelperUtils.showSnackBarMessage(context, state.message);
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text(
            (widget.isJobItem ? 'selectAcceptedUser' : 'selectBuyer').translate(
              context,
            ),
          ),
          bottom: _ItemHeader(preview: widget.preview),
        ),
        bottomAction: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              variant: AppButtonVariant.outlined,
              title: 'noneOfTheAbove',
              onPressed: () => _onSubmit(null),
            ),
            ValueListenableBuilder(
              valueListenable: userId,
              builder: (context, id, child) {
                return AppButton(
                  variant: AppButtonVariant.filled,
                  title: widget.isJobItem ? 'markAsClosed' : 'markAsSold',
                  onPressed: id == null ? null : () => _onSubmit(userId.value),
                );
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: userId,
          builder: (context, id, child) {
            return RadioGroup(
              groupValue: id,
              onChanged: (int? value) {
                if (value == null) return;
                userId.value = value;
              },
              child: child!,
            );
          },
          child: PaginatedListView<BuyerListCubit, UserPreview, void>(
            padding: context.bodyPadding(),
            itemBuilder: (context, user) {
              return _UserTile(preview: user);
            },
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.preview});

  final UserPreview preview;

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      controlAffinity: ListTileControlAffinity.trailing,
      value: preview.id,
      secondary: ProfileAvatar(
        src: preview.profile,
        size: Size.square(40),
        errorImage: UserPlaceholderImage(
          placeholder: preview.placeholder,
          size: Size.square(40),
        ),
      ),
      title: Text(preview.name),
    );
  }
}

class _ItemHeader extends StatelessWidget implements PreferredSizeWidget {
  const _ItemHeader({required this.preview});

  final ItemPreview preview;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: LinearBorder.top(
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      leading: ProfileAvatar(src: preview.image, size: Size.square(40)),
      title: Text(preview.name),
      trailing: Text(
        preview.price ?? '',
        style: context.titleSmall.primaryBold(context),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
