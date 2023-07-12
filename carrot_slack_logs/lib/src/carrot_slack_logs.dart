import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

/// {@template slack_logs}
/// Dart package for Slack Logs
/// {@endtemplate}
class LogsRemoteServices {
  LogsRemoteServices._privateConstructor();

  static const String _botToken = 'xoxb-2336262727205-4267593831697-r7V0C1ZZyFZkErc9GWZc3CvY';
  static const String _host = 'https://slack.com/api';

  /// #notify-client-log
  static const keyLogChannelID = 'C049LNM97UY';

  /// #app-client-order-error
  static const orderLogChannelID = 'C04HCEALQ4W';

  static final LogsRemoteServices _instance = LogsRemoteServices._privateConstructor();

  /// {@macro slack_logs}
  static LogsRemoteServices get instance => _instance;

  /// api for push log to slack channel from slack bot
  Future<void> _pushLogToSlackChannel({
    required String channelID,
    required String message,
  }) async {
    try {
      const uri = '$_host/chat.postMessage';

      final body = {
        'channel': channelID,
        'blocks': [
          {
            'type': 'section',
            'text': {'type': 'mrkdwn', 'text': message}
          }
        ]
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
      log('sentLogToChannel slackProvider error $e');
    }
  }

  /// add title to message
  String addTitle(String? title) {
    return '> **$title**';
  }

  /// add message to message
  String addMessage(String? message) {
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

  /// add platform to message
  String _addPlatform() {
    return '\nPlatform: `${Platform.operatingSystem}`';
  }

  /// add app version to message
  String _addAppVersion(String? appVersion) {
    return '\nApp Version: `$appVersion`';
  }

  /// add province to message
  String _addProvince(String? province) {
    return '\nProvince: `$province`';
  }

  /// add current user data to message
  String _addCurrentUserData(String? currentUserData) {
    return '\nUser: `$currentUserData`';
  }

  /// pushKeyLogToRemote
  Future<bool> pushKeyLogToRemote({
    required String title,
    String? key,
    String? message,
    String? appVersion,
    String? appProvince,
  }) async {
    try {
      var text = addTitle(title);
      text += addMessage(message);
      text += _addKey(key);
      text += _addAppVersion(appVersion);
      text += _addProvince(appProvince);
      text += _addPlatform();
      text += _addTimeLog();

      await _pushLogToSlackChannel(channelID: keyLogChannelID, message: text);
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
    String? appVersion,
    String? appProvince,
  }) async {
    try {
      var text = addTitle('Order Error');
      text += addMessage(message);
      text += _addAppVersion(appVersion);
      text += _addProvince(appProvince);
      text += _addPlatform();
      text += _addCurrentUserData(currentUserData);
      text += _addTimeLog();

      await _pushLogToSlackChannel(channelID: orderLogChannelID, message: text);
      return true;
    } catch (e) {
      log('pushOrderLogToRemote error $e');
      return false;
    }
  }
}
