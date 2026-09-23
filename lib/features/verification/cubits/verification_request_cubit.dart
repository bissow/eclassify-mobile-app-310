import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/verification/models/verification_request.dart';
import 'package:eClassify/features/verification/repository/verification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VerificationRequestState {}

class VerificationRequestInitial extends VerificationRequestState {}

class VerificationRequestLoading extends VerificationRequestState {}

class VerificationRequestSuccess extends VerificationRequestState {
  VerificationRequestSuccess({required this.request});

  final VerificationRequest request;
}

class VerificationRequestFail extends VerificationRequestState {
  VerificationRequestFail({required this.error});

  final Object? error;
}

class VerificationRequestCubit extends Cubit<VerificationRequestState>
    with SessionScoped {
  VerificationRequestCubit() : super(VerificationRequestInitial());

  @override
  void clearSessionState() => emit(VerificationRequestInitial());

  void fetchVerificationRequest() async {
    try {
      emit(VerificationRequestLoading());
      final request = await UserVerificationRepository.instance
          .getVerificationRequest();
      emit(VerificationRequestSuccess(request: request));
    } catch (e) {
      emit(VerificationRequestFail(error: e));
    }
  }
}
