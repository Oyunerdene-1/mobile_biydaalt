import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'feature_pages.dart';
import 'finance_models.dart';
import 'finance_store.dart';

void main() => runApp(const MyApp());

const brand = Color(0xFF5D43C8);
const ink = Color(0xFF25213A);
const canvas = Color(0xFFF7F6FA);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Мөнгө Зөв',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brand, primary: brand),
      scaffoldBackgroundColor: canvas,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F8FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    home: const FinanceShell(),
  );
}

class FinanceShell extends StatefulWidget {
  const FinanceShell({super.key});
  @override
  State<FinanceShell> createState() => _FinanceShellState();
}

class _FinanceShellState extends State<FinanceShell> {
  final FinanceStore store = FinanceStore();
  int selected = 0;
  static const destinations = [
    ('Нүүр', Icons.dashboard_outlined),
    ('Гүйлгээ', Icons.receipt_long_outlined),
    ('Төсөв', Icons.pie_chart_outline),
    ('Зорилго', Icons.track_changes_outlined),
    ('AI зөвлөх', Icons.chat_bubble_outline),
    ('Профайл', Icons.person_outline),
  ];

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  void navigate(int index) => setState(() => selected = index);

  Future<void> addTransaction([FinanceEntry? existing]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => TransactionEditor(store: store, existing: existing),
    );
  }

  Future<void> addGoal() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => GoalEditor(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 850;
    final page = AnimatedBuilder(
      animation: store,
      builder: (context, _) => switch (selected) {
        0 => DashboardPage(
          store: store,
          onAddTransaction: () => addTransaction(),
          onNavigate: navigate,
        ),
        1 => TransactionsPage(
          store: store,
          onAdd: () => addTransaction(),
          onEdit: addTransaction,
        ),
        2 => BudgetPage(store: store),
        3 => GoalsPage(store: store, onAdd: addGoal),
        4 => AdvisorPage(store: store),
        _ => const ProfilePage(),
      },
    );
    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              toolbarHeight: 58,
              leading: Builder(
                builder: (context) => IconButton(
                  tooltip: 'Цэс нээх',
                  icon: const Icon(Icons.menu, color: ink),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: const Text(
                'Мөнгө Зөв',
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Мэдэгдэл',
                  icon: const Icon(Icons.notifications_none, color: ink),
                  onPressed: _showNotifications,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 16),
                  child: IconButton(
                    tooltip: 'Профайл',
                    onPressed: () => navigate(5),
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF3D2D74),
                      child: Text(
                        'Б',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      drawer: isWide ? null : _mobileDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) _sidebar(),
            Expanded(
              child: Column(
                children: [
                  if (isWide) _topbar(),
                  Expanded(child: page),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              height: 68,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFEDE9FF),
              selectedIndex: switch (selected) {
                3 => 2,
                4 => 3,
                5 => 4,
                2 => 0,
                _ => selected,
              },
              onDestinationSelected: (index) =>
                  navigate([0, 1, 3, 4, 5][index]),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Нүүр',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Гүйлгээ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.track_changes_outlined),
                  selectedIcon: Icon(Icons.track_changes),
                  label: 'Зорилго',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: 'AI зөвлөх',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Профайл',
                ),
              ],
            ),
    );
  }

  void _showNotifications() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Мэдэгдэл'),
        content: const Text(
          'Одоогоор шинэ мэдэгдэл алга. Төсвийн явцыг цэснээс харж болно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Хаах'),
          ),
        ],
      ),
    );
  }

  Widget _mobileDrawer() => Drawer(
    backgroundColor: const Color(0xFF18132F),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 28, 20, 28),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: brand,
                  child: Text(
                    '₮',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Мөнгө Зөв',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Санхүүгээ ухаалгаар',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFAAA5BB),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(destinations.length, (index) {
            final item = destinations[index];
            final active = selected == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                tileColor: active ? brand : Colors.transparent,
                leading: Icon(
                  item.$2,
                  color: active ? Colors.white : const Color(0xFFAAA5BB),
                ),
                title: Text(
                  item.$1,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFFAAA5BB),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  navigate(index);
                },
              ),
            );
          }),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(22),
            child: Text(
              '●  DEMO ОРЧИН',
              style: TextStyle(color: Color(0xFF8BD0A6), fontSize: 11),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sidebar() => Container(
    width: 254,
    color: const Color(0xFF18132F),
    padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: brand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '₮',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мөнгө Зөв',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Санхүүгээ ухаалгаар',
                  style: TextStyle(color: Color(0xFFAAA5BB), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 38),
        const Text(
          'ҮНДСЭН ЦЭС',
          style: TextStyle(
            color: Color(0xFF817B98),
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(destinations.length, (index) {
          final item = destinations[index];
          final active = selected == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: active ? brand : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => navigate(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.$2,
                        color: active ? Colors.white : const Color(0xFFAAA5BB),
                        size: 20,
                      ),
                      const SizedBox(width: 13),
                      Text(
                        item.$1,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xFFAAA5BB),
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF241E40),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFA996FF)),
              SizedBox(height: 12),
              Text(
                '7 хоногийн цуврал',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Өнөөдөр гүйлгээгээ бүртгээрэй',
                style: TextStyle(color: Color(0xFFAAA5BB), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '●  DEMO ОРЧИН',
          style: TextStyle(color: Color(0xFF8BD0A6), fontSize: 11),
        ),
      ],
    ),
  );

  Widget _topbar() => Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFEDEBF1))),
    ),
    child: const Row(
      children: [
        Icon(Icons.search, color: Colors.grey),
        SizedBox(width: 10),
        Text(
          'Гүйлгээ, зорилгоо хянах...',
          style: TextStyle(color: Colors.grey),
        ),
        Spacer(),
        Text(
          '● Demo өгөгдөл',
          style: TextStyle(color: Color(0xFF52B58A), fontSize: 12),
        ),
        SizedBox(width: 22),
        CircleAvatar(
          backgroundColor: Color(0xFF3D2D74),
          child: Text('Б', style: TextStyle(color: Colors.white)),
        ),
        SizedBox(width: 9),
        Text('Бат-Эрдэнэ', style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
