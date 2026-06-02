import 'package:flutter_boilerplate/features/onboarding/widgets/splash_brand_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash content fits compact landscape screens', (tester) async {
    tester.view.physicalSize = const Size(2069, 1080);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SplashBrandContent(
            logoOpacity: 1,
            logoScale: 1,
            pulseProgress: 0.5,
            orbitProgress: 0.5,
            shimmerProgress: 0.5,
            textReveal: 1,
            taglineReveal: 1,
            barReveal: 1,
            loadingProgress: 0.5,
            brand: Colors.green,
            accent: Colors.orange,
            surface: Colors.white,
            isDarkMode: false,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Flutter Boilerplate'), findsOneWidget);
  });
}
