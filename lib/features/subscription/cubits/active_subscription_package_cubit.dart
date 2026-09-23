import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/repository/subscription_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageInitial extends ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageLoading extends ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageSuccess extends ActiveSubscriptionPackageState {
  ActiveSubscriptionPackageSuccess({required this.activePackages});

  final List<SubscriptionPackage> activePackages;
}

class ActiveSubscriptionPackageFailure extends ActiveSubscriptionPackageState {
  ActiveSubscriptionPackageFailure({required this.error});

  final Object error;
}

class ActiveSubscriptionPackageCubit
    extends Cubit<ActiveSubscriptionPackageState>
    with SessionScoped {
  ActiveSubscriptionPackageCubit() : super(ActiveSubscriptionPackageInitial());

  bool _isFetching = false;

  @override
  void clearSessionState() => emit(ActiveSubscriptionPackageInitial());

  /// [silent] skips the [ActiveSubscriptionPackageLoading] emission — for
  /// background refreshes (e.g. a [PaymentNotification] arriving while
  /// this screen is already showing data) where flashing a loading state
  /// over existing content would just be visual noise.
  Future<void> getPackages({
    SubscriptionPackageType? type,
    int? categoryId,
    AdItemType? adItemType,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      if (!silent) emit(ActiveSubscriptionPackageLoading());

      final activePackages = await SubscriptionRepository.instance
          .getActivePackages(
            type: type,
            categoryId: categoryId,
            adItemType: adItemType,
          );

      emit(ActiveSubscriptionPackageSuccess(activePackages: activePackages));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ActiveSubscriptionPackageFailure(error: e));
    } finally {
      _isFetching = false;
    }
  }
}
