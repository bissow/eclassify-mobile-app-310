import 'package:eClassify/features/subscription/repository/subscription_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AssignFreePackageState {}

class AssignFreePackageInitial extends AssignFreePackageState {}

class AssignFreePackageLoading extends AssignFreePackageState {}

class AssignFreePackageSuccess extends AssignFreePackageState {
  AssignFreePackageSuccess({required this.responseMessage});

  final String responseMessage;
}

class AssignFreePackageFailure extends AssignFreePackageState {
  AssignFreePackageFailure({required this.error});

  final String error;
}

class AssignFreePackageCubit extends Cubit<AssignFreePackageState> {
  AssignFreePackageCubit() : super(AssignFreePackageInitial());

  void assignFreePackage({required int packageId}) async {
    try {
      emit(AssignFreePackageLoading());

      final response = await SubscriptionRepository.instance.assignFreePackage(
        packageId: packageId,
      );

      emit(AssignFreePackageSuccess(responseMessage: response));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(AssignFreePackageFailure(error: e.toString()));
    }
  }
}
