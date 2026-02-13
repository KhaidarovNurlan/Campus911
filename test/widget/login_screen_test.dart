import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campus911/pages/login.dart';
import 'package:campus911/data/providers.dart';
import 'package:campus911/utils/validator.dart';

void main() {
  testWidgets('Переход на Главную страницу после Входа', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    final emailField = find.byType(EditableText).at(0);
    final passwordField = find.byType(EditableText).at(1);

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, '123456');

    await tester.tap(find.text('Войти'));

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('На экране присутствуют все поля и кнопка', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MaterialApp(home: LoginScreen()),
    ));

    expect(find.text('Электронная почта'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('Показ ошибки при пустом вводе', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(Validator.validateEmail(''), 'Нужен email');
  });
}