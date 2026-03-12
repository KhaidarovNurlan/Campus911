import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:campus911/pages/register.dart';
import 'package:campus911/data/providers.dart';
import 'package:campus911/data/services.dart';

class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late MockFirebaseService mockFirebase;

  setUp(() {
    mockFirebase = MockFirebaseService();
    when(() => mockFirebase.isHeadmanTaken(any(), any()))
        .thenAnswer((_) async => false);
  });

  Widget createRegisterScreen() {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => UserProvider(firebase: mockFirebase),
        child: const RegisterScreen(),
      ),
    );
  }

  group('Register screen UI Tests', () {

    testWidgets('Should show validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      final registerButton = find.text('Create an account');
      await tester.tap(registerButton, warnIfMissed: false);

      await tester.pump();

      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('Changing college should update groups list', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      expect(find.text('AITU'), findsOneWidget);

      await tester.tap(find.text('AITU'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('KILC').last);
      await tester.pumpAndSettle();

      expect(find.text('K-1'), findsOneWidget);
    });

    testWidgets('Tapping Headman card should select it', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      final headmanCard = find.text('Headman');
      await tester.tap(headmanCard);
      await tester.pump();

      expect(find.text('👑'), findsOneWidget);
    });
  });
}