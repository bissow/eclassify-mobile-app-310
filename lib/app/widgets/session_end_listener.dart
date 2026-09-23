import 'package:eClassify/app/provider_registry.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reacts to the session ending — a manual logout, an account deletion, or a
/// 401 caught by `UnauthenticatedInterceptor`.
///
/// Every screen that can be on-screen when a session ends has to wrap itself
/// in this. A stale token makes the very first request fail while
/// `SplashScreen` is still up, so a listener that only lives on `MainActivity`
/// never sees that transition — `AuthSessionCubit` has already settled into
/// `Unauthenticated` by the time it mounts.
class SessionEndListener extends StatelessWidget {
  const SessionEndListener({
    required this.child,
    this.onSessionEnded,
    super.key,
  });

  final Widget child;

  /// Replaces the default redirect to [Routes.auth]. Used by screens that
  /// can't be torn down on the spot — `SplashScreen` still has to finish
  /// loading system settings and translations before anything else can render.
  final VoidCallback? onSessionEnded;

  void _endSession(BuildContext context, Unauthenticated state) {
    for (final getter in ProviderRegistry.sessionScopedCubits) {
      getter(context).clearSessionState();
    }
    context.read<BottomNavCubit>().changeTab(BottomTab.home);

    if (state.reason == SessionEndReason.expired) {
      HelperUtils.showSnackBarMessage(
        context,
        'sessionExpired'.translate(context),
        messageDuration: 3,
      );
    }

    if (onSessionEnded != null) {
      onSessionEnded!();
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.auth, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) {
        if (state is Unauthenticated) _endSession(context, state);
      },
      child: child,
    );
  }
}
