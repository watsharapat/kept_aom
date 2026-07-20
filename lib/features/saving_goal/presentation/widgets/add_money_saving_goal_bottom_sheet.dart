import 'package:flutter/material.dart';
import 'package:kept_aom/core/theme/styles.dart';

class AddMoneySavingGoalBottomSheet extends StatefulWidget {
  final String goalName;
  final String goalEmoji;
  final Function(int amountToAdd) onSubmit;

  const AddMoneySavingGoalBottomSheet({
    super.key,
    required this.goalName,
    required this.goalEmoji,
    required this.onSubmit,
  });

  @override
  State<AddMoneySavingGoalBottomSheet> createState() =>
      _AddMoneySavingGoalBottomSheetState();
}

class _AddMoneySavingGoalBottomSheetState
    extends State<AddMoneySavingGoalBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to Goal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                height: 60,
                width: 60,
                child: Center(
                  child: Text(
                    widget.goalEmoji,
                    style: const TextStyle(
                      fontFamily: 'NotoEmoji',
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.goalName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount to add',
              prefixIcon: const Icon(Icons.add),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final amount = int.tryParse(_amountController.text.trim()) ?? 0;
                if (amount > 0) {
                  widget.onSubmit(amount);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                }
              },
              child: Text(
                'Add Money',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
