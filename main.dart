import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart';


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
    return _MoneyProfile(transactions: _transactions, onNavigate: (index) => setState(() => _currentIndex = index));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Center(child: Text("Нүүр хуудас", style: TextStyle(fontSize: 18))),
      _buildTransactionsView(),
      _buildGoalsView(),
      _MoneyAdvisor(transactions: _transactions, goals: _goals),
      _buildProfileView(),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: _currentIndex == 4 && MediaQuery.of(context).size.width >= 1120 ? null : BottomNavigationBar(
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

const _violet = Color(0xFF6847DB);
const _ink = Color(0xFF302347);
const _muted = Color(0xFF9690A8);
const _line = Color(0xFFE7E1F0);
const _wash = Color(0xFFF7F5FA);

String _mnt(num value) => '${value.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ₮';
String? _emailError(String? value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '') ? null : 'И-мэйл хаягаа зөв оруулна уу.';
String? _nameError(String? value) => (value?.trim().isEmpty ?? true) ? 'Нэрээ оруулна уу.' : null;

// Device-only demo repository. Never use this as server authentication.
class _AccountStore extends ChangeNotifier {
  static final instance = _AccountStore();
  final _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 210000, bits: 256);
  SharedPreferences? _prefs;
  Future<void>? _loading;
  List<Map<String, dynamic>> _accounts = [];
  String? _active;
  bool reminders = true;
  bool reports = true;
  bool get signedIn => user != null;
  Map<String, dynamic>? get user {
    for (final account in _accounts) {
      if (account['email'] == _active) return account;
    }
    return null;
  }
  String get name => user?['name'] as String? ?? 'Зочин';
  String get email => user?['email'] as String? ?? 'Demo хэрэглэгч';
  String get initial => name.isEmpty ? 'М' : name.substring(0, 1).toUpperCase();
  String get occupation => user?['occupation'] as String? ?? '';
  Future<void> load() => _loading ??= _load();
  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('mz.accounts.v1');
    if (raw != null) {
      _accounts = (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    // Restore only a display session; this is not a trusted security token.
    _active = _prefs!.getString('mz.session.v1');
    _readSettings();
  }
  void _readSettings() {
    reminders = user?['reminders'] as bool? ?? true;
    reports = user?['reports'] as bool? ?? true;
  }
  Future<String> _hash(String password, List<int> salt) async {
    final key = await _kdf.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
    return base64Encode(await key.extractBytes());
  }
  Future<void> _save() async {
    final ok = await _prefs!.setString('mz.accounts.v1', jsonEncode(_accounts));
    if (!ok) throw StateError('Мэдээлэл хадгалагдсангүй. Дахин оролдоно уу.');
    notifyListeners();
  }
  Future<void> authenticate({required String email, required String password, String? name}) async {
    await load();
    email = email.trim().toLowerCase();
    Map<String, dynamic>? existing;
    for (final account in _accounts) {
      if (account['email'] == email) existing = account;
    }
    if (name != null) {
      if (existing != null) throw StateError('Энэ и-мэйлээр бүртгүүлсэн байна. Нэвтэрнэ үү.');
      final random = Random.secure();
      final salt = List<int>.generate(24, (_) => random.nextInt(256));
      final account = <String, dynamic>{'name': name.trim(), 'email': email, 'salt': base64Encode(salt), 'hash': await _hash(password, salt)};
      _accounts.add(account);
      try { await _save(); } catch (_) { _accounts.remove(account); rethrow; }
    } else {
      if (existing == null) throw StateError('И-мэйл эсвэл нууц үг буруу байна.');
      final hash = await _hash(password, base64Decode(existing['salt'] as String));
      if (hash != existing['hash']) throw StateError('И-мэйл эсвэл нууц үг буруу байна.');
    }
    if (!await _prefs!.setString('mz.session.v1', email)) throw StateError('Нэвтрэлтийг хадгалж чадсангүй.');
    _active = email;
    _readSettings();
    notifyListeners();
  }
  Future<void> edit(String name, String email, String occupation) async {
    email = email.trim().toLowerCase();
    if (_accounts.any((a) => a != user && a['email'] == email)) throw StateError('Энэ и-мэйл бүртгэлтэй байна.');
    final account = user!;
    final before = Map<String, dynamic>.from(account);
    final previousActive = _active;
    account.addAll({'name': name.trim(), 'email': email, 'occupation': occupation.trim()});
    _active = email;
    try {
      await _save();
      if (!await _prefs!.setString('mz.session.v1', email)) throw StateError('Нэвтрэлтийг хадгалж чадсангүй.');
    } catch (_) {
      account..clear()..addAll(before);
      _active = previousActive;
      await _save();
      rethrow;
    }
    notifyListeners();
  }
  Future<void> changePassword(String old, String next) async {
    final account = user!;
    if (await _hash(old, base64Decode(account['salt'] as String)) != account['hash']) throw StateError('Одоогийн нууц үг буруу байна.');
    final random = Random.secure();
    final salt = List<int>.generate(24, (_) => random.nextInt(256));
    final oldSalt = account['salt'];
    final oldHash = account['hash'];
    account['salt'] = base64Encode(salt);
    account['hash'] = await _hash(next, salt);
    try { await _save(); } catch (_) { account['salt'] = oldSalt; account['hash'] = oldHash; rethrow; }
  }
  Future<void> settings(bool reminderValue, bool reportValue) async {
    final account = user!;
    account['reminders'] = reminderValue;
    account['reports'] = reportValue;
    await _save();
    _readSettings();
    notifyListeners();
  }
  Future<void> logout() async {
    if (!await _prefs!.remove('mz.session.v1')) throw StateError('Гарах үйлдэл амжилтгүй.');
    _active = null;
    notifyListeners();
  }
}

Widget _panel({required Widget child, Color color = Colors.white}) => Container(
  width: double.infinity, padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line),
    boxShadow: [BoxShadow(color: _ink.withOpacity(.035), blurRadius: 20, offset: const Offset(0, 8))]), child: child);
Widget _badge(IconData icon) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFFF0EBFF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _violet, size: 22));
Widget _avatar(_AccountStore store, {double size = 40}) => Container(width: size, height: size,
  alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(size * .3), gradient: const LinearGradient(colors: [Color(0xFF59418E), Color(0xFF2F2148)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
  child: Text(store.initial, style: TextStyle(color: Colors.white, fontSize: size * .34, fontWeight: FontWeight.bold)));
Widget _action(String text, VoidCallback? onTap, {bool filled = false, IconData? icon}) {
  final style = filled ? ElevatedButton.styleFrom(backgroundColor: _violet, foregroundColor: Colors.white, elevation: 0, minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)))
    : OutlinedButton.styleFrom(foregroundColor: _ink, side: const BorderSide(color: _line), minimumSize: const Size(0, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)));
  final content = Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)], Flexible(child: Text(text, textAlign: TextAlign.center))]);
  return filled ? ElevatedButton(onPressed: onTap, style: style, child: content) : OutlinedButton(onPressed: onTap, style: style, child: content);
}
void _notice(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<void> _info(BuildContext context, String title, String message) => showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: SingleChildScrollView(child: Text(message)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ойлголоо'))]));
Widget _topBar(BuildContext context, _AccountStore store) => Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [
  IconButton(tooltip: 'Хуудасны мэдээлэл', onPressed: () => _info(context, 'Мөнгө Зөв', 'AI зөвлөх болон профайл хэсэг. Доод цэсээр хуудсаа сонгоно уу.'), icon: const Icon(Icons.menu, color: _muted)),
  const Spacer(), IconButton(tooltip: 'Мэдэгдэл', onPressed: () => _info(context, 'Мэдэгдэл', 'Одоогоор шинэ мэдэгдэл алга. Demo горимд системийн push мэдэгдэл илгээхгүй.'), icon: const Icon(Icons.notifications_outlined, color: _muted)), const SizedBox(width: 10), _avatar(store),
]));
Widget _deviceNote() => _panel(color: const Color(0xFFF4EFFF), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.verified_user_outlined, color: _violet), SizedBox(height: 10), Text('Demo горим', style: TextStyle(color: _violet, fontWeight: FontWeight.w600)), SizedBox(height: 6), Text('Бүртгэл, профайл зөвхөн энэ төхөөрөмжид хадгалагдана. Сервер, банк, үүлэн синхрончлол холбогдоогүй. Гүйлгээ, зорилго нь анхны төслийн түр санах ойд хэвээр; хэрэглэгчээр тусгаарлагдахгүй.', style: TextStyle(color: _muted, fontSize: 12, height: 1.6))]));

class _MoneyProfile extends StatefulWidget {
  final List<Transaction> transactions;
  final ValueChanged<int> onNavigate;
  const _MoneyProfile({required this.transactions, required this.onNavigate});
  @override
  State<_MoneyProfile> createState() => _MoneyProfileState();
}
class _MoneyProfileState extends State<_MoneyProfile> {
  final store = _AccountStore.instance;
  late Future<void> loading;
  @override
  void initState() { super.initState(); loading = store.load(); }
  Future<void> _auth() async {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const _MoneyAuth()));
    if (mounted) setState(() {});
  }
  Future<void> _edit() async {
    final result = await showDialog<List<String>>(context: context, builder: (_) => _AccountForm(name: store.name, email: store.email, occupation: store.occupation));
    if (result == null) return;
    try { await store.edit(result[0], result[1], result[2]); if (mounted) _notice(context, 'Профайл хадгалагдлаа.'); }
    catch (e) { if (mounted) _notice(context, e.toString()); }
  }
  Future<void> _notifications() async {
    if (!store.signedIn) { await _auth(); return; }
    bool reminder = store.reminders, report = store.reports;
    final save = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(title: const Text('Мэдэгдлийн тохиргоо'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Demo тохиргоо хадгалагдана. Push мэдэгдэл холбогдоогүй.', style: TextStyle(color: _muted, fontSize: 12)),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Төсөв, зорилгын сануулга'), value: reminder, onChanged: (v) => update(() => reminder = v)),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Сарын тайлан'), value: report, onChanged: (v) => update(() => report = v)),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Болих')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Хадгалах'))])));
    if (save == true) {
      try { await store.settings(reminder, report); if (mounted) _notice(context, 'Тохиргоо хадгалагдлаа.'); }
      catch (e) { if (mounted) _notice(context, e.toString()); }
    }
  }
  void _export() {
    String cell(Object value) => '"${value.toString().replaceAll('"', '""')}"';
    final csv = [['Огноо', 'Тайлбар', 'Ангилал', 'Төрөл', 'Дүн', 'Төлбөрийн хэлбэр'].map(cell).join(','),
      ...widget.transactions.map((t) => [t.date, t.title, t.category, t.isIncome ? 'Орлого' : 'Зарлага', t.amount.round(), t.paymentMethod].map(cell).join(','))].join('\r\n');
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: const Text('Гүйлгээ · CSV'), content: SizedBox(width: 520, child: SingleChildScrollView(child: SelectableText(csv))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Хаах')), TextButton(onPressed: () async { await Clipboard.setData(ClipboardData(text: csv)); if (mounted) _notice(context, 'CSV хууллаа. .csv файлд хадгалаарай.'); }, child: const Text('CSV хуулах'))]));
  }
  Widget _row(IconData icon, String title, String detail, VoidCallback onTap) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: _badge(icon),
    title: Text(title, style: const TextStyle(fontSize: 13, color: _ink, fontWeight: FontWeight.w500)), subtitle: Text(detail, style: const TextStyle(fontSize: 11, color: _muted)), trailing: const Icon(Icons.chevron_right, color: _ink, size: 20), onTap: onTap);
  Future<void> _salaryPlan() async {
    if (!store.signedIn) { await _auth(); return; }
    final key = 'mz.salary.${store.email}';
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final result = await showDialog<String>(context: context, builder: (_) => _SalaryPlanDialog(saved: prefs.getString(key)));
    if (result == null) return;
    try {
      if (!await prefs.setString(key, result)) throw StateError('Хадгалж чадсангүй.');
      if (mounted) _notice(context, 'Цалингийн төлөвлөгөө хадгалагдлаа. Автомат гүйлгээ үүсгэхгүй.');
    } catch (e) { if (mounted) _notice(context, e.toString()); }
  }
  Future<void> _logout() async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Бүртгэлээс гарах уу?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Болих')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Гарах'))]));
    if (yes == true) { try { await store.logout(); } catch (e) { if (mounted) _notice(context, e.toString()); } }
  }
  Widget _identity(bool desktop) => _panel(child: SizedBox(height: desktop ? 434 : null, child: Column(mainAxisSize: MainAxisSize.min, children: [
    const SizedBox(height: 8), _avatar(store, size: 86), const SizedBox(height: 20), Text(store.name, textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 21)), const SizedBox(height: 7), Text(store.email, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12)), const SizedBox(height: 22),
    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFF0EBFF), borderRadius: BorderRadius.circular(9)), child: Text(store.signedIn ? 'ТӨХӨӨРӨМЖИЙН БҮРТГЭЛ' : 'ЗОЧИН · DEMO', style: const TextStyle(color: _violet, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: .5))), const SizedBox(height: 24),
    SizedBox(width: double.infinity, child: _action(store.signedIn ? 'Профайл засах' : 'Нэвтрэх / Бүртгүүлэх', store.signedIn ? _edit : _auth, icon: store.signedIn ? Icons.edit_outlined : Icons.login)),
  ])));
  Widget _settingsCard() => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line), boxShadow: [BoxShadow(color: _ink.withOpacity(.035), blurRadius: 24, offset: const Offset(0, 10))]), clipBehavior: Clip.antiAlias, child: Column(children: [
    _row(Icons.person_outline, 'Хувийн мэдээлэл', 'Нэр, и-мэйл, үндсэн ажил', store.signedIn ? _edit : _auth), const Divider(height: 1, color: _line),
    _row(Icons.notifications_none, 'Мэдэгдлийн тохиргоо', 'Төсөв, тайлан, зорилгын сануулга', _notifications), const Divider(height: 1, color: _line),
    _row(Icons.shield_outlined, 'Нууцлал ба аюулгүй байдал', 'Нууц үг, өгөгдлийн хамгаалалт', () { if (!store.signedIn) { _auth(); return; } Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const _PasswordPage())); }), const Divider(height: 1, color: _line),
    _row(Icons.download_outlined, 'Өгөгдөл татах', 'Гүйлгээг CSV хэлбэрээр хуулж авах', _export), const Divider(height: 1, color: _line),
    _row(Icons.settings_outlined, 'Аппын тохиргоо', 'MNT · Asia/Ulaanbaatar · Монгол хэл', () => _info(context, 'Аппын тохиргоо', 'Валют: Монгол төгрөг (MNT)\nХэл: Монгол\nЦагийн бүс: Asia/Ulaanbaatar\n\nЭнэ хувилбарын тогтмол тохиргоо.')),
  ]));
  Widget _salaryCard(bool desktop) {
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Цалингийн өдрийн төлөвлөгөө', style: TextStyle(color: _ink, fontSize: 13)), const SizedBox(height: 5), Text('Цалингаа хэрэгцээ, хүсэл, хуримтлалдаа хуваарилах загвар.', style: TextStyle(color: _muted, fontSize: desktop ? 10 : 11, height: 1.5))]);
    final button = _action('Төлөвлөгөө нэмэх', _salaryPlan);
    return _panel(child: desktop ? Row(children: [_badge(Icons.calendar_month_outlined), const SizedBox(width: 16), Expanded(child: text), const SizedBox(width: 16), button]) : Column(children: [Row(children: [_badge(Icons.calendar_month_outlined), const SizedBox(width: 14), Expanded(child: text)]), const SizedBox(height: 16), SizedBox(width: double.infinity, child: button)]));
  }
  Widget _sidebar() => Container(width: 264, color: const Color(0xFF17112D), child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 30, 20, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF74E4BB), size: 28), SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Мөнгө Зөв', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('Санхүүгээ ухаалгаар', style: TextStyle(color: Color(0xFF9F91C7), fontSize: 11))])]), const SizedBox(height: 38),
    const Padding(padding: EdgeInsets.only(left: 10, bottom: 18), child: Text('ҮНДСЭН ЦЭС', style: TextStyle(color: Color(0xFF7D719B), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
    ...List.generate(5, (i) {
      const labels = ['Нүүр', 'Гүйлгээ', 'Зорилго', 'AI зөвлөх', 'Профайл'];
      const icons = [Icons.grid_view_outlined, Icons.receipt_long_outlined, Icons.track_changes, Icons.chat_bubble_outline, Icons.person_outline];
      return Padding(padding: const EdgeInsets.only(bottom: 8), child: ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), selected: i == 4, selectedTileColor: const Color(0xFF302349), leading: Icon(icons[i], color: i == 4 ? Colors.white : const Color(0xFFAEA4C4), size: 21), title: Text(labels[i], style: TextStyle(color: i == 4 ? Colors.white : const Color(0xFFAEA4C4), fontSize: 14)), onTap: () => widget.onNavigate(i)));
    }), const SizedBox(height: 42),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF251C3C), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF3A2D52))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_awesome_outlined, color: Color(0xFFB39AFB)), SizedBox(height: 14), Text('Бага алхам, зөв дадал', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)), SizedBox(height: 7), Text('Өдөр бүр гүйлгээгээ бүртгэж, санхүүгээ илүү ойлгомжтой болгоорой.', style: TextStyle(color: Color(0xFF9F91B8), height: 1.6, fontSize: 11))])), const SizedBox(height: 20), const Text('●  DEMO ОРЧИН', style: TextStyle(color: Color(0xFF72CDA9), letterSpacing: 1.5, fontSize: 9)),
  ]))));
  Widget _desktopTop() => Container(height: 78, padding: const EdgeInsets.symmetric(horizontal: 30), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: _line))), child: Row(children: [
    Expanded(child: TextField(decoration: const InputDecoration(icon: Icon(Icons.search, color: _muted, size: 21), hintText: 'Профайлын тохиргоо хайх…', hintStyle: TextStyle(color: _muted, fontSize: 13), border: InputBorder.none), onSubmitted: (query) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return;
      if (q.contains('мэдэгд')) { _notifications(); }
      else if (q.contains('csv') || q.contains('өгөгдөл')) { _export(); }
      else if (q.contains('нууц')) { if (store.signedIn) { Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const _PasswordPage())); } else { _auth(); } }
      else if (q.contains('профайл') || q.contains('хувийн') || q.contains('нэр')) { if (store.signedIn) { _edit(); } else { _auth(); } }
      else _info(context, 'Тохиргоо хайх', 'Профайл, хувийн мэдээлэл, мэдэгдэл, нууц үг, CSV гэж хайгаарай.');
    })), const SizedBox(width: 20), const Text('● Demo өгөгдөл', style: TextStyle(color: _muted, fontSize: 11)), const SizedBox(width: 14),
    IconButton(tooltip: 'Мэдэгдэл', onPressed: () => _info(context, 'Мэдэгдэл', 'Одоогоор шинэ мэдэгдэл алга.'), icon: const Icon(Icons.notifications_outlined, color: _muted)), const SizedBox(width: 14), Container(height: 36, width: 1, color: _line), const SizedBox(width: 18), _avatar(store), const SizedBox(width: 12),
    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(store.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text('Хувийн бүртгэл', style: TextStyle(color: _muted, fontSize: 10))])),
    PopupMenuButton<String>(tooltip: 'Бүртгэлийн цэс', onSelected: (v) { if (v == 'logout') { _logout(); } else if (store.signedIn) { _edit(); } else { _auth(); } }, itemBuilder: (_) => [PopupMenuItem(value: 'profile', child: Text(store.signedIn ? 'Профайл засах' : 'Нэвтрэх / Бүртгүүлэх')), if (store.signedIn) const PopupMenuItem(value: 'logout', child: Text('Гарах'))]),
  ]));
  Widget _content(bool desktop) => SingleChildScrollView(padding: EdgeInsets.all(desktop ? 38 : 16), child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: BoxConstraints(maxWidth: desktop ? 1280 : 680), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ХУВИЙН ТОХИРГОО', style: TextStyle(color: _violet, fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w600)), const SizedBox(height: 12), const Text('Профайл ба нууцлал', style: TextStyle(fontSize: 28, color: _ink, fontWeight: FontWeight.w400)), const SizedBox(height: 8), const Text('Өөрийн мэдээлэл, мэдэгдэл болон өгөгдлөө удирдаарай.', style: TextStyle(color: _muted, fontSize: 13)), const SizedBox(height: 30),
    if (desktop) Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 300, child: Column(children: [_identity(true), const SizedBox(height: 20), _deviceNote(), if (store.signedIn) ...[const SizedBox(height: 16), SizedBox(width: double.infinity, child: _action('Бүртгэлээс гарах', _logout, icon: Icons.logout))]])), const SizedBox(width: 20), Expanded(child: Column(children: [_settingsCard(), const SizedBox(height: 20), _salaryCard(true)]))])
    else ...[_identity(false), const SizedBox(height: 18), _settingsCard(), const SizedBox(height: 18), _salaryCard(false), const SizedBox(height: 18), _deviceNote(), if (store.signedIn) ...[const SizedBox(height: 16), SizedBox(width: double.infinity, child: _action('Бүртгэлээс гарах', _logout, icon: Icons.logout))]], const SizedBox(height: 24),
  ]))));
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(future: loading, builder: (context, snapshot) {
    if (snapshot.hasError) return Center(child: _action('Дахин ачаалах', () => setState(() { store._loading = null; loading = store.load(); })));
    if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
    return AnimatedBuilder(animation: store, builder: (context, _) => LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 1120;
      final main = ColoredBox(color: _wash, child: Column(children: [desktop ? _desktopTop() : _topBar(context, store), Expanded(child: _content(desktop))]));
      return desktop ? Row(children: [_sidebar(), Expanded(child: main)]) : main;
    }));
  });

}

InputDecoration _input(String label, {IconData? icon, Widget? suffix}) => InputDecoration(labelText: label, prefixIcon: icon == null ? null : Icon(icon, color: _muted, size: 20), suffixIcon: suffix, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: _line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: _line)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: _violet, width: 1.5)));
String? _passwordError(String? value) => (value?.length ?? 0) < 8 ? 'Нууц үг хамгийн багадаа 8 тэмдэгт байна.' : null;

class _MoneyAuth extends StatefulWidget {
  const _MoneyAuth();
  @override
  State<_MoneyAuth> createState() => _MoneyAuthState();
}
class _MoneyAuthState extends State<_MoneyAuth> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), password = TextEditingController(), confirm = TextEditingController();
  bool register = false, hidden = true, busy = false, accepted = false;
  String? error;
  @override
  void dispose() { name.dispose(); email.dispose(); password.dispose(); confirm.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (busy || !form.currentState!.validate()) return;
    if (register && !accepted) { setState(() => error = 'Demo горимын нөхцөлийг зөвшөөрнө үү.'); return; }
    setState(() { busy = true; error = null; });
    try {
      await _AccountStore.instance.authenticate(email: email.text, password: password.text, name: register ? name.text : null);
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) setState(() => error = e.toString().replaceFirst('Bad state: ', '')); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: _wash, appBar: AppBar(backgroundColor: Colors.white, title: const Text('Мөнгө Зөв', style: TextStyle(color: _ink, fontSize: 18))), body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Center(child: _badge(Icons.account_balance_wallet_outlined)), const SizedBox(height: 20), Text(register ? 'Бүртгэл үүсгэх' : 'Тавтай морил!', textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 28)), const SizedBox(height: 8), const Text('Санхүүгээ зөв удирдах эхний алхам.', textAlign: TextAlign.center, style: TextStyle(color: _muted)), const SizedBox(height: 28),
    if (register) ...[TextFormField(controller: name, enabled: !busy, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.name], validator: _nameError, decoration: _input('Таны нэр', icon: Icons.person_outline)), const SizedBox(height: 16)],
    TextFormField(controller: email, enabled: !busy, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], autocorrect: false, validator: _emailError, decoration: _input('И-мэйл', icon: Icons.mail_outline)), const SizedBox(height: 16),
    TextFormField(controller: password, enabled: !busy, obscureText: hidden, autocorrect: false, enableSuggestions: false, textInputAction: register ? TextInputAction.next : TextInputAction.done, onFieldSubmitted: (_) { if (!register) _submit(); }, validator: register ? _passwordError : (v) => (v?.isEmpty ?? true) ? 'Нууц үгээ оруулна уу.' : null, decoration: _input('Нууц үг', icon: Icons.lock_outline, suffix: IconButton(tooltip: hidden ? 'Нууц үг харах' : 'Нууц үг нуух', onPressed: () => setState(() => hidden = !hidden), icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _muted)))),
    if (register) ...[const SizedBox(height: 16), TextFormField(controller: confirm, enabled: !busy, obscureText: hidden, autocorrect: false, enableSuggestions: false, onFieldSubmitted: (_) => _submit(), validator: (v) => v != password.text ? 'Нууц үг таарахгүй байна.' : null, decoration: _input('Нууц үг давтах', icon: Icons.lock_outline)), CheckboxListTile(contentPadding: EdgeInsets.zero, activeColor: _violet, controlAffinity: ListTileControlAffinity.leading, value: accepted, onChanged: busy ? null : (v) => setState(() => accepted = v ?? false), title: const Text('Зөвхөн энэ төхөөрөмжид хадгалагдах demo бүртгэл болохыг ойлголоо.', style: TextStyle(color: _muted, fontSize: 12)))],
    if (!register) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: busy ? null : () => _info(context, 'Нууц үг сэргээх', 'И-мэйл илгээх сервер холбогдоогүй тул сэргээх холбоос илгээх боломжгүй. Нэвтэрсэн үедээ профайлын нууцлал хэсгээс нууц үгээ солино.'), child: const Text('Нууц үгээ мартсан уу?', style: TextStyle(color: _violet)))),
    if (error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Semantics(liveRegion: true, child: Text(error!, style: const TextStyle(color: Colors.red)))), const SizedBox(height: 12),
    _action(busy ? 'Түр хүлээнэ үү…' : register ? 'Бүртгүүлэх' : 'Нэвтрэх', busy ? null : _submit, filled: true), const SizedBox(height: 12),
    TextButton(onPressed: busy ? null : () { setState(() { register = !register; error = null; password.clear(); confirm.clear(); }); form.currentState?.reset(); }, child: Text(register ? 'Бүртгэлтэй юу? Нэвтрэх' : 'Бүртгэлгүй юу? Бүртгүүлэх', style: const TextStyle(color: _violet))), const SizedBox(height: 18), _deviceNote(),
  ])))))));
}

class _AccountForm extends StatefulWidget {
  final String name, email, occupation;
  const _AccountForm({required this.name, required this.email, required this.occupation});
  @override
  State<_AccountForm> createState() => _AccountFormState();
}
class _AccountFormState extends State<_AccountForm> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.name), email = TextEditingController(text: widget.email), occupation = TextEditingController(text: widget.occupation);
  @override
  void dispose() { name.dispose(); email.dispose(); occupation.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Хувийн мэдээлэл'), content: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextFormField(controller: name, validator: _nameError, decoration: _input('Нэр')), const SizedBox(height: 14), TextFormField(controller: email, validator: _emailError, keyboardType: TextInputType.emailAddress, decoration: _input('И-мэйл')), const SizedBox(height: 14), TextFormField(controller: occupation, decoration: _input('Үндсэн ажил')),
  ]))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Болих')), TextButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(context, [name.text, email.text, occupation.text]); }, child: const Text('Хадгалах'))]);
}
class _PasswordPage extends StatefulWidget {
  const _PasswordPage();
  @override
  State<_PasswordPage> createState() => _PasswordPageState();
}
class _PasswordPageState extends State<_PasswordPage> {
  final form = GlobalKey<FormState>();
  final old = TextEditingController(), next = TextEditingController(), confirm = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() { old.dispose(); next.dispose(); confirm.dispose(); super.dispose(); }
  Future<void> _save() async {
    if (!form.currentState!.validate() || busy) return;
    setState(() { busy = true; error = null; });
    try { await _AccountStore.instance.changePassword(old.text, next.text); if (mounted) { _notice(context, 'Нууц үг шинэчлэгдлээ.'); Navigator.pop(context); } }
    catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: _wash, appBar: AppBar(title: const Text('Нууцлал ба аюулгүй байдал')), body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('Demo бүртгэлийн нууц үг PBKDF2-SHA256 хэшээр хадгалагдана. Энэ нь серверийн баталгаажуулалтыг орлохгүй.', style: TextStyle(color: _muted, height: 1.6)), const SizedBox(height: 24),
    TextFormField(controller: old, enabled: !busy, obscureText: true, decoration: _input('Одоогийн нууц үг'), validator: (v) => (v?.isEmpty ?? true) ? 'Нууц үгээ оруулна уу.' : null), const SizedBox(height: 16),
    TextFormField(controller: next, enabled: !busy, obscureText: true, decoration: _input('Шинэ нууц үг'), validator: _passwordError), const SizedBox(height: 16),
    TextFormField(controller: confirm, enabled: !busy, obscureText: true, decoration: _input('Нууц үг давтах'), validator: (v) => v != next.text ? 'Нууц үг таарахгүй байна.' : null), const SizedBox(height: 20),
    if (error != null) Text(error!, style: const TextStyle(color: Colors.red)), _action(busy ? 'Хадгалж байна…' : 'Нууц үг солих', busy ? null : _save, filled: true),
  ]))))));
}

class _Advice {
  final String text;
  final bool estimate;
  const _Advice(this.text, {this.estimate = false});
}
abstract class FinancialAdvisorRepository {
  _Advice reply(String question, List<Transaction> transactions, List<SavingsGoal> goals);
}
class RuleBasedFinancialAdvisorRepository implements FinancialAdvisorRepository {
  @override
  _Advice reply(String question, List<Transaction> transactions, List<SavingsGoal> goals) {
    final q = question.toLowerCase();
    if (q.contains('зорилго')) {
      if (goals.isEmpty) return const _Advice('Хуримтлалын зорилго бүртгэлгүй байна. «Зорилго» хэсэгт дүн, хугацаагаа оруулаарай.');
      return _Advice(goals.map((g) => '${g.title}: ${_mnt(g.currentAmount)} / ${_mnt(g.targetAmount)} (${(g.progress * 100).toStringAsFixed(1)}%). Сард ойролцоогоор ${_mnt(g.monthlyNeeded)} хэрэгтэй.').join('\n\n') + '\n\nТооцоолол: үлдсэн дүн ÷ үлдсэн сарын тоо. Анхны зорилгын тооцооллыг ашиглав; хугацаа тодорхойгүй бол 6 сар гэж үздэг. Орлого, зардал өөрчлөгдөхгүй гэсэн баталгаа байхгүй.', estimate: true);
    }
    if (transactions.isEmpty) return const _Advice('Тооцоолол хийхэд гүйлгээний мэдээлэл хүрэлцэхгүй байна. «Гүйлгээ» хэсэгт орлого, зарлагаа нэмээрэй. Мэдээлэлгүй үед дүн болон хуримтлалын хувь таамаглахгүй.');
    final income = transactions.where((t) => t.isIncome).fold<int>(0, (s, t) => s + t.amount.round());
    final expense = transactions.where((t) => !t.isIncome).fold<int>(0, (s, t) => s + t.amount.round());
    final balance = income - expense;
    final categories = <String, int>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      categories[t.category] = (categories[t.category] ?? 0) + t.amount.round();
    }
    final sorted = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    const scope = '\n\nХамрах хүрээ: бүртгэлтэй бүх гүйлгээ. Огнооны бүтэц дутуу тул сараар ялгаагүй. Дүнг бүхэл төгрөгөөр тоймлов.';
    if (q.contains('их зар') || q.contains('ангилал') || q.contains('юунд')) {
      if (sorted.isEmpty) return const _Advice('Зарлага бүртгэлгүй байна. Ангиллаар харьцуулах мэдээлэл алга.');
      return _Advice('Хамгийн их зарлага: ${sorted.first.key} — ${_mnt(sorted.first.value)}.\n\n${sorted.map((e) => '${e.key}: ${_mnt(e.value)} (${expense > 0 ? (e.value * 100 / expense).toStringAsFixed(1) : '0'}%)').join('\n')}\n\nТооцоолол: ангиллын зарлага ÷ нийт зарлага × 100.$scope');
    }
    if (q.contains('хуримт') || q.contains('хэмнэ') || q.contains('төлөв')) {
      if (sorted.isEmpty) return _Advice('Бүртгэлтэй орлого ${_mnt(income)}. Зарлага бүртгэлгүй тул хэмнэлтийн боломжийг найдвартай тооцох боломжгүй.$scope');
      final saving = (sorted.first.value * .10).round();
      return _Advice('${sorted.first.key} ангилалд ${_mnt(sorted.first.value)} зарцуулсан байна. Үүнийг 10% бууруулж чадвал ${_mnt(saving)} хэмнэх жишиг хувилбар байна.\n\nТооцоолол: ${_mnt(sorted.first.value)} × 10%. Энэ нь зөвхөн хувилбар; зайлшгүй хэрэгцээний зардлаа эхэлж ялгаарай. Дараа сарын баталгаатай таамаг биш.$scope', estimate: true);
    }
    if (q.contains('тойм') || q.contains('орлого') || q.contains('үлдэгдэл') || q.contains('санхүү') || q.contains('зарлага')) {
      return _Advice('Орлого: ${_mnt(income)}\nЗарлага: ${_mnt(expense)}\nЗөрүү: ${_mnt(balance)}\n${income > 0 ? 'Орлогоос үлдсэн хувь: ${(balance * 100 / income).toStringAsFixed(1)}%.' : 'Орлого бүртгэлгүй тул хуримтлалын хувь тооцохгүй.'}\n\nТооцоолол: орлого − зарлага. Зөрүү нь дансны бодит үлдэгдэл болон тусдаа хадгалсан хуримтлалтай заавал тэнцэхгүй.$scope');
    }
    return const _Advice('Энэ нь дүрэмд суурилсан demo зөвлөх. «Санхүүгийн тойм», «Юунд хамгийн их зарцуулсан бэ?», «Илүү их хуримтлуулах арга», «Зорилгодоо яаж хүрэх вэ?» гэж асуугаарай. Ерөнхий асуултад хариулах алсын AI холбогдоогүй.');
  }
}
class _ChatItem {
  final String text;
  final bool mine, estimate;
  const _ChatItem(this.text, {this.mine = false, this.estimate = false});
}
class _MoneyAdvisor extends StatefulWidget {
  final List<Transaction> transactions;
  final List<SavingsGoal> goals;
  const _MoneyAdvisor({required this.transactions, required this.goals});
  @override
  State<_MoneyAdvisor> createState() => _MoneyAdvisorState();
}
class _MoneyAdvisorState extends State<_MoneyAdvisor> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final store = _AccountStore.instance;
  final FinancialAdvisorRepository repository = RuleBasedFinancialAdvisorRepository();
  final messages = <_ChatItem>[const _ChatItem('Сайн байна уу! Би таны бүртгэсэн гүйлгээ, зорилгод тулгуурлан зөвлөгөө өгнө. Юу мэдэхийг хүсэж байна вэ?')];
  @override
  void initState() { super.initState(); store.load().then((_) { if (mounted) setState(() {}); }).catchError((Object _) {}); }
  @override
  void dispose() { input.dispose(); scroll.dispose(); super.dispose(); }
  void _send([String? suggestion]) {
    final text = (suggestion ?? input.text).trim();
    if (text.isEmpty) return;
    final advice = repository.reply(text, widget.transactions, widget.goals);
    setState(() { messages.add(_ChatItem(text, mine: true)); messages.add(_ChatItem(advice.text, estimate: advice.estimate)); input.clear(); });
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted && scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut); });
  }
  @override
  Widget build(BuildContext context) {
    final income = widget.transactions.where((t) => t.isIncome).fold<int>(0, (s, t) => s + t.amount.round());
    final expense = widget.transactions.where((t) => !t.isIncome).fold<int>(0, (s, t) => s + t.amount.round());
    return ColoredBox(color: _wash, child: Column(children: [
      _topBar(context, store), Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _violet, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.smart_toy_outlined, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Зөв туслах', style: TextStyle(color: _ink, fontWeight: FontWeight.w600)), SizedBox(height: 4), Text('● Дүрэмд суурилсан · Demo', style: TextStyle(color: _muted, fontSize: 11))])), PopupMenuButton<String>(tooltip: 'Чатын тохиргоо', onSelected: (v) {
        if (v == 'clear') setState(() { messages.removeRange(1, messages.length); });
        else _info(context, 'AI зөвлөхийн тухай', 'Алсын AI үйлчилгээ холбогдоогүй. Бүртгэлтэй мэдээлэл дээр дүрэм, ил тод тооцоолол ашиглана. Яриа зөвхөн энэ хуудасны түр санах ойд хадгалагдана.');
      }, itemBuilder: (_) => const [PopupMenuItem(value: 'about', child: Text('Зөвлөхийн тухай')), PopupMenuItem(value: 'clear', child: Text('Яриа цэвэрлэх'))]),
      ])),
      Expanded(child: ListView(controller: scroll, padding: const EdgeInsets.all(18), children: [
        Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(children: [
          const Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Алсын AI холбогдоогүй. Demo тооцоолол нь мэргэжлийн санхүүгийн зөвлөгөөг орлохгүй.', style: TextStyle(color: _muted, fontSize: 11, height: 1.6))),
          ...messages.map((m) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Align(alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft, child: FractionallySizedBox(widthFactor: .88, child: Column(crossAxisAlignment: m.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: m.mine ? _violet : Colors.white, borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(m.mine ? 18 : 4), bottomRight: Radius.circular(m.mine ? 4 : 18))), child: SelectableText(m.text, style: TextStyle(color: m.mine ? Colors.white : _ink, height: 1.65, fontSize: 13))),
            if (!m.mine) Padding(padding: const EdgeInsets.only(top: 5, left: 8), child: Text(m.estimate ? 'ТООЦООЛЛЫН ХУВИЛБАР · Баталгаа биш' : 'БҮРТГЭЛД СУУРИЛСАН · Demo', style: const TextStyle(color: _muted, fontSize: 9))),
          ]))))),
          const SizedBox(height: 8), _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Бүртгэлтэй гүйлгээний тойм', style: TextStyle(color: _ink, fontSize: 16)), const SizedBox(height: 6), const Text('Бүх хугацаа · Бүхэл төгрөгөөр тоймлов', style: TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 16),
            ...[MapEntry('Орлого', income), MapEntry('Зарлага', expense), MapEntry('Зөрүү', income - expense)].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(e.key, style: const TextStyle(color: _muted, fontSize: 12))), Text(_mnt(e.value), style: const TextStyle(color: _ink, fontWeight: FontWeight.w600, fontSize: 13))]))),
            if (widget.transactions.isEmpty) const Text('Гүйлгээ нэмсний дараа зөвлөгөө, тооцоолол гарна.', style: TextStyle(color: _muted, fontSize: 12)),
          ])),
        ]))),
      ])),
      Container(color: Colors.white, width: double.infinity, padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, children: ['Санхүүгийн тойм', 'Юунд хамгийн их зарцуулсан бэ?', 'Илүү их хуримтлуулах арга', 'Зорилгодоо яаж хүрэх вэ?'].map((q) => Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(backgroundColor: Colors.white, side: const BorderSide(color: _line), label: Text(q, style: const TextStyle(color: _violet, fontSize: 11)), onPressed: () => _send(q)))).toList())), const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: TextField(controller: input, minLines: 1, maxLines: 3, maxLength: 1000, textInputAction: TextInputAction.send, onChanged: (_) => setState(() {}), onSubmitted: (_) => _send(), decoration: _input('Санхүүгийн талаар асуугаарай').copyWith(counterText: '', contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)))), const SizedBox(width: 10), SizedBox(width: 48, height: 48, child: IconButton(tooltip: 'Зурвас илгээх', style: IconButton.styleFrom(backgroundColor: input.text.trim().isEmpty ? const Color(0xFFBDB0ED) : _violet, foregroundColor: Colors.white, disabledForegroundColor: Colors.white), onPressed: input.text.trim().isEmpty ? null : () => _send(), icon: const Icon(Icons.north_east)))]),
      ])))),
    ]));
  }
}

class _SalaryPlanDialog extends StatefulWidget {
  final String? saved;
  const _SalaryPlanDialog({this.saved});
  @override
  State<_SalaryPlanDialog> createState() => _SalaryPlanDialogState();
}
class _SalaryPlanDialogState extends State<_SalaryPlanDialog> {
  final form = GlobalKey<FormState>();
  late final TextEditingController amount;
  late final TextEditingController day;
  late final TextEditingController needs;
  late final TextEditingController wants;
  late final TextEditingController savings;
  @override
  void initState() {
    super.initState();
    final data = widget.saved == null ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(widget.saved!) as Map);
    amount = TextEditingController(text: '${data['amount'] ?? ''}');
    day = TextEditingController(text: '${data['day'] ?? 1}');
    needs = TextEditingController(text: '${data['needs'] ?? 50}');
    wants = TextEditingController(text: '${data['wants'] ?? 30}');
    savings = TextEditingController(text: '${data['savings'] ?? 20}');
  }
  @override
  void dispose() { for (final c in [amount, day, needs, wants, savings]) { c.dispose(); } super.dispose(); }
  Widget _field(String label, TextEditingController controller, int max, {bool positive = false}) => Padding(padding: const EdgeInsets.only(bottom: 14), child: TextFormField(controller: controller, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: _input(label), onChanged: (_) => setState(() {}), validator: (v) { final n = int.tryParse(v ?? ''); return n == null || n < (positive ? 1 : 0) || n > max ? 'Зөв дүн оруулна уу (${positive ? 1 : 0}–$max).' : null; }));
  @override
  Widget build(BuildContext context) {
    final total = int.tryParse(amount.text) ?? 0;
    int percent(TextEditingController c) => int.tryParse(c.text) ?? 0;
    return AlertDialog(title: const Text('Цалингийн өдрийн төлөвлөгөө'), content: SizedBox(width: 440, child: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Зөвхөн төлөвлөгөө хадгална. Автомат гүйлгээ, шилжүүлэг хийхгүй.', style: TextStyle(color: _muted, fontSize: 12, height: 1.6)), const SizedBox(height: 20),
      _field('Сарын цалин · ₮', amount, 999999999999, positive: true), _field('Цалин авах өдөр · 1–31', day, 31, positive: true),
      _field('Зайлшгүй хэрэгцээ · %', needs, 100), _field('Хүсэл, нэмэлт хэрэглээ · %', wants, 100), _field('Хуримтлал · %', savings, 100),
      Text('Хэрэгцээ: ${_mnt(total * percent(needs) / 100)}\nХүсэл: ${_mnt(total * percent(wants) / 100)}\nХуримтлал: ${_mnt(total * percent(savings) / 100)}', style: const TextStyle(color: _ink, height: 1.8)),
      if (percent(needs) + percent(wants) + percent(savings) != 100) const Text('Хуваарилалтын нийлбэр 100% байх ёстой.', style: TextStyle(color: Colors.red, fontSize: 12)),
    ])))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Болих')), TextButton(onPressed: () { if (!form.currentState!.validate() || percent(needs) + percent(wants) + percent(savings) != 100) return; Navigator.pop(context, jsonEncode({'amount': total, 'day': int.parse(day.text), 'needs': percent(needs), 'wants': percent(wants), 'savings': percent(savings)})); }, child: const Text('Хадгалах'))]);
  }
}