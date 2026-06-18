import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/today_transaction.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kept_aom/utils/constants.dart';
import 'package:kept_aom/utils/format_utils.dart';

final isMonthlyBalanceProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(transactionProvider);
    final isMonthly = ref.watch(isMonthlyBalanceProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    final firstName = fullName.split(' ')[0];

    final double balance;
    if (isMonthly) {
      final now = DateTime.now();
      final DateTime cycleStartDate;
      final DateTime cycleEndDate;

      if (now.day >= AppConstants.startDayOfMonth) {
        cycleStartDate = DateTime(
          now.year,
          now.month,
          AppConstants.startDayOfMonth,
        );
        // Next month, start day
        cycleEndDate = DateTime(
          now.year,
          now.month + 1,
          AppConstants.startDayOfMonth,
        );
      } else {
        cycleStartDate = DateTime(
          now.year,
          now.month - 1,
          AppConstants.startDayOfMonth,
        );
        cycleEndDate = DateTime(
          now.year,
          now.month,
          AppConstants.startDayOfMonth,
        );
      }

      final monthlyTransactions = provider.transactions.where((t) {
        return t.date.isAfter(
              cycleStartDate.subtract(const Duration(seconds: 1)),
            ) &&
            t.date.isBefore(cycleEndDate);
      });

      balance = monthlyTransactions.fold<double>(
        0,
        (sum, transaction) => sum + _signedBalanceAmount(transaction),
      );
    } else {
      balance = provider.transactions.fold<double>(
        0,
        (sum, transaction) => sum + _signedBalanceAmount(transaction),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: 'Sign out',
            padding: EdgeInsets.zero,
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.account_circle, size: 28)
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text('$firstName', overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              tooltip: 'Refresh transactions',
              onPressed: () {
                provider.fetchTransactions();
              },
              icon: const Icon(Icons.replay_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          accountCard(context, balance, isMonthly, () {
            ref.read(isMonthlyBalanceProvider.notifier).state = !isMonthly;
          }),
          Column(
            children: [
              //TO DO: Add Saving Goals
              // Text(
              //   'Saving Goals',
              //   style: Theme.of(context).textTheme.displaySmall,
              // ),
              // SizedBox(
              //   height: 120,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     itemCount: sgProvider.savingGoals.length,
              //     separatorBuilder: (_, __) => const SizedBox(width: 12),
              //     itemBuilder: (context, index) {
              //       final goal = sgProvider.savingGoals[index];
              //       final emoji = goal.name.characters.first;
              //       final name = goal.name.characters.skip(1).toString().trim();

              //       return Container(
              //         width: 120,
              //         decoration: BoxDecoration(
              //           color: Theme.of(context).cardColor,
              //           borderRadius: BorderRadius.circular(16),
              //           boxShadow: const [
              //             BoxShadow(
              //               color: Colors.black12,
              //               blurRadius: 8,
              //               offset: Offset(0, 4),
              //             ),
              //           ],
              //         ),
              //         child: Stack(
              //           children: [
              //             Positioned.fill(
              //               child: Align(
              //                 alignment: Alignment.bottomRight,
              //                 child: Opacity(
              //                   opacity: 0.33,
              //                   child: Text(
              //                     emoji,
              //                     style: const TextStyle(fontSize: 72),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             Padding(
              //               padding: const EdgeInsets.all(16),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     name,
              //                     style:
              //                         Theme.of(context).textTheme.titleMedium,
              //                     maxLines: 1,
              //                     overflow: TextOverflow.ellipsis,
              //                   ),
              //                   const Spacer(),
              //                   Text(
              //                     '${goal.stored}/${goal.target}',
              //                     style: Theme.of(context).textTheme.bodyMedium,
              //                   ),
              //                 ],
              //               ),
              //             ),
              //             // Progress bar à¸—à¸µà¹ˆà¸¥à¹ˆà¸²à¸‡à¸ªà¸¸à¸”
              //             Positioned(
              //               left: 0,
              //               right: 0,
              //               bottom: 0,
              //               child: ClipRRect(
              //                 borderRadius: const BorderRadius.vertical(
              //                     bottom: Radius.circular(16)),
              //                 child: LinearProgressIndicator(
              //                   borderRadius:
              //                       const BorderRadius.all(Radius.circular(8)),
              //                   value: (goal.target > 0)
              //                       ? (goal.stored / goal.target)
              //                           .clamp(0.0, 1.0)
              //                       : 0.0,
              //                   minHeight: 8,
              //                   backgroundColor: AppColors.border.withAlpha(50),
              //                   valueColor: const AlwaysStoppedAnimation<Color>(
              //                     AppColors.primary,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          const Expanded(child: TodayTransactions()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        onPressed: () {
          context.push('/addtransaction');
          // showModalBottomSheet(
          //   context: context,
          //   backgroundColor: Colors.transparent,
          //   builder: (context) => Container(
          //     padding: const EdgeInsets.all(24),
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).cardColor,
          //       borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          //     ),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Container(
          //           width: 40,
          //           height: 4,
          //           margin: const EdgeInsets.only(bottom: 24),
          //           decoration: BoxDecoration(
          //             color: Theme.of(context).disabledColor.withOpacity(0.2),
          //             borderRadius: BorderRadius.circular(2),
          //           ),
          //         ),
          //         Text(
          //           'Choose Entry Mode',
          //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //         ),
          //         const SizedBox(height: 24),
          //         Row(
          //           children: [
          //             Expanded(
          //               child: InkWell(
          //                 onTap: () {
          //                   Navigator.pop(context);
          //                   context.push('/addtransaction');
          //                 },
          //                 child: Container(
          //                   padding: const EdgeInsets.all(16),
          //                   decoration: BoxDecoration(
          //                     color: Theme.of(context).primaryColor.withOpacity(0.1),
          //                     borderRadius: BorderRadius.circular(16),
          //                     border: Border.all(
          //                       color: Theme.of(context).primaryColor.withOpacity(0.2),
          //                     ),
          //                   ),
          //                   child: Column(
          //                     children: [
          //                       Icon(Icons.edit_note_rounded,
          //                           size: 32, color: Theme.of(context).primaryColor),
          //                       const SizedBox(height: 8),
          //                       const Text('Manual',
          //                           style: TextStyle(fontWeight: FontWeight.w600)),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             const SizedBox(width: 16),
          //             Expanded(
          //               child: InkWell(
          //                 onTap: () {
          //                   Navigator.pop(context);
          //                   context.push('/addtransaction?scan=true');
          //                 },
          //                 child: Container(
          //                   padding: const EdgeInsets.all(16),
          //                   decoration: BoxDecoration(
          //                     color: Theme.of(context).primaryColor.withOpacity(0.1),
          //                     borderRadius: BorderRadius.circular(16),
          //                     border: Border.all(
          //                       color: Theme.of(context).primaryColor.withOpacity(0.2),
          //                     ),
          //                   ),
          //                   child: Column(
          //                     children: [
          //                       Icon(Icons.document_scanner_rounded,
          //                           size: 32, color: Theme.of(context).primaryColor),
          //                       const SizedBox(height: 8),
          //                       const Text('Scan Slip',
          //                           style: TextStyle(fontWeight: FontWeight.w600)),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //         const SizedBox(height: 16),
          //       ],
          //     ),
          //   ),
          //);
        },
        label: Text(
          'Add Transaction',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget accountCard(
    BuildContext context,
    double balance,
    bool isMonthly,
    VoidCallback onToggle,
  ) {
    String balanceString = FormatUtils.formatNumber(balance.toDouble());
    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.bottomRight,
          radius: 3,
          colors: [Color(0xFF3F51B5), Colors.black87],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Display cycle label if monthly? Optional but good for UX.
              if (isMonthly) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  balanceString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isMonthly ? Icons.calendar_month : Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.8),
              ),
              tooltip: isMonthly
                  ? 'Show All Time Balance'
                  : 'Show Monthly Balance',
            ),
          ),
        ],
      ),
    );
  }
}

double _signedBalanceAmount(Transaction transaction) {
  final amount = transaction.amount.abs();
  return transaction.typeId == 1 ? -amount : amount;
}
