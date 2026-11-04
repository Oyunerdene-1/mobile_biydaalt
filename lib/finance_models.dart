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
    this.deadlineDate,
    this.isPriority = false,
  });

  final String id;
  final String title;
  final int target;
  final int saved;
  final String deadline;
  final String emoji;
  final DateTime? deadlineDate;
  final bool isPriority;

  double get progress => target <= 0 ? 0 : (saved / target).clamp(0, 1);
  int get remaining => (target - saved).clamp(0, target);
  int monthlyNeeded([DateTime? today]) {
    if (remaining == 0) return 0;
    final now = today ?? DateTime.now();
    final months = deadlineDate == null
        ? 6
        : ((deadlineDate!.year - now.year) * 12 +
                  deadlineDate!.month -
                  now.month)
              .clamp(1, 1200);
    return (remaining / months).ceil();
  }

  SavingsGoal withSaved(int value) => SavingsGoal(
    id: id,
    title: title,
    target: target,
    saved: value,
    deadline: deadline,
    emoji: emoji,
    deadlineDate: deadlineDate,
    isPriority: isPriority,
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
