import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wise_apartment/wise_apartment_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWiseApartment platform = MethodChannelWiseApartment();
  const MethodChannel channel = MethodChannel('wise_apartment/methods');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
