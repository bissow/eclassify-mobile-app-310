import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/repository/subscription_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubscriptionPackageState {}

class SubscriptionPackageInitial extends SubscriptionPackageState {}

class SubscriptionPackageLoading extends SubscriptionPackageState {}

class SubscriptionPackageSuccess extends SubscriptionPackageState {
  SubscriptionPackageSuccess({required this.packages});

  final List<SubscriptionPackage> packages;
}

class SubscriptionPackageFailure extends SubscriptionPackageState {
  final Object error;
  SubscriptionPackageFailure({required this.error});
}

class SubscriptionPackageCubit extends Cubit<SubscriptionPackageState> {
  SubscriptionPackageCubit() : super(SubscriptionPackageInitial());

  Future<void> getPackages({
    required SubscriptionPackageType type,
    int? categoryId,
    AdItemType? adItemType,
    bool isRenew = false,
  }) async {
    try {
      emit(SubscriptionPackageLoading());

      final packages = await SubscriptionRepository.instance.getPackages(
        type: type,
        categoryId: categoryId,
        adItemType: adItemType,
        isRenew: isRenew,
      );

      emit(SubscriptionPackageSuccess(packages: packages));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(SubscriptionPackageFailure(error: e));
    }
  }
}
