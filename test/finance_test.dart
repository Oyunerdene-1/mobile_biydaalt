import 'package:biydaalt/finance_models.dart';
import 'package:biydaalt/finance_store.dart';
import 'package:biydaalt/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MNT formatting and totals use whole numbers', () {
    expect(formatMoney(1250000), '1,250,000 ₮');
    expect(formatMoney(-186400), '−186,400 ₮');
    final store = FinanceStore();
    expect(store.income, 3850000);
    expect(store.expenses, 267100);
    expect(store.balance, 3582900);
    store.saveEntry(
      FinanceEntry(
        id: 'new',
        title: 'Шинэ зарлага',
        category: 'Хүнс',
        amount: -10000,
        date: DateTime(2025, 6, 15),
      ),
    );
    expect(store.expenses, 277100);
    store.deleteEntry('new');
    expect(store.expenses, 267100);
  });

  testWidgets('Home renders and bottom navigation opens transactions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Өглөөний мэнд, Бат-Эрдэнэ'), findsOneWidget);
    expect(find.text('3,582,900 ₮'), findsWidgets);
    await tester.tap(find.byIcon(Icons.receipt_long_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('Орлого, зарлагаа нэг дороос хянаарай.'), findsOneWidget);
  });

  testWidgets('Mobile app bar opens menu, notifications, and profile', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byTooltip('Цэс нээх'), findsOneWidget);
    expect(find.byTooltip('Мэдэгдэл'), findsOneWidget);
    expect(find.byTooltip('Профайл'), findsWidgets);

    await tester.tap(find.byTooltip('Цэс нээх'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Төсөв').last);
    await tester.pumpAndSettle();
    expect(find.text('Ангилал бүрийн зарцуулалтаа хянаарай.'), findsOneWidget);

    await tester.tap(find.byTooltip('Мэдэгдэл'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Одоогоор шинэ мэдэгдэл алга. Төсвийн явцыг цэснээс харж болно.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Хаах'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Профайл').first);
    await tester.pumpAndSettle();
    expect(find.text('Demo орчны мэдээлэл'), findsOneWidget);
  });
}
