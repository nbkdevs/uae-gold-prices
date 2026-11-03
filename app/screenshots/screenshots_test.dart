// Renders real app screens to PNG for the store listings.
// Run: flutter test screenshots/screenshots_test.dart  (writes ../store-assets/app/raw/*.png)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uae_gold_calculator/main.dart';
import 'package:uae_gold_calculator/state.dart';

Future<void> _font(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) {
    l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await l.load();
}

const _root = Key('root');

void main() {
  final out = Directory('../store-assets/app/raw')..createSync(recursive: true);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/sdk/flutter';
  const cairo = '/usr/share/fonts/truetype/sand-box/google/Cairo/Cairo-VariableFont_slnt,wght.ttf';

  setUpAll(() async {
    await _font('Roboto', [cairo]);
    await _font('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  Future<void> shoot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final rb = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
    final bytes = await tester.runAsync(() async {
      final img = await rb.toImage(pixelRatio: tester.view.devicePixelRatio);
      return img.toByteData(format: ui.ImageByteFormat.png);
    });
    File('${out.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  for (final size in [const Size(1080, 1920), const Size(800, 1280)]) {
    for (final ar in [true, false]) {
      final tag = '${ar ? 'ar' : 'en'}-${size.width.toInt()}x${size.height.toInt()}';
      testWidgets('screens $tag', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = size.width == 1080 ? 2.625 : 2.0;
        addTearDown(tester.view.reset);
        final st = AppState(null)
          ..ar = ar
          ..priceText = '461.11';
        await tester.pumpWidget(RepaintBoundary(key: _root, child: GoldApp(state: st)));
        await shoot(tester, '1-karats-$tag');

        await tester.tap(find.byIcon(Icons.diamond_outlined));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('itemMaking')), '30');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        FocusManager.instance.primaryFocus?.unfocus();
        await shoot(tester, '2-item-$tag');

        await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('addItem')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('zw1')), '25');
        FocusManager.instance.primaryFocus?.unfocus();
        await shoot(tester, '3-zakat-$tag');

        await tester.tap(find.byIcon(Icons.swap_horiz).last);
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('convValue')), '2');
        FocusManager.instance.primaryFocus?.unfocus();
        await shoot(tester, '4-units-$tag');

        await tester.tap(find.byKey(const Key('aboutButton')));
        await shoot(tester, '5-about-$tag');
      });
    }
  }
}
