import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/splash/presentation/screens/splash_screen.dart';
import 'package:derin_kazi/features/splash/presentation/widgets/lava_particles_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Açılış Ekranı (SplashScreen) & Lav Parçacık Sistemi Testleri', () {
    test('LavaParticle random parçacıklar doğru sınır değerlerde üretilmeli', () {
      final particle = LavaParticle.random(
        Random(42),
        const Size(800, 600),
      );

      expect(particle.size, greaterThan(0));
      expect(particle.speed, greaterThan(0));
      expect(particle.opacity, greaterThan(0));
    });

    testWidgets('SplashScreen başarıyla render edilmeli ve başlıkları içermeli', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('YERALTI SAVAŞLARI'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
