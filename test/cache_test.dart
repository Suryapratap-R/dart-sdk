import 'dart:convert';

import 'package:configcat_client/configcat_client.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'cache_test.mocks.dart';
import 'helpers.dart';

@GenerateMocks([ConfigCatCache])
void main() {
  tearDown(() {
    ConfigCatClient.closeAll();
  });

  test('failing cache, returns memory-cached value', () async {
    // Arrange
    final cache = MockConfigCatCache();

    when(cache.write(any, any)).thenThrow(Exception());
    when(cache.read(any)).thenThrow(Exception());

    final client = ConfigCatClient.get(
        sdkKey: testSdkKey, options: ConfigCatOptions(cache: cache));
    final dioAdapter = DioAdapter(dio: client.httpClient);
    dioAdapter.onGet(getPath(), (server) {
      server.reply(200, createTestConfig({'value': 'test'}).toJson());
    });

    // Act
    final value = await client.getValue(key: 'value', defaultValue: '');

    // Assert
    expect(value, equals('test'));
  });

  test('failing fetch, returns cached value', () async {
    // Arrange
    final cache = MockConfigCatCache();
    when(cache.read(any)).thenAnswer(
        (_) => Future.value(jsonEncode(createTestEntry({'value': 'test'}))));

    final client = ConfigCatClient.get(
        sdkKey: testSdkKey, options: ConfigCatOptions(cache: cache));
    final dioAdapter = DioAdapter(dio: client.httpClient);
    dioAdapter.onGet(getPath(), (server) {
      server.reply(500, null);
    });

    // Act
    final value = await client.getValue(key: 'value', defaultValue: '');

    // Assert
    expect(value, equals('test'));
  });
}
