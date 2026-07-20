import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/saving_goal/presentation/viewmodels/saving_goal_viewmodel.dart';
import 'package:kept_aom/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:kept_aom/utils/format_utils.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/features/saving_goal/presentation/widgets/saving_goal_bottom_sheet.dart';

class SavingGoalsPage extends ConsumerWidget {
  const SavingGoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingGoalsAsync = ref.watch(savingGoalViewModelProvider);

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
        title: const Text('Saving Goals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            top: 12,
            right: 20,
            bottom: 16,
          ),
          child: Column(
            children: [
              Expanded(
                child: savingGoalsAsync.when(
                  data: (savingGoals) => savingGoals.isEmpty
                      ? Center(
                          child: Text(
                            'No saving goals available',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPlaceholder,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: savingGoals.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final savingGoal = savingGoals[index];
                            final emoji = savingGoal.name.isNotEmpty ? savingGoal.name.characters.first : "🎯";
                            final name = savingGoal.name.characters.skip(1).toString().trim();
                            final progress = savingGoal.target == 0 ? 0.0 : (savingGoal.stored / savingGoal.target).clamp(0.0, 1.0);

                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => AddOrEditSavingGoalBottomSheet(
                                    isEdit: true,
                                    initialName: savingGoal.name,
                                    initialStored: savingGoal.stored,
                                    initialTarget: savingGoal.target,
                                    onSubmit: (newName, stored, target) {
                                      if (stored != savingGoal.stored) {
                                        final diff = (stored - savingGoal.stored).abs();
                                        final isDeposit = stored > savingGoal.stored;
                                        
                                        String newEmoji = "🎯";
                                        String goalName = newName;
                                        if (newName.isNotEmpty && newName.runes.length > 1) {
                                          newEmoji = newName.characters.first;
                                          goalName = newName.characters.skip(1).toString().trim();
                                        }
                                        
                                        final transaction = TransactionEntity(
                                          id: null,
                                          userId: Supabase.instance.client.auth.currentUser!.id,
                                          date: DateTime.now(),
                                          amount: diff.toDouble(),
                                          paymentType: 0,
                                          typeId: isDeposit ? 1 : 2,
                                          icon: newEmoji,
                                          title: isDeposit ? 'Save to $goalName' : 'Withdraw from $goalName',
                                          categoryId: 0, 
                                          description: 'Auto-generated saving transaction',
                                        );
                                        ref.read(transactionViewModelProvider.notifier).addTransaction(transaction);
                                      }

                                      ref.read(savingGoalViewModelProvider.notifier).updateSavingGoal(
                                        savingGoal.name,
                                        savingGoal,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            emoji,
                                            style: const TextStyle(fontSize: 28, fontFamily: 'NotoEmoji'),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                          onPressed: () {
                                            ref.read(savingGoalViewModelProvider.notifier).deleteSavingGoal(savingGoal.name);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      name,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          FormatUtils.formatNumber(savingGoal.stored.toDouble()),
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          FormatUtils.formatNumber(savingGoal.target.toDouble()),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textPlaceholder,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 12,
                                        backgroundColor: AppColors.border.withValues(alpha: 0.5),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddOrEditSavingGoalBottomSheet(
              isEdit: false,
              onSubmit: (name, stored, target) {
                ref.read(savingGoalViewModelProvider.notifier).addSavingGoal(
                  SavingGoalEntity(
                    userId: Supabase.instance.client.auth.currentUser!.id,
                    name: name,
                    statusId: 0,
                    stored: stored,
                    target: target,
                  ),
                );
              },
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
