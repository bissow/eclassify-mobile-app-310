import 'package:eClassify/features/auth/storage/auth_storage.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/app/session/app_session.dart';

class LocalSessionService {
  Future<void> saveLocalUser(User user) async {
    AuthStorage.setUser(user.toJson());
    AppSession.setCurrentUser(user);
  }

  Future<void> saveLocalJwtToken(String token) async {
    AuthStorage.setJWT(token);
    AppSession.setJwtToken(token);
  }

  User? getLocalUser() {
    return AuthStorage.getUser();
  }

  String? getLocalJwtToken() {
    return AuthStorage.getJWT();
  }

  Future<void> clearLocalSession() async {
    await AuthStorage.clearSession();
    AppSession.clear();
  }
}
