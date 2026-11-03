import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uae_gold_calculator/app_info.dart';
import 'package:uae_gold_calculator/main.dart';
import 'package:uae_gold_calculator/state.dart';

void main() {
  testWidgets('Arabic first, karat table and item total', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final st = AppState(null);
    await tester.pumpWidget(GoldApp(state: st));
    expect(find.text('حاسبة قيمة الذهب'), findsWidgets);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.rtl,
    );

    await tester.enterText(find.byKey(const Key('priceField')), '461.11');
    await tester.pump();
    expect(find.byKey(const Key('k21g')), findsOneWidget);
    expect(find.text('403.41'), findsWidgets);

    await tester.tap(find.text('سعر القطعة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('itemMaking')), '30');
    await tester.pump();
    expect(find.text('4,550.84 د.إ'), findsOneWidget);
  });

  testWidgets('English toggle, zakat and about link', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final st = AppState(null);
    await tester.pumpWidget(GoldApp(state: st));
    await tester.tap(find.byKey(const Key('langToggle')));
    await tester.pumpAndSettle();
    expect(find.text('Gold Value Calculator'), findsWidgets);
    await tester.enterText(find.byKey(const Key('priceField')), '461.11');
    await tester.tap(find.text('Zakat'));
    await tester.pumpAndSettle();
    expect(find.text('1,008.53 AED'), findsOneWidget);

    await tester.tap(find.byKey(const Key('aboutButton')));
    await tester.pumpAndSettle();
    expect(find.text(AppInfo.siteAnchor), findsOneWidget);
    expect(AppInfo.siteUrl, 'https://uaegoldprices.ae/');
  });
}
