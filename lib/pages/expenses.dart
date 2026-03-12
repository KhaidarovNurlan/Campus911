import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/colors.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/models.dart';
import '../data/providers.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

const List<ExpenseCategory> _categories = [
  ExpenseCategory(id: 'transport', name: 'Transport', icon: Icons.directions_bus_rounded),
  ExpenseCategory(id: 'food', name: 'Food', icon: Icons.restaurant_rounded),
  ExpenseCategory(id: 'books', name: 'Books', icon: Icons.menu_book_rounded),
  ExpenseCategory(id: 'housing', name: 'Housing', icon: Icons.home_rounded),
  ExpenseCategory(id: 'entertainment', name: 'Entertainment', icon: Icons.sports_esports_rounded),
  ExpenseCategory(id: 'health', name: 'Health', icon: Icons.medical_services_rounded),
  ExpenseCategory(id: 'clothing', name: 'Clothing', icon: Icons.checkroom_rounded),
  ExpenseCategory(id: 'communication', name: 'Communication', icon: Icons.stay_current_portrait_rounded),
];

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() async {
      if (!mounted) return;
      final user = context.read<UserProvider>().user;
      if (user != null) {
        await context.read<ExpenseProvider>().loadExpenses(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Statistics'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_StatisticsTab(), _HistoryTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_expense_btn",
        onPressed: () => _showAddExpenseDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddExpenseBottomSheet(),
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    final totalAmount = expenseProvider.totalAmount;
    final expensesByCategory = expenseProvider.expensesByCategory;

    if (expenses.isEmpty) return _EmptyExpenses();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TotalAmountCard(totalAmount: totalAmount),
          const SizedBox(height: 32),
          _sectionTitle(context, 'Expenses by category'),
          const SizedBox(height: 16),
          _PieChartWidget(expensesByCategory: expensesByCategory),
          const SizedBox(height: 32),
          _sectionTitle(context, 'Activity schedule'),
          const SizedBox(height: 16),
          _LineChartWidget(expenses: expenses),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textGrey,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _TotalAmountCard extends StatelessWidget {
  final double totalAmount;
  const _TotalAmountCard({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'en_US');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total invested',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${currencyFormat.format(totalAmount).replaceAll(',', ' ')} ₸',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final Map<String, double> expensesByCategory;
  const _PieChartWidget({required this.expensesByCategory});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: sortedEntries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    color: _getColor(entry.key),
                    radius: 12,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: sortedEntries.take(4).map((e) => _buildLegendItem(context, e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, MapEntry<String, double> entry) {
    final cat = _categories.firstWhere((c) => c.id == entry.key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: _getColor(entry.key), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cat.name,
              style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String id) {
    switch (id) {
      case 'food': return AppColors.food;
      case 'transport': return AppColors.transport;
      case 'housing': return AppColors.housing;
      case 'health': return AppColors.health;
      default: return AppColors.primary;
    }
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _LineChartWidget({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final spots = expenses.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 24, right: 24, left: 8, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.primary.withValues(alpha: 0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;

    if (expenses.isEmpty) return _EmptyExpenses();

    final Map<String, List<ExpenseModel>> groupedExpenses = {};
    for (var expense in expenses) {
      final dateKey = DateFormat('d MMMM yyyy', 'en_US').format(expense.date);
      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) {
        final dateA = groupedExpenses[a]!.first.date;
        final dateB = groupedExpenses[b]!.first.date;
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayExpenses = groupedExpenses[date]!;
        final dayTotal = dayExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    '${dayTotal.toStringAsFixed(0)} ₸',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            ...dayExpenses.map((expense) => _ExpenseHistoryCard(expense: expense)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _ExpenseHistoryCard extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseHistoryCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final cat = _categories.firstWhere((c) => c.id == expense.category,
        orElse: () => _categories.first);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (expense.note != null)
                  Text(expense.note!, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '-${expense.amount.toInt()} ₸',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 64, color: AppColors.textGrey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }
}

class _AddExpenseBottomSheet extends StatefulWidget {
  const _AddExpenseBottomSheet();

  @override
  State<_AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<_AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'food';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Add', style: Theme.of(context).textTheme.headlineSmall)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Amount',
                hint: '...',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(padding: EdgeInsets.all(12), child: Text('₸', style: TextStyle(fontSize: 20))),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Enter the correct amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
              ),
              const SizedBox(height: 8),
              _CategorySelector(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) => setState(() => _selectedCategory = category),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description (optional)',
                hint: '...',
                controller: _noteController,
                maxLines: 2,
                prefixIcon: const Icon(Icons.note_rounded),
              ),
              const SizedBox(height: 16),
              _DateSelector(
                selectedDate: _selectedDate,
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Add',
                onPressed: _saveExpense,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    await context.read<ExpenseProvider>().addExpense(user.id, expense);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${expense.amount.toStringAsFixed(0)}₸ expense added'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const _CategorySelector({required this.selectedCategory, required this.onCategoryChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = selectedCategory == category.id;

        return InkWell(
          onTap: () => onCategoryChanged(category.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBackground
                      : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textGrey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  size: 28,
                  color: isSelected ? AppColors.primary : AppColors.textGrey,
                ),
                const SizedBox(height: 4),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateSelector({required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) onDateChanged(pickedDate);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  DateFormat('d MMMM yyyy', 'en_US').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}