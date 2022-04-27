import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_effects_plugin/zego_effects_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('zego_effects_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZegoEffectsPlugin.platformVersion, '42');
  });
}
