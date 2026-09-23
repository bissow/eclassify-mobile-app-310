import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class SmartAuthSMSRetriever extends SmsRetriever {
  final SmartAuth _smartAuth = SmartAuth.instance;

  @override
  Future<void> dispose() async {
    _smartAuth.removeSmsRetrieverApiListener();
    _smartAuth.removeUserConsentApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final retrieverRes = await _smartAuth.getSmsWithRetrieverApi();
    if (retrieverRes.hasData) return retrieverRes.data!.code;

    final consentRes = await _smartAuth.getSmsWithUserConsentApi();
    if (consentRes.hasData) return consentRes.data!.code;

    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}
