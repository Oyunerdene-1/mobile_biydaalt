import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final String paymentMethod;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.paymentMethod,
    required this.icon,
  });
}

class SavingsGoal {
  final String id;
  final String title;
  final String deadline;
  final DateTime? deadlineDate;
  final double targetAmount;
  double currentAmount;
  final IconData icon;
  final bool isPriority;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.deadline,
    this.deadlineDate,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    this.isPriority = false,
  });

  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // Sar teden tugrug tsugluulval herreeffamu (Dynamic calculation)
  double get monthlyNeeded {
    double remainingAmount = targetAmount - currentAmount;
    if (remainingAmount <= 0) return 0;

    int monthsLeft = 6; // Default to 6 months if date not parsed
    if (deadlineDate != null) {
      final now = DateTime.now();
      monthsLeft = (deadlineDate!.year - now.year) * 12 + deadlineDate!.month - now.month;
      if (monthsLeft <= 0) monthsLeft = 1;
    }
    return remainingAmount / monthsLeft;
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // Default to 'Зорилго'

  final Color primaryColor = const Color(0xFF500071);
  final Color darkCardColor = const Color(0xFF381E72);

  final List<Transaction> _transactions = [];
  String _transactionFilter = 'Бүгд';

  final List<SavingsGoal> _goals = [];

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
    final amountController = TextEditingController();
    String selectedCategory = 'Хүнс';
    String selectedPaymentMethod = 'Карт';
    bool isIncome = false;
    DateTime selectedDate = DateTime.now();

    final categories = [
      'Хүнс',
      'Тээвэр',
      'Төлбөр',
      'Худалдан авалт',
      'Орлого',
      'Нэмэлт орлого'
    ];

    final paymentMethods = [
      'Карт',
      'QPay',
      'Бэлэн мөнгө',
      'Шилжүүлэг',
      'Автомат',
      'Хаан банк'
    ];

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Шинэ гүйлгээ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Text("Мэдээллийг үнэн зөв бөглөөрэй",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isIncome = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isIncome
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: !isIncome
                                      ? Colors.red.shade300
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.call_made,
                                      color: !isIncome
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text("Зарлага",
                                      style: TextStyle(
                                        color: !isIncome
                                            ? Colors.red.shade700
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isIncome = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isIncome
                                      ? Colors.green.shade300
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.call_received,
                                      color: isIncome
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text("Орлого",
                                      style: TextStyle(
                                        color: isIncome
                                            ? Colors.green.shade700
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text("Дүн",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        suffixText: "₮",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Тайлбар",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: "Жишээ: Хүнсний дэлгүүр",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Ангилал",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text("Огноо",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}",
                              style: const TextStyle(fontSize: 15),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Төлбөрийн хэлбэр",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMethod,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: paymentMethods.map((pm) {
                        return DropdownMenuItem(
                          value: pm,
                          child: Text(pm),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedPaymentMethod = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Болих",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            onPressed: () {
                              if (titleController.text.isEmpty ||
                                  amountController.text.isEmpty) return;
                              setState(() {
                                _transactions.insert(
                                  0,
                                  Transaction(
                                    id: DateTime.now().toString(),
                                    title: titleController.text,
                                    category: selectedCategory,
                                    amount: double.tryParse(
                                            amountController.text) ??
                                        0.0,
                                    isIncome: isIncome,
                                    date: "Jun ${selectedDate.day}",
                                    paymentMethod: selectedPaymentMethod,
                                    icon: isIncome
                                        ? Icons.call_received
                                        : Icons.shopping_bag_outlined,
                                  ),
                                );
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text("Хадгалах",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final initialAmountController = TextEditingController();
    DateTime? selectedDate;
    IconData selectedIcon = Icons.flight;
    bool isPriority = false;

    final localIcons = [
      {'icon': Icons.flight, 'name': 'Аялал'},
      {'icon': Icons.laptop, 'name': 'Технологи'},
      {'icon': Icons.directions_car, 'name': 'Машин'},
      {'icon': Icons.home, 'name': 'Байшин'},
      {'icon': Icons.security, 'name': 'Сан'},
    ];

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Шинэ зорилго үүсгэх",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                          labelText: "Зорилгын нэр (ж: Япон руу аялах)",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Нэн тэргүүний зорилго",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text(
                          "Дээд зэрэглэлийн бараан өнгөтэй card хэлбэрээр харуулна"),
                      value: isPriority,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        setModalState(() {
                          isPriority = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text("Зорилгын дүрс сонгох:",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: localIcons.map((item) {
                        final IconData ic = item['icon'] as IconData;
                        final bool isSelected = selectedIcon == ic;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedIcon = ic;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.transparent),
                            ),
                            child: Icon(ic,
                                color: isSelected
                                    ? primaryColor
                                    : Colors.black54),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, color: Colors.grey),
                      label: Text(
                        selectedDate == null
                            ? "Хүрэх хугацаа сонгох (Calendar)"
                            : "Хүрэх хугацаа: ${selectedDate!.year} оны ${selectedDate!.month} сарын ${selectedDate!.day}",
                        style: TextStyle(
                            color: selectedDate == null
                                ? Colors.grey
                                : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: "Зорилтот дүн (₮) - Зөвхөн тоо",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: initialAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: "Эхний хуримтлуулах дүн (₮) - Зөвхөн тоо",
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

                          final date = selectedDate;
                          String dateStr = date != null
                              ? "${date.year} оны ${date.month} сарын ${date.day}"
                              : '2026 оны 3 сарын 15';

                          setState(() {
                            _goals.add(SavingsGoal(
                              id: DateTime.now().toString(),
                              title: titleController.text,
                              deadline: dateStr,
                              deadlineDate: date,
                              targetAmount:
                                  double.tryParse(targetController.text) ??
                                      0.0,
                              currentAmount: double.tryParse(
                                      initialAmountController.text) ??
                                  0.0,
                              icon: selectedIcon,
                              isPriority: isPriority,
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
              ),
            );
          },
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: depositController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: "Нэмэх дүн (₮) - Зөвхөн тоо",
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
                    if (depositController.text.isEmpty) return;
                    setState(() {
                      goal.currentAmount +=
                          double.tryParse(depositController.text) ?? 0.0;
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
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.black54),
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.black54),
                          onPressed: () {}),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, size: 18, color: primaryColor),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text("мөнгөний урсгал",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Гүйлгээ",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  FloatingActionButton.small(
                    backgroundColor: primaryColor,
                    onPressed: _showAddTransactionDialog,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
              const Text("Орлого, зарлагаа нэг дороос хянаарай.",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Гүйлгээ хайх...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: ['Бүгд', 'Орлого', 'Зарлага'].map((type) {
                    final isSelected = _transactionFilter == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: primaryColor.withOpacity(0.15),
                        backgroundColor: Colors.white,
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
                          final stickerColor = item.isIncome
                              ? Colors.green.shade50
                              : Colors.red.shade50;
                          final iconColor = item.isIncome
                              ? Colors.green.shade700
                              : Colors.red.shade400;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: stickerColor,
                                child: Icon(item.icon, color: iconColor),
                              ),
                              title: Text(item.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              subtitle: Text(
                                  "${item.category} · ${item.paymentMethod}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${item.isIncome ? '+' : '-'}${item.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₮",
                                        style: TextStyle(
                                          color: item.isIncome
                                              ? Colors.green
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 16, color: Colors.grey),
                                        onPressed: () {},
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 16, color: Colors.redAccent),
                                        onPressed: () => setState(() =>
                                            _transactions.removeWhere(
                                                (t) => t.id == item.id)),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.date,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 10)),
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
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("ирээдүйн төлөвлөгөө",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  FloatingActionButton.small(
                    backgroundColor: primaryColor,
                    onPressed: _showAddGoalDialog,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Хуримтлалын зорилго",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              const Text("Том зорилгыг жижиг, тогтвортой алхмаар биелүүлээрэй.",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          final percent = (goal.progress * 100).toStringAsFixed(0);
                          final remaining = goal.targetAmount - goal.currentAmount;
                          
                          // Hereeffamee ba'u sar bur tsugluulval zoriogdoo hurneh dunge herreeffamee
                          final monthlyNeededStr = goal.monthlyNeeded
                              .toStringAsFixed(0)
                              .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

                          if (goal.isPriority) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: darkCardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6))
                                ],
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
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text("НЭН ТЭРГҮҮНИЙ",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent, size: 20),
                                        onPressed: () => setState(() =>
                                            _goals.removeWhere(
                                                (g) => g.id == goal.id)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(goal.title,
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Text("${goal.deadline} хүртэл",
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 55,
                                            height: 55,
                                            child: CircularProgressIndicator(
                                              value: goal.progress,
                                              backgroundColor:
                                                  Colors.white.withOpacity(0.2),
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(Colors.greenAccent),
                                              strokeWidth: 5,
                                            ),
                                          ),
                                          Text("$percent%",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13)),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
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
                                                  color: Colors.white60,
                                                  fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                              "${goal.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₮",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Зорилтот дүн",
                                              style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                              "${goal.targetAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₮",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Үлдсэн",
                                              style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                              "${remaining.clamp(0, double.infinity).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₮",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: goal.progress,
                                      minHeight: 6,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.15),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.greenAccent),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.auto_awesome,
                                          color: Colors.purpleAccent, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Сар бүр $monthlyNeededStr ₮ хуримтлуулбал зорилгодоо хугацаандаа хүрнэ.",
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed: () =>
                                          _showAddDepositDialog(goal),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, size: 18),
                                          SizedBox(width: 6),
                                          Text("Хуримтлал нэмэх",
                                              style: TextStyle(fontSize: 15)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(goal.icon,
                                          color: primaryColor, size: 28),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent, size: 20),
                                      onPressed: () => setState(() =>
                                          _goals.removeWhere(
                                              (g) => g.id == goal.id)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(goal.title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("${goal.deadline} хүртэл",
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: goal.progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green.shade600),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${goal.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₮ / ${goal.targetAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₮",
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text("$percent%",
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: primaryColor.withOpacity(0.3)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _showAddDepositDialog(goal),
                                    child: Text("Хуримтлал нэмэх",
                                        style: TextStyle(color: primaryColor)),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showAddGoalDialog,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.add, color: primaryColor),
                        ),
                        const SizedBox(height: 10),
                        const Text("Шинэ зорилго",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87)),
                        const SizedBox(height: 4),
                        const Text("Хуримтлалын төлөвлөгөө үүсгэх",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 50, color: primaryColor),
            ),
            const SizedBox(height: 20),
            const Text(
              "Та нэвтрээгүй байна",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Санхүүгийн мэдээллээ хадгалах болон синхрончлохын тулд нэвтэрнэ үү.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("Нэвтрэх / Бүртгүүлэх",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Center(child: Text("Нүүр хуудас", style: TextStyle(fontSize: 18))),
      _buildTransactionsView(),
      _buildGoalsView(),
      const Center(child: Text("AI зөвлөх хуудас", style: TextStyle(fontSize: 18))),
      _buildProfileView(),
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