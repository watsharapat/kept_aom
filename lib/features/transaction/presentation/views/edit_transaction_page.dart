import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:kept_aom/core/theme/theme_provider.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/date_picker.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/emoji_picker.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/quick_title_button.dart';
import 'package:kept_aom/core/widgets/custom_toggle_button.dart';
import 'package:kept_aom/core/theme/styles.dart';

class EditTransactionPage extends ConsumerStatefulWidget {
  final TransactionEntity transaction;
  const EditTransactionPage({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<EditTransactionPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late ThemeMode themeMode;
  bool _amountInvalid = false;
  bool _titleInvalid = false;
  late int _paymentType;
  late int _categoryId;
  late DateTime _date;
  late int _typeId;
  late String _title;
  late String _description;
  late double _amount;
  late String _emoji;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emoji = widget.transaction.icon;
    _title = widget.transaction.title;
    _categoryId = widget.transaction.categoryId;
    _titleController = TextEditingController(text: _title);
    _description = widget.transaction.description;
    _descriptionController = TextEditingController(text: _description);
    _amount = widget.transaction.amount.abs();
    _amountController = TextEditingController(
      text: _amount == 0
          ? ''
          : _amount.toStringAsFixed(2).replaceAll('.00', ''),
    );
    _paymentType = widget.transaction.paymentType;
    _date = widget.transaction.date;
    _typeId = widget.transaction.typeId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeMode = ref.watch(themeViewModelProvider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(transactionViewModelProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Edit transaction'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filled(
              tooltip: 'Save transaction',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _amountInvalid = _amount <= 0;
                        _titleInvalid = _title.isEmpty;
                      });

                      if (!_amountInvalid && !_titleInvalid) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          final updatedTransaction = TransactionEntity(
                            id: widget.transaction.id,
                            userId: widget.transaction.userId,
                            date: _date,
                            amount: _amount,
                            paymentType: _paymentType,
                            typeId: _typeId,
                            icon: _emoji,
                            title: _title,
                            categoryId: _categoryId,
                            description: _description,
                          );
                          await provider.updateTransaction(updatedTransaction);
                          if (mounted) {
                            context.pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update transaction: $e',
                                ),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      }
                    },
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.done_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                height: 60,
                child: DatepickerWidget(
                  initialDate: _date,
                  onDateChange: (dateTime) {
                    setState(() {
                      final original = widget.transaction.date;
                      _date = DateTime(
                        dateTime.year,
                        dateTime.month,
                        dateTime.day,
                        original.hour,
                        original.minute,
                        original.second,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: CustomToggleButton(
                              selectedIndex: _paymentType - 1,
                              colors: [Theme.of(context).primaryColor],
                              onSelectionChanged: (int value) {
                                setState(() {
                                  _paymentType = value + 1;
                                });
                              },
                              icons: const [
                                FaIcon(FontAwesomeIcons.moneyBill, size: 16),
                                Icon(Icons.credit_card_rounded, size: 24),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: CustomToggleButton(
                              selectedIndex: _typeId == 1 ? 0 : 1,
                              colors: [Theme.of(context).primaryColor],
                              onSelectionChanged: (int value) {
                                setState(() {
                                  _typeId = value == 0 ? 1 : 2;
                                });
                              },
                              icons: const [
                                Icon(Icons.file_upload_outlined),
                                Icon(Icons.file_download_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: _amountInvalid
                              ? Border.all(color: AppColors.danger, width: 2)
                              : null,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          maxLines: 1,
                          minLines: 1,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          controller: _amountController,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            setState(() {
                              try {
                                double doubleValue = double.parse(value);
                                _amount = doubleValue;
                                _amountInvalid = false;
                              } catch (e) {
                                _amount = 0.0;
                                _amountInvalid = true;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: _titleInvalid
                      ? Border.all(color: AppColors.danger, width: 2)
                      : null,
                ),
                padding: const EdgeInsets.only(
                  left: 12,
                  bottom: 4,
                  top: 4,
                  right: 8,
                ),
                height: 80,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      height: 48,
                      width: 48,
                      child: EmojiPickerButton(
                        selectedEmoji: _emoji,
                        onEmojiSelected: (String value) {
                          setState(() {
                            _emoji = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 60,
                        child: TextField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _title = value;
                              _titleInvalid = false;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 60,
                      width: 40,
                      child: QuickTitleButton(
                        onTitleSelected: (selectedTitle) {
                          setState(() {
                            _titleController.text = selectedTitle.title;
                            _title = selectedTitle.title;
                            _emoji = selectedTitle.icon;
                            _typeId = selectedTitle.typeId;
                            _categoryId =
                                selectedTitle.categoryId ?? _categoryId;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add notes or description (optional)',
                  hintStyle: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textPlaceholder),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, child) {
                  final categories = ref.watch(categoriesByTypeProvider(_typeId));

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ChoiceChip(
                                label: const Text('No Category'),
                                selected: _categoryId == 0,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _categoryId = 0;
                                    });
                                  }
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: _categoryId == 0
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  fontWeight: _categoryId == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              ...categories.map((category) {
                                final isSelected =
                                    _categoryId == category.categoryId;

                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        category.icon,
                                        style: const TextStyle(
                                          fontFamily: 'NotoEmoji',
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(category.name),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _categoryId = category.categoryId;
                                      });
                                    }
                                  },
                                  selectedColor: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
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
