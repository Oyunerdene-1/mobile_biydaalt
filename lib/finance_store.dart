import 'package:flutter/foundation.dart';

import 'finance_models.dart';

class FinanceStore extends ChangeNotifier {
  final List<FinanceEntry> _entries = [
    FinanceEntry(
      id: '1',
      title: 'Цалин',
      category: 'Орлого',
      amount: 3200000,
      date: DateTime(2025, 6, 14),
      paymentMethod: 'Хаан банк',
    ),
    FinanceEntry(
      id: '2',
      title: 'Номин супермаркет',
      category: 'Хүнс',
      amount: -186400,
      date: DateTime(2025, 6, 13),
    ),
    FinanceEntry(
      id: '3',
      title: 'UBCab',
      category: 'Тээвэр',
      amount: -18400,
      date: DateTime(2025, 6, 12),
      paymentMethod: 'QPay',
    ),
    FinanceEntry(
      id: '4',
      title: 'Unitel',
      category: 'Төлбөр',
      amount: -45500,
      date: DateTime(2025, 6, 11),
      paymentMethod: 'Автомат',
    ),
    FinanceEntry(
      id: '5',
      title: 'Coffee Fellows',
      category: 'Хүнс',
      amount: -16800,
      date: DateTime(2025, 6, 10),
    ),
    FinanceEntry(
      id: '6',
      title: 'Фриланс төсөл',
      category: 'Нэмэлт орлого',
      amount: 650000,
      date: DateTime(2025, 6, 8),
      paymentMethod: 'Шилжүүлэг',
    ),
  ];

  final List<SavingsGoal> _goals = [
    const SavingsGoal(
      id: '1',
      title: 'Япон руу аялах',
      target: 3000000,
      saved: 900000,
      deadline: '2026 оны 3 сар',
      emoji: '✈️',
    ),
    const SavingsGoal(
      id: '2',
      title: 'Гэнэтийн сан',
      target: 5000000,
      saved: 2400000,
      deadline: '2026 оны 6 сар',
      emoji: '🛟',
    ),
    const SavingsGoal(
      id: '3',
      title: 'Шинэ компьютер',
      target: 3600000,
      saved: 1800000,
      deadline: '2025 оны 12 сар',
      emoji: '💻',
    ),
  ];

  List<FinanceEntry> get entries => List.unmodifiable(_entries);
  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  int get income =>
      _entries.where((e) => e.isIncome).fold(0, (sum, e) => sum + e.amount);
  int get expenses =>
      _entries.where((e) => !e.isIncome).fold(0, (sum, e) => sum - e.amount);
  int get balance => income - expenses;
  int get savingsRate =>
      income == 0 ? 0 : ((balance / income) * 100).round().clamp(0, 100);

  int spentIn(String category) => _entries
      .where((e) => !e.isIncome && e.category == category)
      .fold(0, (sum, e) => sum - e.amount);

  Map<String, int> get expenseCategories {
    final result = <String, int>{};
    for (final entry in _entries.where((e) => !e.isIncome)) {
      result.update(
        entry.category,
        (value) => value - entry.amount,
        ifAbsent: () => -entry.amount,
      );
    }
    return result;
  }

  void saveEntry(FinanceEntry entry) {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _entries.insert(0, entry);
    } else {
      _entries[index] = entry;
    }
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  void addGoal(SavingsGoal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void addContribution(String id, int amount) {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index < 0 || amount <= 0) return;
    final goal = _goals[index];
    _goals[index] = goal.withSaved((goal.saved + amount).clamp(0, goal.target));
    notifyListeners();
  }

  void deleteGoal(String id) {
    _goals.removeWhere((goal) => goal.id == id);
    notifyListeners();
  }
}
