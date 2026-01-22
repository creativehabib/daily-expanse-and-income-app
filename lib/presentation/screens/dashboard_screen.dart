import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/date_filter_provider.dart';
import '../providers/providers.dart';
import '../widgets/date_filter_bar.dart';
import 'add_transaction_sheet.dart';

final balancePrivacyModeProvider = StateProvider<bool>((ref) => false);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profileName = settings.profileName.trim().isEmpty
        ? 'Your profile'
        : settings.profileName.trim();
    final profileEmail = settings.profileEmail.trim().isEmpty
        ? 'No email set'
        : settings.profileEmail.trim();

    final transactions = ref.watch(filteredTransactionsProvider);

    final totalIncome = transactions
        .where((entry) => entry.type == 'income')
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final totalExpense = transactions
        .where((entry) => entry.type == 'expense')
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final totalBalance = totalIncome - totalExpense;

    final formatter = NumberFormat.currency(symbol: '৳');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Expense Tracker',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.go('/reports'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0B0F0F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              accountName: Text(
                profileName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              accountEmail: Text(
                profileEmail,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            _DrawerTile(
              icon: Icons.analytics_outlined,
              label: 'Reports',
              onTap: () => context.go('/reports'),
            ),
            _DrawerTile(
              icon: Icons.category_outlined,
              label: 'Categories',
              onTap: () => context.go('/categories'),
            ),
            _DrawerTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Budget',
              onTap: () => context.go('/budget'),
            ),
            _DrawerTile(
              icon: Icons.notifications_outlined,
              label: 'Reminders',
              onTap: () => context.go('/reminders'),
            ),
            _DrawerTile(
              icon: Icons.upload_file_outlined,
              label: 'Export Data',
              onTap: () => context.go('/export'),
            ),
            _DrawerTile(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => context.push('/about'),
            ),
            _DrawerTile(
              icon: Icons.contact_support_outlined,
              label: 'Contact',
              onTap: () => context.push('/contact'),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DateFilterBar(),
          const SizedBox(height: 16),
          _BalanceCard(
            totalBalance: formatter.format(totalBalance),
            income: formatter.format(totalIncome),
            expense: formatter.format(totalExpense),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Transactions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const _EmptyState(
              message: 'No transactions yet. Add your first entry!',
            )
          else
            ...transactions.take(5).map(
                  (entry) => _TransactionTile(
                title: entry.note.isEmpty ? 'No note' : entry.note,
                date: DateFormat.yMMMd().format(entry.date),
                amount: formatter.format(entry.amount),
                isIncome: entry.type == 'income',
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),

      /// premium gradient FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _GradientFab(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddTransactionSheet(),
          );
        },
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0B0F0F)],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0F766E)),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({
    required this.totalBalance,
    required this.income,
    required this.expense,
  });

  final String totalBalance;
  final String income;
  final String expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(balancePrivacyModeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0B0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ref.read(balancePrivacyModeProvider.notifier).state =
              !isPrivacyMode;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPrivacyMode ? '****' : totalBalance,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isPrivacyMode
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              // Widgets below are not const due to params; keep as is in your codebase if needed.
            ],
          ),
          Row(
            children: [
              _BalanceMetric(
                label: 'Income',
                value: income,
                color: const Color(0xFFB8FFEE),
                icon: Icons.arrow_downward,
              ),
              const SizedBox(width: 16),
              _BalanceMetric(
                label: 'Expense',
                value: expense,
                color: const Color(0xFFFFD2D2),
                icon: Icons.arrow_upward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  final String title;
  final String date;
  final String amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final accentColor =
    isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Color(0xFF0F766E),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
