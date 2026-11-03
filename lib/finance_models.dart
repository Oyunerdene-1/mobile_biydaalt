class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMethod = 'Карт',
  });

  final String id;
  final String title;
  final String category;
  final int amount; // Positive for income, negative for expense.
  final DateTime date;
  final String paymentMethod;

  bool get isIncome => amount > 0;
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.title,
    required this.target,
    required this.saved,
    required this.deadline,
    this.emoji = '🎯',
  });

  final String id;
  final String title;
  final int target;
  final int saved;
  final String deadline;
  final String emoji;

  double get progress => target <= 0 ? 0 : (saved / target).clamp(0, 1);
  int get remaining => (target - saved).clamp(0, target);

  SavingsGoal withSaved(int value) => SavingsGoal(
    id: id,
    title: title,
    target: target,
    saved: value,
    deadline: deadline,
    emoji: emoji,
  );
}

String formatMoney(int value, {bool sign = false}) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  final prefix = value < 0 ? '−' : (sign && value > 0 ? '+' : '');
  return '$prefix${buffer.toString()} ₮';
}
