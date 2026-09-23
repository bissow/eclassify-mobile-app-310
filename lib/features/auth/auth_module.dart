import 'package:eClassify/features/auth/repository/auth_repository.dart';
import 'package:eClassify/features/auth/repository/profile_repository.dart';
import 'package:eClassify/features/auth/services/email_auth_service.dart';
import 'package:eClassify/features/auth/services/phone_auth_service.dart';
import 'package:eClassify/features/auth/services/oauth_service.dart';
import 'package:eClassify/features/auth/services/firebase_otp_service.dart';
import 'package:eClassify/features/auth/services/third_party_otp_service.dart';
import 'package:eClassify/features/auth/services/local_session_service.dart';

class AuthModule {
  static AuthModule get instance => _instance;

  AuthModule._internal();

  static final AuthModule _instance = AuthModule._internal();

  EmailAuthService? _emailAuthService;
  EmailAuthService get emailAuthService =>
      _emailAuthService ??= EmailAuthService();

  OAuthService? _oauthService;
  OAuthService get oauthService => _oauthService ??= OAuthService();

  FirebaseOtpService? _firebaseOtpService;
  FirebaseOtpService get firebaseOtpService =>
      _firebaseOtpService ??= FirebaseOtpService();

  ThirdPartyOtpService? _thirdPartyOtpService;
  ThirdPartyOtpService get thirdPartyOtpService =>
      _thirdPartyOtpService ??= ThirdPartyOtpService();

  PhoneAuthService? _phoneAuthService;
  PhoneAuthService get phoneAuthService =>
      _phoneAuthService ??= PhoneAuthService();

  LocalSessionService? _localSessionService;
  LocalSessionService get localSessionService =>
      _localSessionService ??= LocalSessionService();

  ProfileRepository? _profileRepository;
  ProfileRepository get profileRepository =>
      _profileRepository ??= ProfileRepository();

  AuthRepository? _repository;

  AuthRepository get repository => _repository ?? _buildRepository();

  AuthRepository _buildRepository() {
    _repository = AuthRepository(
      phoneAuthService: phoneAuthService,
      localSessionService: localSessionService,
    );
    return _repository!;
  }
}
