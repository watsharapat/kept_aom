import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/dashboard/presentation/viewmodels/dashboard_provider.dart';
import 'package:kept_aom/utils/format_utils.dart';

class SixMonthCategoryBarChartWidget extends ConsumerStatefulWidget {
  final bool isExpense;
  final List<CategoryEntity> categories;

  const SixMonthCategoryBarChartWidget({
    super.key,
    required this.isExpense,
    required this.categories,
  });

  @override
  ConsumerState<SixMonthCategoryBarChartWidget> createState() =>
      _SixMonthCategoryBarChartWidgetState();
}

class _SixMonthCategoryBarChartWidgetState
    extends ConsumerState<SixMonthCategoryBarChartWidget> {
  int? _selectedCategoryId;
  int _touchedGroupIndex = -1;

  final List<Color> _paletteColors = const [
    Color(0xFF006BA4),
    Color(0xFFFF800E),
    Color(0xFF595959),
    Color(0xFF5F9ED1),
    Color(0xFFC85200),
    Color(0xFF898989),
    Color(0xFFA2C8EC),
    Color(0xFFFFBC79),
    Color(0xFFCFCFCF),
    Color(0xFF2E7D32),
  ];

  CategoryEntity? _getCategory(int id) {
    for (final cat in widget.categories) {
      if (cat.categoryId == id) return cat;
    }
    return null;
  }

  Color _getCategoryColor(int categoryId, List<int> topCategories) {
    final index = topCategories.indexOf(categoryId);
    if (index >= 0) {
      return _paletteColors[index % _paletteColors.length];
    }
    return const Color(0xFFB0BEC5);
  }

  String _formatAxisValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final comparisonData = ref.watch(
      sixMonthCategoryComparisonProvider(widget.isExpense),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryOnDark
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryOnDark
        : AppColors.textSecondary;
    final gridLineColor = Theme.of(context).colorScheme.outline.withAlpha(40);

    final monthlyData = comparisonData.monthlyData;
    final topCatIds = comparisonData.topCategoryIds;

    // Filter categories with transactions in 6 months
    final activeCategories = topCatIds
        .map((id) => _getCategory(id))
        .whereType<CategoryEntity>()
        .toList();

    // Determine max Y value for scaling
    double maxY = 0.0;
    for (final month in monthlyData) {
      if (_selectedCategoryId == null) {
        if (month.totalAmount > maxY) maxY = month.totalAmount;
      } else {
        final amt = month.categoryTotals[_selectedCategoryId] ?? 0.0;
        if (amt > maxY) maxY = amt;
      }
    }
    if (maxY == 0) maxY = 100;
    maxY = maxY * 1.15; // 15% padding top

    final isSingleCategoryMode = _selectedCategoryId != null;
    final selectedCategoryEntity = isSingleCategoryMode
        ? _getCategory(_selectedCategoryId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with Title and Category Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เปรียบเทียบ 6 เดือนย้อนหลัง',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.isExpense ? 'แนวโน้มรายจ่าย' : 'แนวโน้มรายรับ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Category Selector Dropdown / Filter Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withAlpha(60),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedCategoryId,
                  isDense: true,
                  dropdownColor: Theme.of(context).cardColor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('ทุกหมวดหมู่ (รวม)'),
                    ),
                    ...activeCategories.map((cat) {
                      return DropdownMenuItem<int?>(
                        value: cat.categoryId,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cat.icon,
                              style: const TextStyle(
                                fontFamily: 'NotoEmoji',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                      _touchedGroupIndex = -1;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Total 6-Month Summary Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (widget.isExpense ? AppColors.danger : AppColors.success)
                .withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isSingleCategoryMode
                      ? 'ยอดรวม 6 เดือน (${selectedCategoryEntity?.name ?? ''})'
                      : 'ยอดรวม 6 เดือนย้อนหลัง',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FormatUtils.formatNumber(
                  isSingleCategoryMode
                      ? (comparisonData
                              .categoryTotal6Months[_selectedCategoryId] ??
                          0.0)
                      : comparisonData.overallTotal6Months,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isExpense
                      ? AppColors.danger
                      : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

          // Bar Chart Container
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        _touchedGroupIndex = -1;
                        return;
                      }
                      _touchedGroupIndex =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFF1C1C1E),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthSpend = monthlyData[groupIndex];
                      final monthName = monthSpend.monthLabel;

                      if (isSingleCategoryMode) {
                        final catAmt =
                            monthSpend.categoryTotals[_selectedCategoryId] ??
                                0.0;
                        final catName =
                            selectedCategoryEntity?.name ?? 'Category';
                        return BarTooltipItem(
                          '$monthName\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '$catName: ',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            TextSpan(
                              text: FormatUtils.formatNumber(catAmt),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }

                      return BarTooltipItem(
                        '$monthName\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'รวม: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          TextSpan(
                            text: FormatUtils.formatNumber(
                              monthSpend.totalAmount,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == meta.max) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          _formatAxisValue(value),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < monthlyData.length) {
                          final isSelected = index == _touchedGroupIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthlyData[index].monthLabel,
                              style: TextStyle(
                                color: isSelected
                                    ? (widget.isExpense
                                        ? AppColors.danger
                                        : AppColors.success)
                                    : primaryTextColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: gridLineColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: monthlyData.asMap().entries.map((entry) {
                  final groupIndex = entry.key;
                  final monthSpend = entry.value;

                  if (isSingleCategoryMode) {
                    final catAmount =
                        monthSpend.categoryTotals[_selectedCategoryId] ?? 0.0;
                    final catColor = _getCategoryColor(
                      _selectedCategoryId!,
                      topCatIds,
                    );

                    return BarChartGroupData(
                      x: groupIndex,
                      barRods: [
                        BarChartRodData(
                          toY: catAmount,
                          color: catColor,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }

                  // Stacked Bar Mode
                  final Map<int, double> catTotals = monthSpend.categoryTotals;
                  double currentStackHeight = 0.0;
                  final List<BarChartRodStackItem> stackItems = [];

                  // Top categories stack
                  for (final catId in topCatIds) {
                    final amt = catTotals[catId] ?? 0.0;
                    if (amt > 0) {
                      final nextHeight = currentStackHeight + amt;
                      final catColor = _getCategoryColor(catId, topCatIds);
                      stackItems.add(
                        BarChartRodStackItem(
                          currentStackHeight,
                          nextHeight,
                          catColor,
                        ),
                      );
                      currentStackHeight = nextHeight;
                    }
                  }

                  return BarChartGroupData(
                    x: groupIndex,
                    barRods: [
                      BarChartRodData(
                        toY: monthSpend.totalAmount,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        rodStackItems: stackItems,
                        color: stackItems.isEmpty
                            ? Theme.of(context).colorScheme.outline.withAlpha(40)
                            : null,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Legend / Breakdown Section
          if (!isSingleCategoryMode && activeCategories.isNotEmpty) ...[
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).colorScheme.outline.withAlpha(40),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: activeCategories.take(5).map((cat) {
                final color = _getCategoryColor(cat.categoryId, topCatIds);
                final total6m =
                    comparisonData.categoryTotal6Months[cat.categoryId] ?? 0.0;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${FormatUtils.formatNumber(total6m)})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: primaryTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      );
    }
  }
