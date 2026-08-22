import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Derin Kazı App render ve Mağaza buton testi', (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DerinKaziApp(),
      ),
    );

    // Ana Menü Elemanları
    expect(find.text('DERİN KAZI'), findsOneWidget);
    expect(find.text('SOLO KAZI'), findsOneWidget);
    expect(find.text('EKİP KAZISI (ODA KUR)'), findsOneWidget);
    expect(find.text('ODAYA KATIL'), findsOneWidget);

    // Solo Kazı'ya tıkla
    await tester.tap(find.text('SOLO KAZI'));
    await tester.pumpAndSettle();

    // 3 Saniyelik geri sayımın bitmesini bekle (Overlay kapansın)
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Oyun ekranı açıldı mı?
    expect(find.text('MAĞAZA'), findsOneWidget);
    expect(find.text('ÇANTA'), findsOneWidget);
    expect(find.textContaining('KAZ'), findsWidgets);
    expect(find.text('SIFIRLA'), findsOneWidget);

    // Mağaza butonuna tıklama testi
    await tester.tap(find.text('MAĞAZA'));
    await tester.pumpAndSettle();

    // Dialog açıldı mı?
    expect(find.text('MAĞAZA & YÜKSELTMELER'), findsOneWidget);

    // Temizlik
    container.dispose();
  });
}
