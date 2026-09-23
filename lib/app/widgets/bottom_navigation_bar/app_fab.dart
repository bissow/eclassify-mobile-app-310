import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/widgets/bottom_navigation_bar/blob_border.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/subscription/cubits/user_package_limit_cubit.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/screens/widgets/hexagon_shape_border.dart';
import 'package:eClassify/features/subscription/screens/widgets/no_package_available_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

enum FabType { diamond, round, ellipse, svg, material, custom }

class AppFab extends StatelessWidget {
  const AppFab({
    this.type = FabType.diamond,
    this.borderRadius = 20,
    this.svgAsset,
    this.svgSize = 80,
    this.border,
    this.heroTag,
    super.key,
  }) : assert(
         type != FabType.svg || svgAsset != null,
         'svgAsset must not be null when type is FabType.svg',
       );
  final FabType type;
  final double borderRadius;
  final String? svgAsset;
  final double? svgSize;
  final ShapeBorder? border;
  final Object? heroTag;

  ShapeBorder? get _shapeBorder {
    assert(
      type != FabType.custom || border != null,
      'border must not be null when type is FabType.custom',
    );
    return switch (type) {
      FabType.diamond => HexagonBorderShape(cornerRadius: 5),
      FabType.round => CircleBorder(),
      FabType.ellipse => RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      FabType.svg => null,
      FabType.material => null,
      FabType.custom => border,
    };
  }

  void _onPressed(BuildContext context) {
    UiUtils.checkUser(
      onNotGuest: () {
        // Instead of calling the api everytime the button is pressed we can optimize
        // it to check whether the state is already success so we can directly navigate
        // but doing so will remove the correctness if the user's plan expired while the api
        // was open, then this will allow the item to be added or maybe not if the api
        // has such checks. Need to confirm.
        //
        // In either case, calling api on every button click is not ideal solution for this
        final state = context.read<UserPackageLimitCubit>().state;
        if (state is UserPackageLimitLoading &&
            state.packageType == SubscriptionPackageType.itemListing) {
          return;
        }
        context.read<UserPackageLimitCubit>().fetchUserPackageLimit(
          packageType: SubscriptionPackageType.itemListing,
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (type == FabType.svg) {
      if (svgAsset == null) {
        throw Exception('svgAsset must not be null when type is FabType.svg');
      }
      child = GestureDetector(
        onTap: () => _onPressed(context),
        child: SvgPicture.asset(svgAsset!, height: svgSize, width: svgSize),
      );
    } else if (type == FabType.custom) {
      child = CustomPaint(
        painter: const BlobShadowPainter(
          shadow: BoxShadow(
            color: Color(0x3F00B2CA),
            blurRadius: 10,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ),
        child: FloatingActionButton(
          heroTag: heroTag,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => _onPressed(context),
          shape: _shapeBorder,
          child: CustomImage(
            src: AppAssets.common.plusIcon,
            color: context.colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      child = FloatingActionButton(
        heroTag: heroTag,
        onPressed: () => _onPressed(context),
        shape: _shapeBorder,
        child: Icon(AppIcons.plus),
      );
    }

    return BlocListener<UserPackageLimitCubit, UserPackageLimitState>(
      listenWhen: (_, state) =>
          state.packageType == SubscriptionPackageType.itemListing,
      listener: (context, state) {
        if (state is UserPackageLimitFailure) {
          NoPackageAvailableDialog.show(
            context,
            type: SubscriptionPackageType.itemListing,
          );
        }
        if (state is UserPackageLimitSuccess) {
          Navigator.pushNamed(context, Routes.adPostingScreen);
        }
      },
      child: child,
    );
  }
}
