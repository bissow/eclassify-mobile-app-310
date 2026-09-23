import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/repository/subscription_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// This cubit is registered globally (see provider_registry.dart) and shared
// by every "check my package limit before proceeding" flow — item listing
// (AppFab) and featured ads (FeatureAdCard) both drive it. Every state
// carries which packageType it's for so each listener can filter to just
// its own flow with listenWhen; without it, a fetch for one flow also
// fires the other flow's listener. packageType is nullable only because
// UserPackageLimitInitial exists before any fetch has been made.
abstract class UserPackageLimitState {
  const UserPackageLimitState(this.packageType);

  final SubscriptionPackageType? packageType;
}

class UserPackageLimitInitial extends UserPackageLimitState {
  const UserPackageLimitInitial() : super(null);
}

class UserPackageLimitLoading extends UserPackageLimitState {
  const UserPackageLimitLoading(super.packageType);
}

class UserPackageLimitSuccess extends UserPackageLimitState {
  const UserPackageLimitSuccess(super.packageType);
}

class UserPackageLimitFailure extends UserPackageLimitState {
  const UserPackageLimitFailure(super.packageType, {required this.error});

  final String error;
}

class UserPackageLimitCubit extends Cubit<UserPackageLimitState>
    with SessionScoped {
  UserPackageLimitCubit() : super(const UserPackageLimitInitial());

  @override
  void clearSessionState() => emit(const UserPackageLimitInitial());

  void fetchUserPackageLimit({
    required SubscriptionPackageType packageType,
  }) async {
    try {
      emit(UserPackageLimitLoading(packageType));

      await SubscriptionRepository.instance.fetchUserPackageLimit(
        packageType: packageType,
      );

      emit(UserPackageLimitSuccess(packageType));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(UserPackageLimitFailure(packageType, error: e.toString()));
    }
  }
}
