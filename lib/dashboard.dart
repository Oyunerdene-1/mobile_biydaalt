import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'finance_models.dart';
import 'finance_store.dart';
import 'main.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final String eyebrow, title, subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 16,
    runSpacing: 16,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.6,
              color: brand,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(
              fontSize: MediaQuery.sizeOf(context).width < 550 ? 22 : 28,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF8A8798), fontSize: 13),
          ),
        ],
      ),
      ?action,
    ],
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.store,
    required this.onAddTransaction,
    required this.onNavigate,
  });
  final FinanceStore store;
  final VoidCallback onAddTransaction;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 680;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.all(mobile ? 16 : 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeading(
                  eyebrow: 'DEMO · 2025 ОНЫ 6 САР',
                  title: 'Өглөөний мэнд, Бат-Эрдэнэ',
                  subtitle: 'Таны санхүүгийн тойм нэг дор.',
                  action: FilledButton.icon(
                    onPressed: onAddTransaction,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Гүйлгээ нэмэх'),
                    style: FilledButton.styleFrom(
                      backgroundColor: brand,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 19,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, bounds) {
                    final columns = bounds.maxWidth < 650 ? 2 : 4;
                    final width =
                        (bounds.maxWidth - 16 * (columns - 1)) / columns;
                    final stats = [
                      (
                        'Нийт үлдэгдэл',
                        formatMoney(store.balance),
                        Icons.account_balance_wallet_outlined,
                        const Color(0xFFEEE9FC),
                      ),
                      (
                        'Энэ сарын орлого',
                        formatMoney(store.income),
                        Icons.south_west,
                        const Color(0xFFE7F6EF),
                      ),
                      (
                        'Энэ сарын зарлага',
                        formatMoney(store.expenses),
                        Icons.north_east,
                        const Color(0xFFFFF3E7),
                      ),
                      (
                        'Хуримтлалын хувь',
                        '${store.savingsRate}%',
                        Icons.trending_up,
                        const Color(0xFFEAF2FF),
                      ),
                    ];
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: stats
                          .map(
                            (stat) => SizedBox(
                              width: width,
                              child: AppPanel(
                                padding: const EdgeInsets.all(17),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            stat.$1,
                                            style: const TextStyle(
                                              color: Color(0xFF8A8798),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: stat.$4,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          child: Icon(
                                            stat.$3,
                                            color: brand,
                                            size: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        stat.$2,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '● Demo өгөгдөл',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF67AA8A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, bounds) {
                    final wide = bounds.maxWidth >= 810;
                    final chart = _cashFlowCard();
                    final discipline = _disciplineCard();
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 7, child: chart),
                              const SizedBox(width: 18),
                              Expanded(flex: 3, child: discipline),
                            ],
                          )
                        : Column(
                            children: [
                              chart,
                              const SizedBox(height: 18),
                              discipline,
                            ],
                          );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, bounds) {
                    final wide = bounds.maxWidth >= 810;
                    final categories = _categoryCard();
                    final budgets = _budgetCard();
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: categories),
                              const SizedBox(width: 18),
                              Expanded(child: budgets),
                            ],
                          )
                        : Column(
                            children: [
                              categories,
                              const SizedBox(height: 18),
                              budgets,
                            ],
                          );
                  },
                ),
                const SizedBox(height: 18),
                _recentCard(),
                const SizedBox(height: 18),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: brand),
                          SizedBox(width: 9),
                          Text(
                            'Санхүүгийн зөвлөх',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AI үйлчилгээ холбогдоогүй. Бүртгэсэн гүйлгээнд тулгуурласан энгийн дүн шинжилгээг үзээрэй.',
                        style: TextStyle(color: Color(0xFF777385), height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => onNavigate(4),
                        child: const Text('Зөвлөхийг нээх →'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cashFlowCard() => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мөнгөний урсгал',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Орлого, зарлагын хөдөлгөөн',
                    style: TextStyle(color: Color(0xFF8A8798), fontSize: 11),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onNavigate(1),
              child: const Text('Дэлгэрэнгүй ›'),
            ),
          ],
        ),
        const SizedBox(height: 17),
        const Row(
          children: [
            Icon(Icons.circle, size: 9, color: brand),
            SizedBox(width: 5),
            Text('Орлого', style: TextStyle(fontSize: 11)),
            SizedBox(width: 18),
            Icon(Icons.circle, size: 9, color: Color(0xFFE0A65C)),
            SizedBox(width: 5),
            Text('Зарлага', style: TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 205,
          width: double.infinity,
          child: CustomPaint(painter: CashFlowPainter(store.entries)),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('5', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('10', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('15', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('20', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('25', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('30', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _disciplineCard() => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Сахилга бат',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 26),
        Center(
          child: SizedBox(
            width: 138,
            height: 138,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: .78,
                    strokeWidth: 10,
                    backgroundColor: Color(0xFFE9E6F3),
                    color: brand,
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '78',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'DEMO / 100',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 21),
        const Center(
          child: Text(
            'Ухаалаг хэрэглэгч',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 7),
        const Center(
          child: Text(
            'Жишээ оноо · бодит үнэлгээ биш',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
        const Divider(height: 31),
        const Row(
          children: [
            Icon(Icons.check, size: 15, color: Color(0xFF74AD93)),
            SizedBox(width: 5),
            Expanded(
              child: Text('Төсөв баримтлалт', style: TextStyle(fontSize: 11)),
            ),
            Text(
              'Сайн',
              style: TextStyle(fontSize: 11, color: Color(0xFF74AD93)),
            ),
          ],
        ),
        const SizedBox(height: 13),
        const Row(
          children: [
            Icon(Icons.bolt, size: 15, color: Color(0xFF9B8AB8)),
            SizedBox(width: 5),
            Expanded(child: Text('Хуримтлал', style: TextStyle(fontSize: 11))),
            Text(
              'Сайжирч байна',
              style: TextStyle(fontSize: 11, color: Color(0xFF74AD93)),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _categoryCard() {
    final categories = store.expenseCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Зарлагын бүтэц',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Бүртгэсэн гүйлгээгээр',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 146,
              height: 146,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CustomPaint(
                      painter: CategoryRingPainter(
                        categories.map((e) => e.value).toList(),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatMoney(store.expenses),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Нийт зарлага',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            const Text('Одоогоор зарлага бүртгэгдээгүй байна.'),
          ...categories
              .take(4)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: brand, size: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.key,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '${store.expenses == 0 ? 0 : (item.value * 100 / store.expenses).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _budgetCard() {
    const limits = [
      ('Хүнс', 750000, '🍜'),
      ('Тээвэр', 350000, '🚕'),
      ('Худалдан авалт', 450000, '🛍'),
    ];
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Төсвийн явц',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(2),
                child: const Text('Бүгдийг харах'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...limits.map((item) {
            final spent = store.spentIn(item.$1);
            final progress = (spent / item.$2).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(item.$3),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: brand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${formatMoney(spent)} / ${formatMoney(item.$2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(9),
                    backgroundColor: const Color(0xFFEEEAF7),
                    color: progress >= .9 ? const Color(0xFFE7A563) : brand,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _recentCard() {
    final latest = [...store.entries]..sort((a, b) => b.date.compareTo(a.date));
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Сүүлийн гүйлгээ',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(1),
                child: const Text('Бүгдийг харах'),
              ),
            ],
          ),
          if (latest.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Одоогоор гүйлгээ бүртгэгдээгүй байна.'),
            ),
          ...latest
              .take(5)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: entry.isIncome
                            ? const Color(0xFFE9F7F0)
                            : const Color(0xFFFFF0F2),
                        child: Icon(
                          entry.isIncome ? Icons.south_west : Icons.north_east,
                          size: 17,
                          color: entry.isIncome
                              ? const Color(0xFF58A882)
                              : const Color(0xFFD77887),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${entry.category} · ${entry.paymentMethod}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatMoney(entry.amount, sign: true),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: entry.isIncome
                                  ? const Color(0xFF529B78)
                                  : ink,
                            ),
                          ),
                          Text(
                            '${entry.date.month}/${entry.date.day}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class CashFlowPainter extends CustomPainter {
  CashFlowPainter(this.entries);
  final List<FinanceEntry> entries;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFEDEBF2)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final days = List<int>.filled(30, 0);
    for (final entry in entries.where(
      (e) => e.amount < 0 && e.date.month == 6,
    )) {
      if (entry.date.day <= 30) days[entry.date.day - 1] += -entry.amount;
    }
    final smooth = List<double>.generate(30, (i) {
      var sum = 0;
      for (var j = math.max(0, i - 3); j <= math.min(29, i + 3); j++) {
        sum += days[j];
      }
      return sum / 7;
    });
    final maxValue = math.max(30000.0, smooth.reduce(math.max));
    final path = Path();
    for (var i = 0; i < 30; i++) {
      final x = size.width * i / 29;
      final y = size.height * (.82 - .65 * smooth[i] / maxValue);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x335D43C8), Color(0x005D43C8)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = brand
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CashFlowPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class CategoryRingPainter extends CustomPainter {
  CategoryRingPainter(this.values);
  final List<int> values;
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      brand,
      Color(0xFF9A81E6),
      Color(0xFFE8AB65),
      Color(0xFF8EC9B1),
      Color(0xFFBBC1D6),
    ];
    final total = values.fold(0, (a, b) => a + b);
    final rect = Rect.fromLTWH(7, 7, size.width - 14, size.height - 14);
    var start = -math.pi / 2;
    if (total == 0) {
      canvas.drawArc(
        rect,
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = const Color(0xFFEDEBF2)
          ..strokeWidth = 17
          ..style = PaintingStyle.stroke,
      );
      return;
    }
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..strokeWidth = 17
          ..style = PaintingStyle.stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CategoryRingPainter oldDelegate) =>
      oldDelegate.values != values;
}
