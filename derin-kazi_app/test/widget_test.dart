import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/main.dart';

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
    expect(find.text('YERALTI SAVAŞLARI'), findsOneWidget);
    expect(find.textContaining('OYUNA BAŞLA'), findsOneWidget);
    expect(find.textContaining('SİLAH & MERMİ MAĞAZASI'), findsOneWidget);
    expect(find.textContaining('ATÖLYE & GÜÇLENDİRME'), findsOneWidget);

    // Oyuna Başla'ya tıkla (Bölüm Seçim Ekranı Açılır)
    await tester.tap(find.textContaining('OYUNA BAŞLA'));
    await tester.pumpAndSettle();

    expect(find.text('BÖLÜM SEÇİMİ'), findsOneWidget);

    // Hızlı Devam Et'e tıkla ve oyuna başla
    await tester.tap(find.textContaining('DEVAM ET'));
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

