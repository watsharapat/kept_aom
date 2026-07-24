import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kept_aom/features/category/domain/entities/category_entity.dart';
import 'package:kept_aom/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:kept_aom/core/theme/theme_provider.dart';
import 'package:kept_aom/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/date_picker.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/emoji_picker.dart';
import 'package:kept_aom/features/transaction/presentation/views/add_transaction_page/quick_title_button.dart';
import 'package:kept_aom/core/widgets/custom_toggle_button.dart';
import 'package:kept_aom/core/theme/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late ThemeMode themeMode;
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _amountInvalid = false;
  bool _titleInvalid = false;
  int _paymentType = 1;
  int? _categoryId;
  DateTime _date = DateTime.now();
  int _typeId = 1;
  String _title = '';
  String _description = '';
  double _amount = 0.0;
  String _emoji = "😊";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {
        _title = _titleController.text;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: const AppBarGradientBackground(),
        leading: IconButton(
          tooltip: 'Close',
          onPressed: _amount > 0 || _title.isNotEmpty || _description.isNotEmpty
              ? () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titleTextStyle: TextTheme.of(
                          context,
                        ).bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        contentTextStyle: TextTheme.of(context).bodyMedium,
                        backgroundColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Unsaved transaction'),
                        content: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Are you sure you want to discard this transaction?',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.pop();
                            },
                            child: const Text(
                              'Discard',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              : () {
                  context.pop();
                },
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Add transaction'),
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
                      final userId = _supabase.auth.currentUser?.id;
                      setState(() {
                        _amountInvalid = _amount <= 0;
                        _titleInvalid = _title.isEmpty;
                      });

                      if (!_amountInvalid && !_titleInvalid) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {

                          final now = DateTime.now();
                          final dateToSave = DateTime(
                            _date.year,
                            _date.month,
                            _date.day,
                            now.hour,
                            now.minute,
                            now.second,
                          );

                          await ref.read(transactionViewModelProvider.notifier).addTransaction(
                            TransactionEntity(
                              id: null,
                              userId: userId!,
                              date: dateToSave,
                              amount: _amount,
                              typeId: _typeId,
                              title: _title,
                              description: _description,
                              paymentType: _paymentType,
                              icon: _emoji,
                              categoryId: _categoryId ?? 0,
                            ),
                          );
                          if (mounted) {
                            context.pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add transaction: $e'),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 60,
                        child: DatepickerWidget(
                          initialDate: _date,
                          onDateChange: (dateTime) {
                            setState(() {
                              _date = dateTime;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: Text(
                          '-1D',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        tooltip: '1 Day Ago',
                        onPressed: () {
                          setState(() {
                            _date = _date.subtract(const Duration(days: 1));
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomToggleButton(
                              selectedIndex: _paymentType - 1,
                              colors: [Theme.of(context).primaryColor],
                              onSelectionChanged: (int value) {
                                setState(() {
                                  _paymentType = value + 1;
                                });
                              },
                              icons: const [
                                FaIcon(FontAwesomeIcons.moneyBill, size: 16),
                                FaIcon(FontAwesomeIcons.creditCard, size: 16),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CustomToggleButton(
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
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
                            controller: _amountController,
                            maxLines: 1,
                            minLines: 1,
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
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
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: _titleInvalid
                        ? Border.all(color: AppColors.danger, width: 2)
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Transaction Title',
                            hintStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textPlaceholder),
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
                      const SizedBox(width: 8),
                      Container(
                        height: 48,
                        width: 40,
                        child: QuickTitleButton(
                          onTitleSelected: (selectedTitle) {
                            setState(() {
                              _titleController.text = selectedTitle.title;
                              _title = selectedTitle.title;
                              _emoji = selectedTitle.icon;
                              _typeId = selectedTitle.typeId;
                              _categoryId = selectedTitle.categoryId;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final categories = ref.watch(categoriesByTypeProvider(_typeId));

                    CategoryEntity? selectedCategory;
                    if (_categoryId != null && _categoryId != 0) {
                      for (final cat in categories) {
                        if (cat.categoryId == _categoryId) {
                          selectedCategory = cat;
                          break;
                        }
                      }
                    }

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (selectedCategory != null)
                                Text(
                                  '${selectedCategory.icon} ${selectedCategory.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                )
                              else
                                Text(
                                  'No Category',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              Tooltip(
                                message: 'No Category',
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _categoryId = null;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 46,
                                    height: 46,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _categoryId == null || _categoryId == 0
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.15)
                                          : Theme.of(context)
                                              .colorScheme
                                              .surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _categoryId == null || _categoryId == 0
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.3),
                                        width: _categoryId == null || _categoryId == 0 ? 2 : 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.block_rounded,
                                      size: 20,
                                      color: _categoryId == null || _categoryId == 0
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                    ),
                                  ),
                                ),
                              ),
                              ...categories.map((category) {
                                final isSelected =
                                    _categoryId == category.categoryId;

                                return Tooltip(
                                  message: category.name,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _categoryId = category.categoryId;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 46,
                                      height: 46,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.15)
                                            : Theme.of(context)
                                                .colorScheme
                                                .surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withValues(alpha: 0.3),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        category.icon,
                                        style: const TextStyle(
                                          fontFamily: 'NotoEmoji',
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
