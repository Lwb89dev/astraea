import 'dart:convert';

import 'package:astraea/l10n/app_localizations.dart';
import 'package:astraea/screens/onboarding_screen.dart';
import 'package:astraea/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('first launch shows onboarding and suggested relays', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Astraea'), findsOneWidget);

    final pages = find.byType(PageView);
    await tester.drag(pages, const Offset(-700, 0));
    await tester.pumpAndSettle();
    await tester.drag(pages, const Offset(-700, 0));
    await tester.pumpAndSettle();

    expect(find.text('Choose relays for synchronization'), findsOneWidget);
    expect(find.text('nos.lol'), findsOneWidget);
    expect(find.text('relay.damus.io'), findsOneWidget);
    expect(find.text('Selected'), findsNothing);

    final nosLolTile = find.ancestor(
      of: find.text('nos.lol'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: nosLolTile, matching: find.byType(IconButton)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selected'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString(AppConstants.prefsRelaysKey)!), [
      'wss://nos.lol',
    ]);
  });
}
