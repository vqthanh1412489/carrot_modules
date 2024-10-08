import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// {@template mattermost_logs}
/// Dart package for MatterMost Logs
/// {@endtemplate}
class LogsRemoteServices {
  LogsRemoteServices._privateConstructor();

  static const String _botToken = 'jzjzqftwxbgs7y6igxpd7wmbey';
  static const String _host = 'https://workspace.villvietnam.vn/api/v4';

  /// #Client-Key-Logs
  static const keyLogChannelID = 'rmg3fw5zzpr6txqzhdsz3n6udy';

  /// #Client-Order-Logs
  static const orderLogChannelID = '7iu481qcnt8c3xgmi3pnspufzw';

  /// #dev-log-social
  // static const devLogSocialChannelId = 'sskreweg878yzyed6qiyjhniue';

  /// #cl_payment_logs
  static const clPaymentLogsChannelId = 'gd5fh7ieefbn3d515fxcahx6iy';

  /// wrong_api_exception
  static const wrongApiExceptionChannelId = '67xpog5x67817k1e3iysmn9gmo';

  static final LogsRemoteServices _instance =
      LogsRemoteServices._privateConstructor();

  /// {@macro mattermost_logs}
  static LogsRemoteServices get instance => _instance;

  /// api for push log to mattermost channel from mattermost bot
  Future<void> _pushLogToMatterMostChannel({
    required String channelID,
    required String message,
  }) async {
    try {
      const uri = '$_host/posts';

      final body = {
        'channel_id': channelID,
        'message': message,
      };

      final headers = {
        'Authorization': 'Bearer $_botToken',
      };

      await Dio().post<void>(
        uri,
        data: jsonEncode(body),
        options: Options(
          headers: headers,
        ),
      );
    } catch (e) {
      log('sentLogToChannel MatterMostProvider error $e');
    }
  }

  /// add title to message
  String _addTitle(String? title) {
    return '> **$title**';
  }

  /// add payload to message
  String _addPayload(Map<String, dynamic>? value) {
    return '\nPayload: `$value`';
  }

  /// add message to message
  String _addMessage(String? message) {
    return '\nMessage: $message';
  }

  /// add key to message
  String _addKey(String? key) {
    return '\nKey: `$key`';
  }

  /// add time log to message
  String _addTimeLog() {
    return '\nTimelog: `${DateTime.now()}`';
  }

  /// add app version to message
  String _addAppInfo(String? appInfo) {
    return '\nAppInfo: $appInfo';
  }

  /// add province to message
  // String _addProvince(String? province, [String? subProvince]) {
  //   if (subProvince == null) {
  //     return '\nProvince: `$province`';
  //   }
  //   return '\nProvince: `$province` - SubProvince: `$subProvince`';
  // }

  /// add current user data to message
  String _addCurrentUser(String? currentUser) {
    return '\nUser: `$currentUser`';
  }

  /// pushKeyLogToRemote
  Future<bool> pushKeyLogToRemote({
    required String title,
    String? key,
    String? message,
    String? appInfo,
  }) async {
    try {
      var text = _addTitle(title);
      text += _addMessage(message);
      text += _addKey(key);
      text += _addAppInfo(appInfo);
      text += _addTimeLog();

      await _pushLogToMatterMostChannel(
        channelID: keyLogChannelID,
        message: text,
      );
      return true;
    } catch (e) {
      log('pushKeyLogToRemote error $e');
      return false;
    }
  }

  /// pushOrderLogToRemote
  Future<bool> pushOrderLogToRemote({
    String? message,
    String? currentUserData,
    String? appInfo,
    Map<String, dynamic>? payload,
  }) async {
    try {
      var text = _addTitle('onOrderPlace Error');
      text += _addMessage(message);
      text += _addPayload(payload);
      text += _addAppInfo(appInfo);
      text += _addCurrentUser(currentUserData);
      text += _addTimeLog();

      await _pushLogToMatterMostChannel(
        channelID: orderLogChannelID,
        message: text,
      );
      return true;
    } catch (e) {
      log('pushOrderLogToRemote error $e');
      return false;
    }
  }

  /// devLogSocialChannelId
  Future<bool> pushClPaymentLogs({
    String? message,
    String? currentUserData,
    String? appInfo,
  }) async {
    try {
      var text = _addTitle('cl_payment_logs Error');
      text += _addMessage(message);
      text += _addAppInfo(appInfo);
      text += _addCurrentUser(currentUserData);
      text += _addTimeLog();

      await _pushLogToMatterMostChannel(
        channelID: clPaymentLogsChannelId,
        message: text,
      );
      return true;
    } catch (e) {
      log('pushClPaymentLogs error $e');
      return false;
    }
  }

  /// wrong_api_exception
  Future<bool> wrongApiExceptionLogs({
    String? message,
    String? currentUserData,
    String? appInfo,
  }) async {
    try {
      var text = _addTitle('wrong_api_exception Error');
      text += _addMessage(message);
      text += _addAppInfo(appInfo);
      text += _addCurrentUser(currentUserData);
      text += _addTimeLog();

      await _pushLogToMatterMostChannel(
        channelID: wrongApiExceptionChannelId,
        message: text,
      );
      return true;
    } catch (e) {
      log('wrong_api_exception error $e');
      return false;
    }
  }
}
