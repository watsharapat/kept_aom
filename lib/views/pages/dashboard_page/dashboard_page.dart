import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/router/router.dart';
import 'package:kept_aom/utils/constants.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:kept_aom/viewmodels/category_provider.dart';
import 'package:kept_aom/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _expenseScrollController;
  late final ScrollController _incomeScrollController;
  bool _isHeaderCollapsed = false;
  bool _canPullToExpand = false;
  double _expandPullDistance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expenseScrollController = ScrollController();
    _incomeScrollController = ScrollController();
    _tabController.addListener(_syncHeaderWithListScroll);
    _expenseScrollController.addListener(_syncHeaderWithListScroll);
    _incomeScrollController.addListener(_syncHeaderWithListScroll);
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncHeaderWithListScroll);
    _expenseScrollController.removeListener(_syncHeaderWithListScroll);
    _incomeScrollController.removeListener(_syncHeaderWithListScroll);
    _tabController.dispose();
    _expenseScrollController.dispose();
    _incomeScrollController.dispose();
    super.dispose();
  }

  void _syncHeaderWithListScroll() {
    final activeScrollController = _tabController.index == 0
        ? _expenseScrollController
        : _incomeScrollController;
    final activeOffset = activeScrollController.hasClients
        ? activeScrollController.offset
        : 0.0;
    if (!_isHeaderCollapsed && activeOffset > 72) {
      setState(() {
        _isHeaderCollapsed = true;
        _canPullToExpand = false;
        _expandPullDistance = 0;
      });
    }
  }

  bool _handleExpandPull(ScrollNotification notification) {
    if (!_isHeaderCollapsed) {
      return false;
    }

    if (notification is ScrollEndNotification) {
      _expandPullDistance = 0;
      _canPullToExpand = notification.metrics.pixels <= 0;
      return false;
    }

    if (notification.metrics.pixels > 0) {
      _expandPullDistance = 0;
      _canPullToExpand = false;
      return false;
    }

    if (!_canPullToExpand) {
      return false;
    }

    if (notification is OverscrollNotification && notification.overscroll < 0) {
      _expandPullDistance += -notification.overscroll;
    } else if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null &&
        (notification.scrollDelta ?? 0) < 0) {
      _expandPullDistance += -(notification.scrollDelta ?? 0);
    }

    if (_expandPullDistance >= 56) {
      _expandPullDistance = 0;
      setState(() {
        _isHeaderCollapsed = false;
        _canPullToExpand = false;
      });
    }

    return false;
  }

  Future<void> _pickPeriodAnchor(
    BuildContext context,
    DashboardPeriod period,
    DateTime selectedDate,
  ) async {
    final pickedDate = await _showDashboardPeriodPicker(
      context,
      period: period,
      initialDate: selectedDate,
    );

    if (pickedDate != null) {
      ref.read(dashboardAnchorDateProvider.notifier).state = pickedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final selectedPeriod = ref.watch(dashboardPeriodProvider);
    final selectedDate = ref.watch(dashboardAnchorDateProvider);
    final categoryNotifier = ref.watch(categoryProvider);
    final dateRangeLabel = _formatDateRange(
      dashboardState.cycleStartDate,
      dashboardState.cycleEndDate,
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _DashboardSummaryCard(
            isCollapsed: _isHeaderCollapsed,
            dashboardState: dashboardState,
            selectedPeriod: selectedPeriod,
            selectedDate: selectedDate,
            dateRangeLabel: dateRangeLabel,
            onPeriodChanged: (period) {
              ref.read(dashboardPeriodProvider.notifier).state = period;
            },
            onPickPeriod: () {
              _pickPeriodAnchor(context, selectedPeriod, selectedDate);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                indicatorWeight: 0,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                unselectedLabelColor: _dashboardSecondaryText(context),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.arrowDown,
                          size: 14,
                          color: AppColors.danger,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Expense',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.arrowUp,
                          size: 14,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Income',
                          style: TextStyle(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SummaryTabView(
                  scrollController: _expenseScrollController,
                  onPullToExpand: _handleExpandPull,
                  isExpense: true,
                  summaries: dashboardState.expenseSummaries,
                  categoryNotifier: categoryNotifier,
                  cycleStartDate: dashboardState.cycleStartDate,
                  cycleEndDate: dashboardState.cycleEndDate,
                  dateRangeLabel: dateRangeLabel,
                ),
                _SummaryTabView(
                  scrollController: _incomeScrollController,
                  onPullToExpand: _handleExpandPull,
                  isExpense: false,
                  summaries: dashboardState.incomeSummaries,
                  categoryNotifier: categoryNotifier,
                  cycleStartDate: dashboardState.cycleStartDate,
                  cycleEndDate: dashboardState.cycleEndDate,
                  dateRangeLabel: dateRangeLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  final bool isCollapsed;
  final DashboardState dashboardState;
  final DashboardPeriod selectedPeriod;
  final DateTime selectedDate;
  final String dateRangeLabel;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  final VoidCallback onPickPeriod;

  const _DashboardSummaryCard({
    required this.isCollapsed,
    required this.dashboardState,
    required this.selectedPeriod,
    required this.selectedDate,
    required this.dateRangeLabel,
    required this.onPeriodChanged,
    required this.onPickPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final balanceText = FormatUtils.formatNumber(dashboardState.totalBalance);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.all(isCollapsed ? 14 : 24),
        decoration: AppStyles.cardDecoration(context),
        child: ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: isCollapsed
                  ? LayoutBuilder(
                      key: const ValueKey('collapsed_dashboard_summary'),
                      builder: (context, constraints) {
                        final filterWidth = constraints.maxWidth * 0.4;

                        return Row(
                          children: [
                            SizedBox(
                              width: filterWidth,
                              child: _PeriodPickerButton(
                                selectedPeriod: selectedPeriod,
                                selectedDate: selectedDate,
                                onPressed: onPickPeriod,
                                compact: true,
                                showPeriodMode: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      balanceText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: _dashboardPrimaryText(
                                              context,
                                            ),
                                          ),
                                    ),
                                  ),
                                  _BalanceTrend(
                                    changePercentage:
                                        dashboardState.balanceChangePercentage,
                                    period: selectedPeriod,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Column(
                      key: const ValueKey('expanded_dashboard_summary'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: _dashboardPrimaryText(context)),
                        ),
                        Text(
                          dateRangeLabel,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: _dashboardSecondaryText(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _DashboardPeriodControls(
                          selectedPeriod: selectedPeriod,
                          selectedDate: selectedDate,
                          onPeriodChanged: onPeriodChanged,
                          onPickPeriod: onPickPeriod,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            balanceText,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: _dashboardPrimaryText(context),
                                  fontSize: 32,
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _BalanceTrend(
                            changePercentage:
                                dashboardState.balanceChangePercentage,
                            period: selectedPeriod,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.arrowUp,
                                      size: 12,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'รายรับ (Income)',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: _dashboardSecondaryText(context),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            FormatUtils.formatNumber(dashboardState.totalIncome),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.arrowDown,
                                      size: 12,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'รายจ่าย (Expense)',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: _dashboardSecondaryText(context),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            FormatUtils.formatNumber(dashboardState.totalExpense),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.danger,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceTrend extends StatelessWidget {
  final double? changePercentage;
  final DashboardPeriod period;
  final bool compact;

  const _BalanceTrend({
    required this.changePercentage,
    required this.period,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final change = changePercentage;
    final periodLabel = _previousPeriodLabel(period);
    final text = change == null
        ? 'New vs $periodLabel'
        : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs $periodLabel';
    final color = change == null
        ? _dashboardSecondaryText(context)
        : change >= 0
        ? AppColors.success
        : AppColors.danger;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (change != null)
          Icon(
            change >= 0 ? Icons.trending_up : Icons.trending_down,
            size: compact ? 10 : 12,
            color: color,
          ),
        if (change != null) const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: compact ? 11 : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

ButtonStyle _dashboardSegmentedButtonStyle(BuildContext context) {
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;
  final foreground = _dashboardPrimaryText(context);
  final border = _dashboardControlBorder(context);

  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary.withValues(alpha: 0.18);
      }

      return _dashboardControlSurface(context);
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary;
      }

      return foreground;
    }),
    side: WidgetStatePropertyAll(BorderSide(color: border)),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w700),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ButtonStyle _dashboardFilterButtonStyle(
  BuildContext context, {
  bool compact = false,
}) {
  return OutlinedButton.styleFrom(
    backgroundColor: _dashboardControlSurface(context),
    foregroundColor: _dashboardPrimaryText(context),
    side: BorderSide(color: _dashboardControlBorder(context)),
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 10 : 14,
      vertical: compact ? 8 : 12,
    ),
    minimumSize: Size(0, compact ? 40 : 44),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

Color _dashboardControlSurface(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white;
}

Color _dashboardControlBorder(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.22)
      : Colors.black.withValues(alpha: 0.08);
}

Color _dashboardPrimaryText(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? AppColors.textPrimaryOnDark
      : AppColors.textPrimary;
}

Color _dashboardSecondaryText(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? AppColors.textSecondaryOnDark
      : AppColors.textSecondary;
}

class _DashboardPeriodControls extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final DateTime selectedDate;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  final VoidCallback onPickPeriod;

  const _DashboardPeriodControls({
    required this.selectedPeriod,
    required this.selectedDate,
    required this.onPeriodChanged,
    required this.onPickPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<DashboardPeriod>(
          style: _dashboardSegmentedButtonStyle(context),
          segments: DashboardPeriod.values
              .map(
                (period) => ButtonSegment<DashboardPeriod>(
                  value: period,
                  label: Text(period.label),
                ),
              )
              .toList(),
          selected: {selectedPeriod},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onPeriodChanged(selection.first),
        ),
        _PeriodPickerButton(
          selectedPeriod: selectedPeriod,
          selectedDate: selectedDate,
          onPressed: onPickPeriod,
        ),
      ],
    );
  }
}

class _PeriodPickerButton extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final DateTime selectedDate;
  final VoidCallback onPressed;
  final bool compact;
  final bool showPeriodMode;

  const _PeriodPickerButton({
    required this.selectedPeriod,
    required this.selectedDate,
    required this.onPressed,
    this.compact = false,
    this.showPeriodMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _formatPickerLabel(selectedPeriod, selectedDate);

    if (compact) {
      return OutlinedButton(
        onPressed: onPressed,
        style: _dashboardFilterButtonStyle(context, compact: true),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPeriodMode) ...[
              _PeriodModeBadge(period: selectedPeriod),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: _dashboardFilterButtonStyle(context),
      icon: const Icon(Icons.tune, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _PeriodModeBadge extends StatelessWidget {
  final DashboardPeriod period;

  const _PeriodModeBadge({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _periodShortLabel(period),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SummaryTabView extends StatelessWidget {
  final ScrollController scrollController;
  final bool Function(ScrollNotification notification) onPullToExpand;
  final bool isExpense;
  final List<CategorySummary> summaries;
  final CategoryProvider categoryNotifier;
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;
  final String dateRangeLabel;

  const _SummaryTabView({
    required this.scrollController,
    required this.onPullToExpand,
    required this.isExpense,
    required this.summaries,
    required this.categoryNotifier,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.dateRangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            isExpense ? 'No expense data' : 'No income data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _dashboardSecondaryText(context),
            ),
          ),
        ),
      );
    }

    final chartColors = <Color>[
      const Color(0xFF006BA4),
      const Color(0xFFFF800E),
      const Color(0xFFABABAB),
      const Color(0xFF595959),
      const Color(0xFF5F9ED1),
      const Color(0xFFC85200),
      const Color(0xFF898989),
      const Color(0xFFA2C8EC),
      const Color(0xFFFFBC79),
      const Color(0xFFCFCFCF),
    ];

    final chartSemantics = summaries
        .map((summary) {
          final category = categoryNotifier.getCategoryById(summary.categoryId);
          final categoryName = category?.name ?? 'No Category';
          return '$categoryName ${summary.percentage.toStringAsFixed(1)} percent, ${FormatUtils.formatNumber(summary.totalAmount)}';
        })
        .join('. ');

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        onPullToExpand(notification);
        return false;
      },
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 100 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          Semantics(
            container: true,
            label:
                '${isExpense ? 'Expense' : 'Income'} category chart for $dateRangeLabel. $chartSemantics',
            child: _HorizontalCategoryGraph(
              summaries: summaries,
              categoryNotifier: categoryNotifier,
              colors: chartColors,
            ),
          ),
          const SizedBox(height: 16),
          ...summaries.asMap().entries.map((entry) {
            final index = entry.key;
            final summary = entry.value;
            final category = categoryNotifier.getCategoryById(
              summary.categoryId,
            );
            final categoryName = category?.name ?? 'No Category';
            final color = chartColors[index % chartColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _dashboardPrimaryText(context),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${summary.percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _dashboardSecondaryText(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          ...summaries.map((summary) {
            final category = categoryNotifier.getCategoryById(
              summary.categoryId,
            );
            final categoryName = category?.name ?? 'No Category';
            final categoryIcon = category?.icon ?? '';

            return GestureDetector(
              onTap: () {
                context.push(
                  AppRoute.categoryTransactions.path,
                  extra: {
                    'categoryId': summary.categoryId,
                    'categoryName': categoryName,
                    'categoryIcon': categoryIcon,
                    'startDate': cycleStartDate,
                    'endDate': cycleEndDate,
                    'typeId': isExpense ? 1 : 2,
                    'dateRangeLabel': dateRangeLabel,
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardDecoration(context),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (isExpense ? AppColors.danger : AppColors.success)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          categoryIcon,
                          style: const TextStyle(
                            fontFamily: 'NotoEmoji',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _dashboardPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${summary.transactionCount} transactions',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _dashboardSecondaryText(context),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          FormatUtils.formatNumber(summary.totalAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExpense
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                        Text(
                          '${summary.percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _dashboardSecondaryText(context),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HorizontalCategoryGraph extends StatelessWidget {
  final List<CategorySummary> summaries;
  final CategoryProvider categoryNotifier;
  final List<Color> colors;

  const _HorizontalCategoryGraph({
    required this.summaries,
    required this.categoryNotifier,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final segments = summaries.asMap().entries.map((entry) {
      final index = entry.key;
      final summary = entry.value;
      final color = colors[index % colors.length];
      final category = categoryNotifier.getCategoryById(summary.categoryId);

      return _LinearGraphSegment(
        color: color,
        percentage: summary.percentage,
        label: category?.icon ?? '',
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: segments),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _dashboardSecondaryText(context),
              ),
            ),
            Text(
              'Category share',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _dashboardSecondaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '100%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _dashboardSecondaryText(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LinearGraphSegment extends StatelessWidget {
  final Color color;
  final double percentage;
  final String label;

  const _LinearGraphSegment({
    required this.color,
    required this.percentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final flex = (percentage * 100).round().clamp(1, 10000).toInt();
    final showPercent = percentage >= 8;
    final showLabel = percentage >= 14 && label.isNotEmpty;

    return Flexible(
      flex: flex,
      fit: FlexFit.tight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        color: color,
        alignment: Alignment.center,
        child: showPercent
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showLabel) ...[
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'NotoEmoji',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

Future<DateTime?> _showDashboardPeriodPicker(
  BuildContext context, {
  required DashboardPeriod period,
  required DateTime initialDate,
}) {
  final years = List<int>.generate(101, (index) => 2000 + index);
  var selectedMonth = initialDate.month;
  var selectedQuarter = ((initialDate.month - 1) ~/ 3) + 1;
  var selectedYear = initialDate.year.clamp(2000, 2100).toInt();

  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _pickerTitleFor(period),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (period == DashboardPeriod.monthly)
                    DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: const InputDecoration(labelText: 'Month'),
                      items: _monthNames.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key + 1,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedMonth = value);
                        }
                      },
                    ),
                  if (period == DashboardPeriod.quarterly)
                    DropdownButtonFormField<int>(
                      value: selectedQuarter,
                      decoration: const InputDecoration(labelText: 'Quarter'),
                      items: List.generate(4, (index) {
                        final quarter = index + 1;
                        return DropdownMenuItem<int>(
                          value: quarter,
                          child: Text('Q$quarter'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedQuarter = value);
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedYear = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                              _anchorDateForPicker(
                                period,
                                month: selectedMonth,
                                quarter: selectedQuarter,
                                year: selectedYear,
                              ),
                            );
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

DateTime _anchorDateForPicker(
  DashboardPeriod period, {
  required int month,
  required int quarter,
  required int year,
}) {
  switch (period) {
    case DashboardPeriod.monthly:
      return DateTime(year, month, AppConstants.startDayOfMonth);
    case DashboardPeriod.quarterly:
      return DateTime(year, ((quarter - 1) * 3) + 1, 1);
    case DashboardPeriod.yearly:
      return DateTime(year, 1, 1);
  }
}

String _pickerTitleFor(DashboardPeriod period) {
  switch (period) {
    case DashboardPeriod.monthly:
      return 'Select month';
    case DashboardPeriod.quarterly:
      return 'Select quarter';
    case DashboardPeriod.yearly:
      return 'Select year';
  }
}

String _formatDateRange(DateTime startDate, DateTime endDate) {
  final inclusiveEndDate = endDate.subtract(const Duration(days: 1));
  return '${FormatUtils.formatSimpleDate(startDate)} - ${FormatUtils.formatSimpleDate(inclusiveEndDate)}';
}

String _formatPickerLabel(DashboardPeriod period, DateTime selectedDate) {
  switch (period) {
    case DashboardPeriod.monthly:
      return '${_monthNames[selectedDate.month - 1]} ${selectedDate.year}';
    case DashboardPeriod.quarterly:
      final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
      return 'Q$quarter ${selectedDate.year}';
    case DashboardPeriod.yearly:
      return selectedDate.year.toString();
  }
}

String _previousPeriodLabel(DashboardPeriod period) {
  switch (period) {
    case DashboardPeriod.monthly:
      return 'last month';
    case DashboardPeriod.quarterly:
      return 'last quarter';
    case DashboardPeriod.yearly:
      return 'last year';
  }
}

String _periodShortLabel(DashboardPeriod period) {
  switch (period) {
    case DashboardPeriod.monthly:
      return 'M';
    case DashboardPeriod.quarterly:
      return 'Q';
    case DashboardPeriod.yearly:
      return 'Y';
  }
}

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
