// ignore_for_file: prefer_const_constructors
import 'package:logs_remote_services/logs_remote_services.dart';
import 'package:test/test.dart';

void main() {
  group('SlackLogs', () {
    test('can be instantiated', () {
      expect(LogsRemoteServices.instance, isNotNull);
    });
  });

  group('SlackLogs', () {
    test('pushOrderLogToRemote Success', () async {
      final isSuccessful = await LogsRemoteServices.instance.pushOrderLogToRemote(
        message: 'Failed host lookup: api.mapbox.com',
        currentUserData:
            '{id: 29192, email: thanhxinh@gmail.com, name: VILL VIỆT NAM, api_token: P1CI9shTAGkIxrprWjrNNbS4uhnZQsSqXOxcL69STLTJRwkzYVb8GYsuwONY, province_id: 1, phone: 0869247309, address: , player_id_onesignal: ee4c270a-0a6e-46ff-b755-29d0f846e5ce}',
        appProvince: 'BAO_LOC',
        appVersion: '1.2.108',
      );
      expect(isSuccessful, true);
    });

    test('pushKeyLogToRemote Success', () async {
      final isSuccessful = await LogsRemoteServices.instance.pushKeyLogToRemote(
        title: 'Key Error',
        key: '1234567890abcdefghijklmnopqrstuvwxyz',
        message: 'Failed host lookup: _host',
        appProvince: 'BAO_LOC',
        appVersion: '1.2.108',
      );
      expect(isSuccessful, true);
    });
  });
}
