import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/quick_title_provider.dart';
import 'package:kept_aom/viewmodels/theme_provider.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/date_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/emoji_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/quick_title_button.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/toggle_button.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditTransactionPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const EditTransactionPage({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<EditTransactionPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
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
    _paymentType = widget.transaction.paymentType;
    _date = widget.transaction.date;
    _typeId = widget.transaction.typeId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeMode = ref.watch(themeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(transactionProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 80,
        leadingWidth: 250,
        leading: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: AppColors.netural.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  style: Theme.of(context).iconButtonTheme.style?.copyWith(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.danger),
                        foregroundColor:
                            WidgetStateProperty.all(AppColors.lightSurface),
                      ),
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Edit transaction',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        actions: [
          Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(12),
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
            margin: const EdgeInsets.only(right: 16, top: 4, bottom: 16),
            child: Container(
              width: 36,
              height: 36,
              child: IconButton(
                style: Theme.of(context).iconButtonTheme.style?.copyWith(
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.success),
                      foregroundColor:
                          WidgetStateProperty.all(AppColors.lightSurface),
                    ),
                onPressed: () {
                  setState(() {
                    _amountInvalid = _amount <= 0;
                    _titleInvalid = _title.isEmpty;
                  });

                  if (!_amountInvalid && !_titleInvalid) {
                    final updatedTransaction = Transaction(
                      id: widget.transaction.id,
                      userId: widget.transaction.userId,
                      date: _date,
                      amount: _amount,
                      paymentType: widget.transaction.paymentType,
                      typeId: _typeId,
                      icon: widget.transaction.icon,
                      title: "$_emoji $_title",
                      categoryId: widget.transaction.categoryId,
                      description: _description,
                    );
                    provider.updateTransaction(updatedTransaction);
                    context.pop();
                  }
                },
                icon: const Icon(Icons.done_rounded),
              ),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: themeMode == ThemeMode.light
                      ? [
                          BoxShadow(
                            color: AppColors.netural.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : []),
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
            const SizedBox(height: 24),
            Container(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: themeMode == ThemeMode.light
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.netural.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : []),
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
                              Icon(Icons.credit_card_rounded, size: 24)
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
                              Icon(Icons.file_download_outlined)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 120,
                    width: 240,
                    child: Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: TextField(
                        maxLines: 1,
                        minLines: 1,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: _amount == 0 ? '' : _amount.toString()),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(
                            fontSize: 0,
                          ),
                          errorText: _amountInvalid ? '' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.danger, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.danger, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          enabledBorder: Theme.of(context)
                              .inputDecorationTheme
                              .enabledBorder,
                          border: Theme.of(context).inputDecorationTheme.border,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 8),
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: themeMode == ThemeMode.light
                      ? [
                          BoxShadow(
                            color: AppColors.netural.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : []),
              padding:
                  const EdgeInsets.only(left: 12, bottom: 4, top: 4, right: 8),
              height: 80,
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    child: EmojiPickerButton(
                        selectedEmoji: _emoji,
                        onEmojiSelected: (String value) {
                          setState(() {
                            _emoji = value;
                          });
                        }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 60,
                      child: TextField(
                        controller: _titleController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(
                            fontSize: 0,
                          ),
                          errorText: _titleInvalid ? '' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.danger, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.danger, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          enabledBorder: Theme.of(context)
                              .inputDecorationTheme
                              .enabledBorder,
                          border: Theme.of(context).inputDecorationTheme.border,
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
                        final title = selectedTitle.title;
                        String emojiFromTitle = title.split(' ')[0];
                        String titleWithoutEmoji =
                            title.split(' ').sublist(1).join(' ');
                        setState(() {
                          _titleController.text = titleWithoutEmoji;
                          _title = titleWithoutEmoji;
                          _emoji = emojiFromTitle;
                          _typeId = selectedTitle.typeId;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              height: 84,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: themeMode == ThemeMode.light
                      ? [
                          BoxShadow(
                            color: AppColors.netural.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : []),
              child: TextField(
                controller: _descriptionController,
                expands: true,
                minLines: null,
                maxLines: null,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    focusedBorder:
                        Theme.of(context).inputDecorationTheme.focusedBorder,
                    border: Theme.of(context).inputDecorationTheme.border),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
