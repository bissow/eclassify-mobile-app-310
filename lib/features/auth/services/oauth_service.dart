import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

class OAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);

    final existingName = userCredential.user?.displayName;
    if (existingName.isNullOrEmpty) {
      final givenName = appleCredential.givenName;
      final familyName = appleCredential.familyName;
      final appleName = [
        givenName,
        familyName,
      ].where((e) => e.isNotNullAndNotEmpty).join(' ');

      String getFallbackName() {
        final uid = userCredential.user?.uid;
        final random = uid?.substring(0, 8) ?? Uuid().v4().substring(0, 8);
        return 'guest_$random';
      }

      final name = appleName.isNotNullAndNotEmpty
          ? appleName
          : getFallbackName();

      await userCredential.user?.updateDisplayName(name);
    }

    return userCredential;
  }

  Future<void> signOutOAuth() async {
    // Always initialize + sign out, regardless of whether Google was used
    // this session — _googleSignInInitialized only tracks the current app
    // run, so a Google session restored from a prior run would otherwise
    // never get cleared. Both calls are safe no-ops if Google was never
    // actually used.
    await _ensureGoogleInitialized();
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
