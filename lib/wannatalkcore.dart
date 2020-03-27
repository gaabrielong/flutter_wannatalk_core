import 'dart:async';

import 'package:flutter/services.dart';

class WTEventResponse {

  static const  String cWTEvent= "wt_event";
  static const  int kWTEventTypeLogin= 2001;
  static const  int kWTEventTypeLogout= 2002;

  int eventType;
  WTResult result;

  WTEventResponse.init() {
    this.eventType = -1;
    this.result = new WTResult.init();
  }
}

class WTResult {
  bool success;
  String error;

  WTResult(this.success, this.error);

  WTResult.init() {
    this.success = false;
    this.error = null;
  }
}


class Wannatalkcore {
  static const MethodChannel _channel =
      const MethodChannel('wannatalkcore');


  static Function(WTEventResponse eventResponse) _onReceivedEvent;

  static void setMethodCallHandler({Function(WTEventResponse eventResponse) onReceivedEvent}) {
    _onReceivedEvent = onReceivedEvent;
    _channel.setMethodCallHandler(_wtEvent);
  }

  static Future<void> _wtEvent(MethodCall call) async {

    WTEventResponse eventResponse = new WTEventResponse.init();

    try {

      int eventType = call.arguments["eventType"];
      bool success = call.arguments["success"];
      String error = call.arguments["error"];
      eventResponse.eventType = eventType;
      eventResponse.result.success = success;
      eventResponse.result.error= error;

    } on Exception catch (e) {
      print("Failed to login: '${e.toString()}'.");

    }
    finally {
      _onReceivedEvent(eventResponse);
    }
  }

  static const  String _cWTDefaultMethod= "wannatalkDefaultMethod";
  static const  String _cWTUpdateConfig= "updateConfig";
  static const  String _cWTIsUserLoggedIn= "isUserLoggedIn";


  static const  String _cWTMethodType= "methodType";
  static const  String _cWTArgs= "args";
  static const  String _cWTUsername= "username";
  static const  String _cWTLocalImagePath= "localImagePath";

  static const  String _cWTAutoOpenChat= "autoOpenChat";
  static const  String _cWTUserIdentifier= "userIdentifier";
  static const  String _cWTUserInfo= "userInfo";


  static const  int _kWTLoginMethod= 1001;
  static const  int _kWTSilentLoginMethod= 1002;
  static const  int _kWTLogoutMethod= 1003;
  static const  int _kWTOrgProfileMethod= 1004;
  static const  int _kWTChatListMethod= 1005;
  static const  int _kWTUserListMethod= 1006;
  static const  int _kWTUpdateUserNameMethod= 1007;
  static const  int _kWTUpdateUserImageMethod= 1008;
  static const  int _kWTIsUserLoggedIn= 1009;



  static Future<bool> get isUserLoggedIn => _channel.invokeMethod(_cWTIsUserLoggedIn);

  static Future<void> login({Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTLoginMethod, null, onCompletion: onCompletion);
  }

  static Future<void> silentLogin(String userIdentifier, Map userInfo, {Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTSilentLoginMethod, <String, dynamic>{_cWTUserIdentifier: userIdentifier, _cWTUserInfo: userInfo}, onCompletion: onCompletion);
  }

  static Future<void> logout({Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTLogoutMethod, null, onCompletion: onCompletion);
  }

  static Future<void> presentOrganizationProfile(bool autoOpenChat, {Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTOrgProfileMethod, <String, dynamic>{_cWTAutoOpenChat: autoOpenChat}, onCompletion: onCompletion);
  }

  static Future<void> presentChats({Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTChatListMethod, null, onCompletion: onCompletion);
  }

  static Future<void> presentUsers({Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTUserListMethod, null, onCompletion: onCompletion);
  }

  static Future<void> updateUserName(String username, {Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTUpdateUserNameMethod, <String, dynamic>{_cWTUsername: username}, onCompletion: onCompletion);
  }

  static Future<void> updateUserImage(String localImagePath, {Function(WTResult result) onCompletion}) async {
    _sendWannatalkMethod(_kWTUpdateUserImageMethod, <String, dynamic>{_cWTLocalImagePath: localImagePath}, onCompletion: onCompletion);
  }

//  static Future<String> _sendWannatalkMethod2(int kWTMethod, Object object, {Function(bool success, String error) onCompletion}) async {
//    String error = await _channel.invokeMethod(_cWTDefaultMethod, <String, dynamic>{_cWTMethodType: kWTMethod, _cWTArgs: object});
//    onCompletion(error == null, error);
//    return error;
//  }

  static Future<WTResult> _sendWannatalkMethod(int kWTMethod, Object object, {Function(WTResult result) onCompletion}) async {
    String error = await _channel.invokeMethod(_cWTDefaultMethod, <String, dynamic>{_cWTMethodType: kWTMethod, _cWTArgs: object});
    WTResult result = new WTResult(error == null, error);
    onCompletion(result);
    return result;
  }

  static Future<void> _updateConfig(int kWTMethod, Object object) async {
    _channel.invokeMethod(_cWTUpdateConfig, <String, dynamic>{_cWTMethodType: kWTMethod, _cWTArgs: object});
  }


}

class WannatalkConfig {

  static const  int _kWTConfigClearTempFolder = 9001;
  static const  int _kWTConfigSetInactiveChatTimeout = 9002;
  static const  int _kWTConfigShowGuideButton = 9003;
  static const  int _kWTConfigAllowSendAudioMessage = 9004;
  static const  int _kWTConfigAllowAddParticipant = 9005;
  static const  int _kWTConfigAllowRemoveParticipants = 9006;
  static const  int _kWTConfigShowWelcomePage = 9007;
  static const  int _kWTConfigShowProfileInfoPage = 9008;
  static const  int _kWTConfigEnableAutoTickets = 9009;
  static const  int _kWTConfigShowExitButton = 9010;
  static const  int _kWTConfigShowChatParticipants = 9011;
  static const  int _kWTConfigEnableChatProfile = 9012;
  static const  int _kWTConfigAllowModifyChatProfile = 9013;

  static const  String _cEnable= "enable";
  static const  String _cShow= "show";
  static const  String _cAllow= "allow";
  static const  String _cTimeoutInterval = "timeoutInterval";

  static Future<void> clearTempFiles(bool show) async {
    Wannatalkcore._updateConfig(_kWTConfigClearTempFolder, null);
  }
  static Future<void> setInactiveChatTimeout(double interval) async {
    Wannatalkcore._updateConfig(_kWTConfigSetInactiveChatTimeout, <String, dynamic>{_cTimeoutInterval: interval});
  }

  static Future<void> showGuideButton(bool show) async {
    Wannatalkcore._updateConfig(_kWTConfigShowGuideButton, <String, dynamic>{_cShow: show});
  }

  static Future<void> allowSendAudioMessage(bool allow) async {
    Wannatalkcore._updateConfig(_kWTConfigAllowSendAudioMessage, <String, dynamic>{_cAllow: allow});
  }

  static Future<void> allowAddParticipants(bool allow) async {
    Wannatalkcore._updateConfig(_kWTConfigAllowAddParticipant, <String, dynamic>{_cAllow: allow});
  }


  static Future<void> allowRemoveParticipants(bool allow) async {
    Wannatalkcore._updateConfig(_kWTConfigAllowRemoveParticipants, <String, dynamic>{_cAllow: allow});
  }


  static Future<void> showWelcomeMessage(bool show) async {
    Wannatalkcore._updateConfig(_kWTConfigShowWelcomePage, <String, dynamic>{_cShow: show});
  }


  static Future<void> showProfileInfoPage(bool show) async {
    Wannatalkcore._updateConfig(_kWTConfigShowProfileInfoPage, <String, dynamic>{_cShow: show});
  }

  static Future<void> enableAutoTickets(bool enable) async {
    Wannatalkcore._updateConfig(_kWTConfigEnableAutoTickets, <String, dynamic>{_cEnable: enable});
  }

  static Future<void> showExitButton(bool show) async {
    Wannatalkcore._updateConfig(_kWTConfigShowExitButton, <String, dynamic>{_cShow: show});
  }

  static Future<void> showChatParticipants(bool show) async {
    Wannatalkcore._updateConfig(_kWTConfigShowChatParticipants, <String, dynamic>{_cShow: show});
  }


  static Future<void> enableChatProfile(bool enable) async {
    Wannatalkcore._updateConfig(_kWTConfigEnableChatProfile, <String, dynamic>{_cEnable: enable});
  }

  static Future<void> allowModifyChatProfile(bool allow) async {
    Wannatalkcore._updateConfig(_kWTConfigAllowModifyChatProfile, <String, dynamic>{_cAllow: allow});
  }

}
