import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:kept_aom/viewmodels/category_provider.dart';
import 'package:kept_aom/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';

final dashboardTabProvider =
    StateProvider.autoDispose<int>((ref) => 0); // 0: Expense, 1: Income

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final categoryNotifier = ref.watch(categoryProvider);
    final selectedTab = ref.watch(dashboardTabProvider);

    final currentSummaries = selectedTab == 0
        ? dashboardState.expenseSummaries
        : dashboardState.incomeSummaries;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            bottom: 100 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(top: 8, bottom: 16),
            //   child: Center(
            //     child: Text(
            //       '${FormatUtils.formatSimpleDate(dashboardState.cycleStartDate)} - ${FormatUtils.formatSimpleDate(dashboardState.cycleEndDate.subtract(const Duration(days: 1)))}',
            //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //             color: AppColors.textSecondary,
            //             fontWeight: FontWeight.w600,
            //           ),
            //     ),
            //   ),
            // ),
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration(context).copyWith(
                  //color: Theme.of(context).,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                      '${FormatUtils.formatSimpleDate(dashboardState.cycleStartDate)} - ${FormatUtils.formatSimpleDate(dashboardState.cycleEndDate.subtract(const Duration(days: 1)))}',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        FormatUtils.formatNumber(dashboardState.totalBalance),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 32)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTab(
                      context,
                      ref,
                      index: 0,
                      label: 'Expense',
                      icon: FontAwesomeIcons.arrowDown,
                      color: AppColors.danger,
                      isSelected: selectedTab == 0,
                    ),
                  ),
                  Expanded(
                    child: _buildTab(
                      context,
                      ref,
                      index: 1,
                      label: 'Income',
                      icon: FontAwesomeIcons.arrowUp,
                      color: AppColors.success,
                      isSelected: selectedTab == 1,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 24),
            // Text(
            //   selectedTab == 0 ? 'Expense by Category' : 'Income by Category',
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            const SizedBox(height: 16),
            // Category List
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: currentSummaries.isEmpty
                  ? Center(
                      key: ValueKey('empty_$selectedTab'),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          selectedTab == 0
                              ? 'No expense data'
                              : 'No income data',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: ValueKey('list_$selectedTab'),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentSummaries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final summary = currentSummaries[index];
                        final category = categoryNotifier
                            .getCategoryById(summary.categoryId);
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
                                      color: (selectedTab == 0
                                              ? AppColors.danger
                                              : AppColors.success)
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
                                                  color:
                                                      AppColors.textSecondary),
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
                                          color: selectedTab == 0
                                              ? AppColors.danger
                                              : AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        '${summary.percentage.toStringAsFixed(1)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(dashboardTabProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
