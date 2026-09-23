import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/cubits/delete_account_cubit.dart';
import 'package:eClassify/features/auth/cubits/logout_cubit.dart';
import 'package:eClassify/features/auth/ui/modals/fresh_login_required_dialog.dart';
import 'package:eClassify/features/subscription/cubits/active_subscription_package_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileListenersScope extends StatelessWidget {
  const ProfileListenersScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteAccountCubit, DeleteAccountState>(
          listener: (context, state) async {
            if (state is DeleteAccountInProgress) {
              LoadingOverlay.show(context);
            }
            if (state is DeleteAccountSuccess) {
              HelperUtils.showSnackBarMessage(
                context,
                'userDeletedSuccessfully'.translate(context),
              );
              context.read<AuthSessionCubit>().clearSession();
              LoadingOverlay.hide();
            }
            if (state is DeleteAccountFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(
                context,
                ApiErrorHelper.errorMessageFromException(context, state.error),
              );
            }
            if (state is FreshLoginRequiredForDeletion) {
              LoadingOverlay.hide();
              final shouldLogOut =
                  await FreshLoginRequiredDialog.show(context) ?? false;
              if (shouldLogOut) {
                context.read<LogoutCubit>().logout();
              }
            }
          },
        ),
        BlocListener<LogoutCubit, LogoutState>(
          listener: (context, state) async {
            if (state is LoggingOut) {
              LoadingOverlay.show(context);
            }
            if (state is LogoutSuccess) {
              context.read<AuthSessionCubit>().clearSession();
              LoadingOverlay.hide();
            }
            if (state is LogoutFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(
                context,
                ApiErrorHelper.errorMessageFromException(context, state.error),
              );
            }
          },
        ),
        BlocListener<
          ActiveSubscriptionPackageCubit,
          ActiveSubscriptionPackageState
        >(
          // This cubit is global (see register_cubits.dart) and can get
          // refetched from places other than this scope's own "subscription"
          // menu tap — e.g. ActivePlanScreen's own ServerNotificationListener
          // silently refreshing it on a payment notification. Without this
          // guard, any such background refetch would ALSO make this listener
          // navigate here, stacking a second push on top of whatever already
          // handled that purchase directly. Only react when the user is
          // actually sitting on the main shell (this scope's own screen) —
          // AppSession.currentRouteName tracks the real top-of-stack route
          // via AppNavigatorObserver, not a fixed ModalRoute reference.
          listenWhen: (_, __) => AppSession.currentRouteName == Routes.main,
          listener: (context, state) {
            if (state is ActiveSubscriptionPackageLoading) {
              LoadingOverlay.show(context);
            }
            if (state is ActiveSubscriptionPackageSuccess) {
              LoadingOverlay.hide();
              if (state.activePackages.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  Routes.activePlanScreen,
                  arguments: context.read<ActiveSubscriptionPackageCubit>(),
                );
              } else {
                Navigator.of(context).pushNamed(Routes.subscriptionScreen);
              }
            }
            if (state is ActiveSubscriptionPackageFailure) {
              LoadingOverlay.hide();
              Navigator.of(context).pushNamed(Routes.subscriptionScreen);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
