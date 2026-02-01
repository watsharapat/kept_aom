import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:kept_aom/viewmodels/category_provider.dart';
import 'package:kept_aom/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final categoryNotifier = ref.watch(categoryProvider);

    // Debug print expense by category values
    for (var summary in dashboardState.categorySummaries) {
      debugPrint('Category ${summary.categoryId}: ${summary.totalAmount}');
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 80,
        leadingWidth: 200,
        leading: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          margin:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 100 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                '${FormatUtils.formatSimpleDate(dashboardState.cycleStartDate)} - ${FormatUtils.formatSimpleDate(dashboardState.cycleEndDate.subtract(const Duration(days: 1)))}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration(context).copyWith(
                color: Theme.of(context).primaryColor,
                image: const DecorationImage(
                  image: AssetImage('lib/assets/images/noise.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: AppColors.textPrimaryOnDark.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FormatUtils.formatNumber(dashboardState.totalBalance),
                    style: const TextStyle(
                      color: AppColors.textPrimaryOnDark,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Income / Expense Row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Income',
                    dashboardState.totalIncome,
                    AppColors.success,
                    FontAwesomeIcons.arrowUp,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Expense',
                    dashboardState.totalExpense,
                    AppColors.danger,
                    FontAwesomeIcons.arrowDown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Expense by Category',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Category List
            dashboardState.categorySummaries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No expense data',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardState.categorySummaries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final summary = dashboardState.categorySummaries[index];
                      final category =
                          categoryNotifier.getCategoryById(summary.categoryId);
                      final categoryName = category?.name ?? 'No Category';
                      final categoryIcon = category?.icon ?? '📦';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppStyles.cardDecoration(context),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      categoryIcon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        categoryName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${summary.transactionCount} transactions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      FormatUtils.formatNumber(
                                          summary.totalAmount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                    // Text(
                                    //   '${summary.percentage.toStringAsFixed(1)}%',
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .bodySmall
                                    //       ?.copyWith(
                                    //           color: AppColors.textSecondary),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                            // const SizedBox(height: 12),
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(4),
                            //   child: LinearProgressIndicator(
                            //     value: summary.percentage / 100,
                            //     backgroundColor: Theme.of(context)
                            //         .disabledColor
                            //         .withValues(alpha: 0.2),
                            //     valueColor: AlwaysStoppedAnimation<Color>(
                            //         Theme.of(context).primaryColor),
                            //     minHeight: 6,
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            FormatUtils.formatNumber(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
