import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/viewmodels/saving_goals_provider.dart';
import 'package:kept_aom/views/utils/styles.dart';

class SavingGoalsPage extends ConsumerWidget {
  const SavingGoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingGoalsNotifier = ref.watch(savingGoalsProvider.notifier);
    final savingGoals = ref.watch(savingGoalsProvider).savingGoals;

    String statusText(int statusId) {
      switch (statusId) {
        case 2:
          return 'Completed';
        case 1:
          return 'In Progress';
        default:
          return 'Planning';
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 80,
        leadingWidth: 240,
        leading: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(99),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(99)),
                  ),
                  height: 40,
                  width: 40,
                  child: IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      Icons.arrow_back_rounded,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saving Goals',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: savingGoals.isEmpty
                    ? const Center(
                        child: Text('No saving goals available'),
                      )
                    : ListView.builder(
                        itemCount: savingGoals.length,
                        itemBuilder: (context, index) {
                          final savingGoal = savingGoals[index];
                          return Builder(
                            builder: (tileContext) {
                              return GestureDetector(
                                onLongPress: () async {
                                  final RenderBox overlay = Overlay.of(context)
                                      .context
                                      .findRenderObject() as RenderBox;
                                  final RenderBox tileBox = tileContext
                                      .findRenderObject() as RenderBox;
                                  final Offset tilePosition =
                                      tileBox.localToGlobal(Offset.zero,
                                          ancestor: overlay);

                                  if (savingGoal.userId.isNotEmpty) {
                                    await showMenu(
                                      surfaceTintColor:
                                          Theme.of(context).canvasColor,
                                      color: Theme.of(context).cardColor,
                                      shadowColor: AppColors.netural,
                                      constraints: const BoxConstraints.expand(
                                        width: double.infinity,
                                        height: 128,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        tilePosition.dx + tileBox.size.width,
                                        tilePosition.dy + tileBox.size.height,
                                        tilePosition.dx + tileBox.size.width,
                                        tilePosition.dy,
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            titleAlignment:
                                                ListTileTitleAlignment.center,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            leading: const Icon(
                                              Icons.edit,
                                              color: AppColors.caution,
                                            ),
                                            title: const Text('Edit'),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              16)),
                                                ),
                                                builder: (context) => SafeArea(
                                                  child:
                                                      AddOrEditSavingGoalBottomSheet(
                                                    isEdit: true,
                                                    initialName:
                                                        savingGoal.name,
                                                    initialStored:
                                                        savingGoal.stored,
                                                    initialTarget:
                                                        savingGoal.target,
                                                    onSubmit:
                                                        (name, stored, target) {
                                                      savingGoalsNotifier
                                                          .updateSavingGoals(
                                                        oldName:
                                                            savingGoal.name,
                                                        name: name,
                                                        stored: stored,
                                                        target: target,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        PopupMenuItem(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          value: 'delete',
                                          child: ListTile(
                                            titleAlignment:
                                                ListTileTitleAlignment.center,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            leading: const Icon(
                                              Icons.delete,
                                              color: AppColors.danger,
                                            ),
                                            title: const Text('Delete'),
                                            onTap: () {
                                              savingGoalsNotifier
                                                  .deleteSavingGoals(
                                                      savingGoal.name);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  height: 100,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    title: Text(
                                      savingGoal.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          'Status: ${statusText(savingGoal.statusId)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Stored: ${savingGoal.stored}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Target: ${savingGoal.target}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                    style: ListTileStyle.drawer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    trailing: SizedBox(
                                      width:
                                          40, // กำหนดความกว้างสูงสุดให้ trailing
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${((savingGoal.stored / (savingGoal.target == 0 ? 1 : savingGoal.target)) * 100).toStringAsFixed(1)}%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: savingGoal.target == 0
                                                ? 0
                                                : savingGoal.stored /
                                                    savingGoal.target,
                                            backgroundColor: AppColors.border,
                                            color: AppColors.primary,
                                            minHeight: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('Add Saving Goal'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => SafeArea(
                      child: AddOrEditSavingGoalBottomSheet(
                        isEdit: false,
                        onSubmit: (name, stored, target) {
                          savingGoalsNotifier.addSavingGoals(
                            name: name,
                            target: target,
                            stored: stored,
                          );
                          savingGoalsNotifier.fetchSavingGoals();
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOrEditSavingGoalBottomSheet extends StatefulWidget {
  final void Function(String name, int stored, int target) onSubmit;
  final String? initialName;
  final int? initialStored;
  final int? initialTarget;
  final bool isEdit;

  const AddOrEditSavingGoalBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialStored,
    this.initialTarget,
    this.isEdit = false,
  });

  @override
  _AddOrEditSavingGoalBottomSheetState createState() =>
      _AddOrEditSavingGoalBottomSheetState();
}

class _AddOrEditSavingGoalBottomSheetState
    extends State<AddOrEditSavingGoalBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _storedController;
  late TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _storedController =
        TextEditingController(text: widget.initialStored?.toString() ?? '0');
    _targetController =
        TextEditingController(text: widget.initialTarget?.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storedController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.isEdit ? 'Edit Saving Goal' : 'Add Saving Goal',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.isEdit)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _storedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stored',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            )
          else
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  if (widget.isEdit) {
                    widget.onSubmit(
                      _nameController.text.trim(),
                      int.tryParse(_storedController.text.trim()) ?? 0,
                      int.tryParse(_targetController.text.trim()) ?? 0,
                    );
                  } else {
                    widget.onSubmit(
                      _nameController.text.trim(),
                      0,
                      int.tryParse(_targetController.text.trim()) ?? 0,
                    );
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                }
              },
              child: Text(widget.isEdit ? 'Done' : 'Add',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryOnDark,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
