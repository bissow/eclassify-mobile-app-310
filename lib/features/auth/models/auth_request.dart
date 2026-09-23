import 'package:eClassify/core/models/contact.dart';

enum AuthType { signIn, signUp }

sealed class AuthRequest {}

class EmailAuthRequest extends AuthRequest {
  EmailAuthRequest({
    required this.email,
    required this.password,
    required this.authType,
  });

  final String email;
  final String password;
  final AuthType authType;
}

class PhoneAuthRequest extends AuthRequest {
  PhoneAuthRequest({required this.contact, required this.password});

  final Contact contact;
  final String password;
}

class GoogleAuthRequest extends AuthRequest {}

class AppleAuthRequest extends AuthRequest {}
