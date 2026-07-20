import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/transaction/presentation/views/transactions_page/transaction_list_view.dart';
import 'package:kept_aom/core/theme/styles.dart';

class CategoryTransactionsPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? typeId;
  final String? dateRangeLabel;

  const CategoryTransactionsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.startDate,
    this.endDate,
    this.typeId,
    this.dateRangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categoryIcon,
                style: const TextStyle(fontFamily: 'NotoEmoji', fontSize: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(categoryName, overflow: TextOverflow.ellipsis),
                  if (dateRangeLabel != null)
                    Text(
                      dateRangeLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TransactionListView(
            filterCategoryId: categoryId,
            filterStartDate: startDate,
            filterEndDate: endDate,
            filterTypeId: typeId,
          ),
        ),
      ),
    );
  }
}
