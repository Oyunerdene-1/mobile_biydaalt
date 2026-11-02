import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Management',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final String date;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.icon,
  });
}

class SavingsGoal {
  final String id;
  final String title;
  final String deadline;
  final double targetAmount;
  double currentAmount;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.deadline,
    required this.targetAmount,
    required this.currentAmount,
  });

  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1;

  final Color primaryColor = const Color(0xFF500071);
  final Color darkGradientColor = const Color(0xFF290044);

  final List<Transaction> _transactions = [];
  String _transactionFilter = 'Бүгд';
  final List<SavingsGoal> _goals = [];

  double get totalIncome => _transactions
      .where((item) => item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((item) => !item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netBalance => totalIncome - totalExpense;

  List<Transaction> get filteredTransactions {
    if (_transactionFilter == 'Орлого') {
      return _transactions.where((t) => t.isIncome).toList();
    } else if (_transactionFilter == 'Зарлага') {
      return _transactions.where((t) => !t.isIncome).toList();
    }
    return _transactions;
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Гүйлгээ нэмэх",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: "Гүйлгээний нэр (ж: Цалин)",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                        labelText: "Төрөл (ж: Хүнс, Цалин)",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Дүн (₮)", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Орлого"),
                        selected: isIncome,
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                            color: isIncome ? Colors.white : Colors.black),
                        onSelected: (selected) =>
                            setModalState(() => isIncome = true),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Зарлага"),
                        selected: !isIncome,
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                            color: !isIncome ? Colors.white : Colors.black),
                        onSelected: (selected) =>
                            setModalState(() => isIncome = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () {
                        if (titleController.text.isEmpty ||
                            amountController.text.isEmpty) return;
                        setState(() {
                          _transactions.add(Transaction(
                            id: DateTime.now().toString(),
                            title: titleController.text,
                            category: categoryController.text.isEmpty
                                ? 'Бусад'
                                : categoryController.text,
                            amount: double.parse(amountController.text),
                            isIncome: isIncome,
                            date: "Өнөөдөр",
                            icon: isIncome
                                ? Icons.arrow_downward
                                : Icons.shopping_bag_outlined,
                          ));
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text("Хадгалах",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();
    final targetController = TextEditingController();
    final initialAmountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Шинэ зорилго үүсгэх",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: "Зорилгын нэр (ж: Япон руу аялах)",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(
                    labelText: "Хүрэх хугацаа (ж: 2026.03)",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Зорилтот дүн (₮)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: initialAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Эхний хуримтлуулсан дүн (₮)",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        targetController.text.isEmpty) return;
                    setState(() {
                      _goals.add(SavingsGoal(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        deadline: deadlineController.text.isEmpty
                            ? 'Тодорхойгүй'
                            : deadlineController.text,
                        targetAmount: double.parse(targetController.text),
                        currentAmount: initialAmountController.text.isEmpty
                            ? 0.0
                            : double.parse(initialAmountController.text),
                      ));
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Хадгалах",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddDepositDialog(SavingsGoal goal) {
    final depositController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("\"${goal.title}\"-д хуримтлал нэмэх",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Нэмэх дүн (₮)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    if (depositController.text.isEmpty) return;
                    setState(() {
                      goal.currentAmount += double.parse(depositController.text);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Нэмэх",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, darkGradientColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.white),
                          onPressed: () {}),
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text("мөнгөний урсгал",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Гүйлгээ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    onPressed: _showAddTransactionDialog,
                    child: Icon(Icons.add, color: primaryColor),
                  )
                ],
              ),
              const Text("Орлого, зарлагаа нэг дороос хянаарай.",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Нийт орлого",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("+${totalIncome.toStringAsFixed(0)} ₮",
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      const Text("Нийт зарлага",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("-${totalExpense.toStringAsFixed(0)} ₮",
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      const Text("Цэвэр мөнгөн урсгал",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("${netBalance.toStringAsFixed(0)} ₮",
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Бүгд', 'Орлого', 'Зарлага'].map((type) {
                    final isSelected = _transactionFilter == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: isSelected ? primaryColor : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal),
                        onSelected: (selected) =>
                            setState(() => _transactionFilter = type),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                filteredTransactions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            const Text(
                              "Гүйлгээ одоогоор байхгүй байна.\n'+' товчийг дарж нэмнэ үү.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final item = filteredTransactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: item.isIncome
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                child: Icon(item.icon,
                                    color: item.isIncome
                                        ? Colors.green
                                        : Colors.red),
                              ),
                              title: Text(item.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text("${item.category} • ${item.date}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${item.isIncome ? '+' : '-'}${item.amount.toStringAsFixed(0)} ₮",
                                    style: TextStyle(
                                      color: item.isIncome
                                          ? Colors.green
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.grey),
                                    onPressed: () => setState(() =>
                                        _transactions.removeWhere(
                                            (t) => t.id == item.id)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, darkGradientColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.white),
                          onPressed: () {}),
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text("ирээдүйн төлөвлөгөө",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Хуримтлалын зорилго",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    onPressed: _showAddGoalDialog,
                    child: Icon(Icons.add, color: primaryColor),
                  )
                ],
              ),
              const Text("Том зорилгыг жижиг, тогтвортой алхмаар биелүүлээрэй.",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _goals.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.track_changes,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            const Text(
                              "Одоогоор хуримтлалын зорилго байхгүй байна.\n'+' товчийг дарж шинэ зорилго үүсгэнэ үү.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: _showAddGoalDialog,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: primaryColor.withOpacity(0.3)),
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          primaryColor.withOpacity(0.1),
                                      child: Icon(Icons.add, color: primaryColor),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text("Шинэ зорилго",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const Text("Хуримтлалын төлөвлөгөө үүсгэх",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _goals.length,
                            itemBuilder: (context, index) {
                              final goal = _goals[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: darkGradientColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text("НЭН ТЭРГҮҮНИЙ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.white70),
                                          onPressed: () => setState(() =>
                                              _goals.removeWhere(
                                                  (g) => g.id == goal.id)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(goal.title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text("${goal.deadline} хүртэл",
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Цуглуулсан",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10)),
                                            Text(
                                                "${goal.currentAmount.toStringAsFixed(0)} ₮",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Зорилтот дүн",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10)),
                                            Text(
                                                "${goal.targetAmount.toStringAsFixed(0)} ₮",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Үлдсэн",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10)),
                                            Text(
                                                "${(goal.targetAmount - goal.currentAmount).clamp(0, double.infinity).toStringAsFixed(0)} ₮",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: goal.progress,
                                        minHeight: 8,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.greenAccent),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white24,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _showAddDepositDialog(goal),
                                        icon: const Icon(Icons.add),
                                        label: const Text("Хуримтлал нэмэх"),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          // Өөр нэг зорилго нэмэх товчлуур
                          InkWell(
                            onTap: _showAddGoalDialog,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text("Өөр нэг зорилго нэмэх",
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ], // Column-ийн хаалт
                      ), // ternary operator (?:)-ийн хаалт
              ], // Column-ийн хаалт
            ), // SingleChildScrollView-ийн хаалт
          ), // Expanded-ийн хаалт
        ), // Expanded (дээрээс нээгдсэн)-ийн хаалт
      ], // Эхний Column-ийн хаалт
    ); // _buildGoalsView()-ийн хаалт
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const Center(child: Text("Нүүр хуудас", style: TextStyle(fontSize: 18))),
      _buildTransactionsView(),
      _buildGoalsView(),
      const Center(child: Text("AI зөвлөх хуудас", style: TextStyle(fontSize: 18))),
      const Center(child: Text("Профайл хуудас", style: TextStyle(fontSize: 18))),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Нүүр'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Гүйлгээ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: 'Зорилго'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined), label: 'AI зөвлөх'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Профайл'),
        ],
      ),
    );
  }
}