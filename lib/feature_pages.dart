import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'finance_models.dart';
import 'finance_store.dart';
import 'main.dart';

Widget pageContainer(BuildContext context, List<Widget> children) {
  final mobile = MediaQuery.sizeOf(context).width < 680;
  return SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.all(mobile ? 16 : 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    super.key,
    required this.store,
    required this.onAdd,
    required this.onEdit,
  });
  final FinanceStore store;
  final VoidCallback onAdd;
  final ValueChanged<FinanceEntry> onEdit;
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String filter = 'Бүгд';
  String search = '';
  @override
  Widget build(BuildContext context) {
    final entries = widget.store.entries.where((entry) {
      final matchesFilter =
          filter == 'Бүгд' ||
          (filter == 'Орлого' && entry.isIncome) ||
          (filter == 'Зарлага' && !entry.isIncome);
      final matchesSearch =
          entry.title.toLowerCase().contains(search.toLowerCase()) ||
          entry.category.toLowerCase().contains(search.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    return pageContainer(context, [
      PageHeading(
        eyebrow: 'МӨНГӨНИЙ УРСГАЛ',
        title: 'Гүйлгээ',
        subtitle: 'Орлого, зарлагаа нэг дороос хянаарай.',
        action: FilledButton.icon(
          onPressed: widget.onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Гүйлгээ нэмэх'),
        ),
      ),
      const SizedBox(height: 22),
      AppPanel(
        child: Wrap(
          spacing: 30,
          runSpacing: 20,
          children: [
            _total(
              'НИЙТ ОРЛОГО',
              formatMoney(widget.store.income, sign: true),
              const Color(0xFF55A582),
            ),
            _total(
              'НИЙТ ЗАРЛАГА',
              formatMoney(-widget.store.expenses),
              const Color(0xFFD77786),
            ),
            _total(
              'ЦЭВЭР МӨНГӨН УРСГАЛ',
              formatMoney(widget.store.balance),
              ink,
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Гүйлгээ хайх...',
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              children: ['Бүгд', 'Орлого', 'Зарлага']
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: filter == value,
                      onSelected: (_) => setState(() => filter = value),
                    ),
                  )
                  .toList(),
            ),
            const Divider(height: 28),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 35),
                child: Center(
                  child: Text(
                    'Одоогоор гүйлгээ олдсонгүй.\nЭхний орлого эсвэл зарлагаа нэмээрэй.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ...entries.map((entry) => _entryTile(entry)),
          ],
        ),
      ),
    ]);
  }

  Widget _total(String label, String value, Color color) => SizedBox(
    width: 190,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _entryTile(FinanceEntry entry) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: entry.isIncome
              ? const Color(0xFFE9F7F0)
              : const Color(0xFFFFEDF0),
          child: Icon(
            entry.isIncome ? Icons.south_west : Icons.north_east,
            size: 18,
            color: entry.isIncome
                ? const Color(0xFF55A582)
                : const Color(0xFFD77786),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '${entry.category} · ${entry.paymentMethod}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: entry.isIncome ? const Color(0xFF55A582) : ink,
              ),
            ),
            Text(
              '${entry.date.year}.${entry.date.month}.${entry.date.day}',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
        PopupMenuButton<String>(
          tooltip: 'Гүйлгээний үйлдэл',
          onSelected: (action) async {
            if (action == 'edit') {
              widget.onEdit(entry);
            } else {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Гүйлгээг устгах уу?'),
                  content: Text('“${entry.title}” гүйлгээг устгана.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Болих'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Устгах'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) widget.store.deleteEntry(entry.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Засах')),
            PopupMenuItem(value: 'delete', child: Text('Устгах')),
          ],
        ),
      ],
    ),
  );
}

class TransactionEditor extends StatefulWidget {
  const TransactionEditor({super.key, required this.store, this.existing});
  final FinanceStore store;
  final FinanceEntry? existing;
  @override
  State<TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController category = TextEditingController(
    text: widget.existing?.category ?? '',
  );
  late final TextEditingController amount = TextEditingController(
    text: widget.existing?.amount.abs().toString() ?? '',
  );
  late bool income = widget.existing?.isIncome ?? false;

  @override
  void dispose() {
    title.dispose();
    category.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      6,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 22,
    ),
    child: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Гүйлгээ нэмэх' : 'Гүйлгээ засах',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Зарлага')),
                  ButtonSegment(value: true, label: Text('Орлого')),
                ],
                selected: {income},
                onSelectionChanged: (values) =>
                    setState(() => income = values.first),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Гүйлгээний нэр'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Нэрээ оруулна уу'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: category,
                decoration: const InputDecoration(labelText: 'Ангилал'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ангиллаа оруулна уу'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Дүн (₮)'),
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                    ? '0-ээс их бүхэл дүн оруулна уу'
                    : null,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final value = int.parse(amount.text);
                    widget.store.saveEntry(
                      FinanceEntry(
                        id:
                            widget.existing?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        title: title.text.trim(),
                        category: category.text.trim(),
                        amount: income ? value : -value,
                        date: widget.existing?.date ?? DateTime.now(),
                        paymentMethod: widget.existing?.paymentMethod ?? 'Карт',
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Хадгалах'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key, required this.store});
  final FinanceStore store;
  @override
  Widget build(BuildContext context) {
    const limits = [
      ('Хүнс', 750000, '🍜'),
      ('Тээвэр', 350000, '🚕'),
      ('Худалдан авалт', 450000, '🛍'),
    ];
    return pageContainer(context, [
      const PageHeading(
        eyebrow: 'САНХҮҮГИЙН ТӨЛӨВЛӨГӨӨ',
        title: 'Төсөв',
        subtitle: 'Ангилал бүрийн зарцуулалтаа хянаарай.',
      ),
      const SizedBox(height: 24),
      ...limits.map((item) {
        final spent = store.spentIn(item.$1);
        final fraction = (spent / item.$2).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.$3, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.$1,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${(fraction * 100).round()}%',
                      style: const TextStyle(
                        color: brand,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: fraction,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(8),
                  color: fraction >= .9 ? Colors.orange : brand,
                  backgroundColor: const Color(0xFFEDEAF5),
                ),
                const SizedBox(height: 11),
                Text(
                  '${formatMoney(spent)} / ${formatMoney(item.$2)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }),
      const Text(
        'Төсвийн хязгаар нь demo жишээ утга. Зарцуулалт нь бүртгэсэн гүйлгээнээс тооцогдоно.',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    ]);
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key, required this.store, required this.onAdd});
  final FinanceStore store;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => pageContainer(context, [
    PageHeading(
      eyebrow: 'ИРЭЭДҮЙН ТӨЛӨВЛӨГӨӨ',
      title: 'Хуримтлалын зорилго',
      subtitle: 'Том зорилгыг жижиг, тогтвортой алхмаар биелүүлээрэй.',
      action: FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Зорилго үүсгэх'),
      ),
    ),
    const SizedBox(height: 23),
    if (store.goals.isEmpty)
      AppPanel(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Text('Танд идэвхтэй хуримтлалын зорилго алга.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onAdd,
                  child: const Text('Зорилго үүсгэх'),
                ),
              ],
            ),
          ),
        ),
      ),
    ...store.goals.asMap().entries.map(
      (item) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: item.key == 0
            ? _featuredGoal(context, item.value)
            : _goalCard(context, item.value),
      ),
    ),
  ]);

  Widget _featuredGoal(BuildContext context, SavingsGoal goal) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF201638), Color(0xFF4A2C94)],
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(goal.emoji, style: const TextStyle(fontSize: 52))),
        Center(
          child: SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: goal.progress,
                    strokeWidth: 5,
                    color: const Color(0xFF84C9B4),
                    backgroundColor: Colors.white24,
                  ),
                ),
                Text(
                  '${(goal.progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 23),
        const Text(
          'НЭН ТЭРГҮҮНИЙ',
          style: TextStyle(
            color: Color(0xFFC4BAE7),
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          goal.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        Text(
          '${goal.deadline} хүртэл',
          style: const TextStyle(color: Color(0xFFC4BAE7), fontSize: 11),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _goalAmount('ЦУГЛУУЛСАН', goal.saved),
            _goalAmount('ЗОРИЛТОТ ДҮН', goal.target),
            _goalAmount('ҮЛДСЭН', goal.remaining),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: goal.progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF82C8B2),
          backgroundColor: Colors.white24,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _contribute(context, goal),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Хуримтлал нэмэх'),
          style: FilledButton.styleFrom(backgroundColor: brand),
        ),
      ],
    ),
  );

  Widget _goalAmount(String label, int amount) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFFBEB4D8), fontSize: 9),
      ),
      const SizedBox(height: 5),
      Text(
        formatMoney(amount),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    ],
  );

  Widget _goalCard(BuildContext context, SavingsGoal goal) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(goal.emoji, style: const TextStyle(fontSize: 25)),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${goal.deadline} хүртэл',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Зорилгын үйлдэл',
              onSelected: (action) async {
                if (action == 'add') {
                  _contribute(context, goal);
                } else {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Зорилгыг устгах уу?'),
                      content: Text('“${goal.title}” зорилгыг устгана.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Болих'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Устгах'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) store.deleteGoal(goal.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'add', child: Text('Хуримтлал нэмэх')),
                PopupMenuItem(value: 'delete', child: Text('Устгах')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '${formatMoney(goal.saved)} / ${formatMoney(goal.target)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 9),
        LinearProgressIndicator(
          value: goal.progress,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          color: brand,
          backgroundColor: const Color(0xFFEDEAF5),
        ),
        const SizedBox(height: 7),
        Text(
          '${(goal.progress * 100).round()}%',
          style: const TextStyle(color: brand, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Future<void> _contribute(BuildContext context, SavingsGoal goal) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${goal.title} · хуримтлал нэмэх'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Дүн (₮)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null || value <= 0) return;
              store.addContribution(goal.id, value);
              Navigator.pop(context);
            },
            child: const Text('Нэмэх'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class GoalEditor extends StatefulWidget {
  const GoalEditor({super.key, required this.store});
  final FinanceStore store;
  @override
  State<GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<GoalEditor> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final target = TextEditingController();
  final saved = TextEditingController();
  final deadline = TextEditingController();
  @override
  void dispose() {
    title.dispose();
    target.dispose();
    saved.dispose();
    deadline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      6,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 22,
    ),
    child: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Шинэ зорилго',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Зорилгын нэр'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Зорилгын нэр оруулна уу'
                    : null,
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Зорилтот дүн (₮)',
                ),
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                    ? '0-ээс их бүхэл дүн оруулна уу'
                    : null,
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: saved,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Одоогоор хуримтлуулсан дүн (₮)',
                ),
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: deadline,
                decoration: const InputDecoration(labelText: 'Хүрэх хугацаа'),
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final goalTarget = int.parse(target.text);
                    final initial = int.tryParse(saved.text) ?? 0;
                    if (initial < 0 || initial > goalTarget) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Хуримтлал 0-ээс зорилтот дүнгийн хооронд байх ёстой.',
                          ),
                        ),
                      );
                      return;
                    }
                    widget.store.addGoal(
                      SavingsGoal(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        title: title.text.trim(),
                        target: goalTarget,
                        saved: initial,
                        deadline: deadline.text.trim().isEmpty
                            ? 'Хугацаа тодорхойгүй'
                            : deadline.text.trim(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Зорилго үүсгэх'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AdvisorPage extends StatelessWidget {
  const AdvisorPage({super.key, required this.store});
  final FinanceStore store;
  @override
  Widget build(BuildContext context) {
    final categories = store.expenseCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = categories.isEmpty ? null : categories.first;
    return pageContainer(context, [
      const PageHeading(
        eyebrow: 'САНХҮҮГИЙН ТУСЛАХ',
        title: 'AI зөвлөх',
        subtitle: 'Бүртгэлдээ үндэслэн санхүүгээ ойлгоорой.',
      ),
      const SizedBox(height: 22),
      AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: brand),
                SizedBox(width: 9),
                Text(
                  'Дүрэмд суурилсан шинжилгээ',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'AI үйлчилгээ одоогоор холбогдоогүй тул дүрэмд суурилсан шинжилгээ ашиглаж байна.',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30),
            if (top == null)
              const Text('Зөвлөмж гаргахад гүйлгээний мэдээлэл хэрэгтэй.'),
            if (top != null)
              Text(
                'Бүртгэсэн зарлага дундаас “${top.key}” хамгийн өндөр байна: ${formatMoney(top.value)}. '
                'Нийт зарлагын ${(top.value * 100 / store.expenses).round()}%-ийг эзэлж байна.',
              ),
            const SizedBox(height: 12),
            Text(
              'Орлого: ${formatMoney(store.income)} · Зарлага: ${formatMoney(store.expenses)} · '
              'Зөрүү: ${formatMoney(store.balance)}',
            ),
            const SizedBox(height: 17),
            const Text(
              'Энэ нь зөвхөн бүртгэсэн demo өгөгдлийн тооцоолол бөгөөд санхүүгийн үр дүнг баталгаажуулахгүй.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    ]);
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => pageContainer(context, [
    const PageHeading(
      eyebrow: 'ХУВИЙН БҮРТГЭЛ',
      title: 'Профайл',
      subtitle: 'Demo орчны мэдээлэл',
    ),
    const SizedBox(height: 22),
    const AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: brand,
              child: Text('Б', style: TextStyle(color: Colors.white)),
            ),
            title: Text('Бат-Эрдэнэ'),
            subtitle: Text('Demo хэрэглэгч'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text('Үндсэн валют'),
            trailing: Text('MNT · ₮'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Хэл'),
            trailing: Text('Монгол'),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Өгөгдөл'),
            subtitle: Text(
              'Энэ хувилбарын өөрчлөлт зөвхөн апп ажиллах хугацаанд хадгалагдана.',
            ),
          ),
        ],
      ),
    ),
  ]);
}
