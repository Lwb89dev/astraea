import 'package:astraea/utils/app_accent.dart';
import 'package:astraea/widgets/astraea_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an unset accent is bitcoin orange', () {
    expect(AppAccent.fromPrefsValue(null), AppAccent.bitcoin);
    expect(AppAccent.fromPrefsValue(''), AppAccent.bitcoin);
    expect(AppAccent.fromPrefsValue('nope'), AppAccent.bitcoin);
    expect(AppAccent.fromPrefsValue('navy'), AppAccent.navy);
    expect(AppAccent.fromPrefsValue('bitcoin').seed, const Color(0xFFF7931A));
  });

  test('a sheet gloss is a vertical gradient, not a flat fill', () {
    const tints = [AstraeaTokens.iris, AstraeaTokens.coral, Color(0xFF2196F3)];
    for (final tint in tints) {
      final gradient = astraeaSheetGradient(tint);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors.last, tint);
      expect(gradient.colors.first, isNot(tint));
    }
  });

  test(
    'a bright blue event deepens on the night desk until white type fits',
    () {
      const blue = Color(0xFF2196F3);
      final paint = astraeaDarkTint(blue);
      final gradient = astraeaSheetGradient(paint);
      expect(readableTextColorOn(paint), Colors.white);
      expect(
        _ratio(gradient.colors.first, Colors.white),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _ratio(gradient.colors.last, Colors.white),
        greaterThanOrEqualTo(4.5),
      );
      expect(astraeaDarkTint(AstraeaTokens.iris), AstraeaTokens.iris);
    },
  );

  test('iris takes light ink and coral takes dark ink', () {
    expect(readableTextColorOn(AstraeaTokens.iris), Colors.white);
    expect(readableTextColorOn(AstraeaTokens.coral), Colors.black);
    expect(_ratio(AstraeaTokens.iris, Colors.white), greaterThanOrEqualTo(4.5));
    expect(
      _ratio(AstraeaTokens.coral, Colors.black),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('opening a sheet uses the card gloss, and only frost blurs', (
    tester,
  ) async {
    const tint = AstraeaTokens.iris;
    await tester.pumpWidget(
      MaterialApp(
        theme: astraeaTheme(brightness: Brightness.light, seed: tint),
        home: const Scaffold(
          body: Stack(
            children: [
              AstraeaBackdrop(),
              Column(
                children: [
                  AstraeaGlassSurface(frosted: true, child: Text('Month')),
                  AstraeaGlassSurface(
                    key: Key('card'),
                    tint: tint,
                    shadow: false,
                    child: Text('Standup'),
                  ),
                  AstraeaSheet(
                    key: Key('sheet'),
                    tint: tint,
                    child: SizedBox(height: 40, width: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      _gradient(tester, find.byKey(const Key('card'))),
      astraeaSheetGradient(tint),
    );
    expect(
      _gradient(tester, find.byKey(const Key('sheet'))),
      astraeaSheetGradient(tint),
    );
    final backdrop = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AstraeaBackdrop),
        matching: find.byType(DecoratedBox),
      ),
    );
    final painted = backdrop.decoration as BoxDecoration;
    expect(painted.gradient, isA<LinearGradient>());
    expect(
      (painted.gradient! as LinearGradient).colors,
      AstraeaPalette.light.glow,
    );
  });

  test('night ink clears the brightest aurora stop', () {
    final ink = AstraeaPalette.dark.ink;
    var brightest = AstraeaPalette.dark.glow.first;
    for (final stop in AstraeaPalette.dark.glow) {
      if (stop.computeLuminance() > brightest.computeLuminance()) {
        brightest = stop;
      }
    }
    expect(_ratio(brightest, ink), greaterThanOrEqualTo(7));
  });

  testWidgets(
    'a blue sheet in the dark theme writes the description in light ink',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: astraeaTheme(
            brightness: Brightness.dark,
            seed: AppAccent.navy.seed,
          ),
          home: Scaffold(
            body: AstraeaSheet(
              tint: const Color(0xFF2196F3),
              child: Scaffold(
                body: Builder(
                  builder: (context) => Text(
                    'Descrizione',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final element = tester.element(find.text('Descrizione'));
      final painted = (element.widget as Text).style?.color;
      final gradient = _gradient(tester, find.byType(AstraeaSheet));
      expect(painted, isNotNull);
      expect(painted!.computeLuminance(), greaterThan(0.5));
      expect(_ratio(gradient.colors.first, painted), greaterThanOrEqualTo(4.5));
      expect(_ratio(gradient.colors.last, painted), greaterThanOrEqualTo(4.5));
    },
  );
}

Gradient _gradient(WidgetTester tester, Finder host) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: host, matching: find.byType(DecoratedBox)).first,
  );
  final decoration = box.decoration as BoxDecoration;
  return decoration.gradient!;
}

double _ratio(Color background, Color ink) {
  final lighter = background.computeLuminance() > ink.computeLuminance()
      ? background.computeLuminance()
      : ink.computeLuminance();
  final darker = background.computeLuminance() > ink.computeLuminance()
      ? ink.computeLuminance()
      : background.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
