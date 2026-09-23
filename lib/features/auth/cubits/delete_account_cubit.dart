import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {}

class DeleteAccountFailure extends DeleteAccountState {
  DeleteAccountFailure(this.error);

  final Object error;
}

/// Firebase's session for this device is too old to authorize deletion, and
/// [providerId] tells the UI which account this was signed in with — used
/// only to phrase the "log out and come back" prompt, since no in-app
/// reauthentication flow is offered (see class doc).
class FreshLoginRequiredForDeletion extends DeleteAccountState {
  FreshLoginRequiredForDeletion(this.providerId);

  final String providerId;
}

/// Deletes the current user's account. Firebase requires a recent sign-in
/// to authorize `currentUser.delete()`; rather than prompting for
/// reauthentication in-app (jarring UX mid-deletion, e.g. replaying an
/// OAuth account picker), a stale session emits
/// [FreshLoginRequiredForDeletion] so the UI can offer a simple "log out
/// and retry" choice instead.
///
/// Phone accounts are a deliberate exception: they sign in via a
/// backend-native password, never establishing a Firebase session, so
/// there's no Firebase session to satisfy recency for in the first place.
/// For those (and the rare case a stale Firebase session's provider can't
/// be read), Firebase is left alone and only the backend record is
/// deleted — the Firebase Auth entry for that number, if any, is
/// permanently orphaned but harmless: future signups with the same number
/// still work.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial());

  final _repository = AuthModule.instance.repository;

  Future<void> deleteUserAccount() async {
    emit(DeleteAccountInProgress());

    try {
      await FirebaseAuth.instance.currentUser?.delete();
    } on FirebaseAuthException catch (e, st) {
      if (e.code == 'requires-recent-login') {
        final providerId = FirebaseAuth
            .instance
            .currentUser
            ?.providerData
            .firstOrNull
            ?.providerId;
        if (providerId != null) {
          emit(FreshLoginRequiredForDeletion(providerId));
          return;
        }
        // No readable provider (e.g. phone) — proceed to backend deletion.
      } else {
        Log.error('Firebase account deletion failed', e, st);
        emit(DeleteAccountFailure(e));
        return;
      }
    } on Exception catch (e, st) {
      Log.error('Firebase account deletion failed', e, st);
      emit(DeleteAccountFailure(e));
      return;
    }

    try {
      await _repository.deleteRemoteUser();
      await _repository.localSessionService.clearLocalSession();
      emit(DeleteAccountSuccess());
    } on Exception catch (e, st) {
      Log.error('Remote account deletion failed', e, st);
      emit(DeleteAccountFailure(e));
    }
  }
}
