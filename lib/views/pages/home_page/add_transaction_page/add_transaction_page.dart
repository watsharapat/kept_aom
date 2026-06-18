import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/models/merchant_model.dart';
import 'package:kept_aom/services/ocr_service.dart';
import 'package:kept_aom/viewmodels/merchant_provider.dart';
import 'package:kept_aom/viewmodels/category_provider.dart';
import 'package:kept_aom/viewmodels/theme_provider.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/date_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/emoji_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/quick_title_button.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/toggle_button.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:supabase/supabase.dart';
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
  String _emoji = "ðŸ˜Š"; // à¸­à¸µà¹‚à¸¡à¸ˆà¸´à¹€à¸£à¸´à¹ˆà¸¡à¸•à¹‰à¸™
  bool _isLoading = false;

  // Track OCR merchant mapping
  Merchant? _foundMerchant;
  String? _scannedReceiverName;

  @override
  void initState() {
    super.initState();
    // à¹€à¸žà¸´à¹ˆà¸¡ Listener à¹€à¸žà¸·à¹ˆà¸­à¸•à¸£à¸§à¸ˆà¸ˆà¸±à¸šà¸à¸²à¸£à¹€à¸›à¸¥à¸µà¹ˆà¸¢à¸™à¹à¸›à¸¥à¸‡à¸‚à¸­à¸‡à¸‚à¹‰à¸­à¸„à¸§à¸²à¸¡
    // ref.watch(themeProvider);

    _titleController.addListener(() {
      setState(() {
        _title = _titleController.text;
      });
    });

    // Check if we should auto-trigger scan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      if (state.uri.queryParameters['scan'] == 'true') {
        _scanSlip();
      }
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
    themeMode = ref.watch(
      themeProvider,
    ); // à¸¢à¹‰à¸²à¸¢à¸¡à¸²à¸—à¸µà¹ˆà¸™à¸µà¹ˆ
  }

  Future<void> _scanSlip() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final ocrResult = await OcrService.analyzeSlip(base64Image);

      if (ocrResult != null) {
        // Reset mapping state
        _foundMerchant = null;
        _scannedReceiverName = null;

        if (ocrResult.amount != null) {
          setState(() {
            _amount = ocrResult.amount!;
            _amountController.text = _amount
                .toStringAsFixed(2)
                .replaceAll('.00', '');
            _amountInvalid = false;
          });
        }

        if (ocrResult.receiverName != null) {
          _scannedReceiverName = ocrResult.receiverName;

          // Use merchant provider to see if we know this receiver
          final merchantNotifier = ref.read(merchantProvider);
          final merchant = await merchantNotifier.findMerchantByNormalizedName(
            ocrResult.receiverName!,
          );

          setState(() {
            if (merchant != null) {
              // Known merchant! Auto-fill everything
              _foundMerchant = merchant;
              _titleController.text = merchant.titleName;
              _title = merchant.titleName;
              _emoji = merchant.titleIcon;
              _categoryId = merchant.categoryId;
            } else {
              // Unknown merchant. Use receiver name as default title
              _titleController.text = ocrResult.receiverName!;
              _title = ocrResult.receiverName!;
            }
            _paymentType =
                1; // Default to bank transfer (index 0 is cash, 1 is card/transfer)
            _typeId = 1; // Default to expense
            _titleInvalid = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  merchant != null
                      ? 'Match found: \${merchant.name}'
                      : 'Slip scanned. Please categorize.',
                ),
                backgroundColor: merchant != null
                    ? AppColors.success
                    : AppColors.primary,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read slip data.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Slip scanning error: \$e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(transactionProvider);
    //final theme = ref.watch(themeProvider);

    return Scaffold(
      //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          if (_scannedReceiverName != null &&
                              _foundMerchant == null) {
                            final newMerchant = Merchant(
                              name: _scannedReceiverName!,
                              titleName: _title,
                              titleIcon: _emoji,
                              categoryId: _categoryId,
                            );
                            final merchantNotifier = ref.read(merchantProvider);
                            _foundMerchant = await merchantNotifier
                                .createMerchant(newMerchant);
                            debugPrint(
                              "Learned new merchant: \${_foundMerchant?.name}",
                            );
                          }

                          await provider.addTransaction(
                            Transaction(
                              id: null,
                              userId: userId!,
                              date: _date,
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
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                    boxShadow: themeMode == ThemeMode.light
                        ? [
                            BoxShadow(
                              color: AppColors.netural.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  height: 60,
                  child: DatepickerWidget(
                    onDateChange: (dateTime) {
                      setState(() {
                        _date = dateTime;
                      });
                    },
                  ),
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
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                          boxShadow: themeMode == ThemeMode.light
                              ? [
                                  BoxShadow(
                                    color: AppColors.netural.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomToggleButton(
                              selectedIndex: _paymentType + 1,
                              colors: [Theme.of(context).primaryColor],
                              onSelectionChanged: (int value) {
                                setState(() {
                                  _paymentType = value - 1;
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
                            border: Border.all(
                              color: _amountInvalid
                                  ? AppColors.danger
                                  : Theme.of(context).colorScheme.outline,
                              width: _amountInvalid ? 2 : 1,
                            ),
                            boxShadow: themeMode == ThemeMode.light
                                ? [
                                    BoxShadow(
                                      color: AppColors.netural.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
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
                    border: Border.all(
                      color: _titleInvalid
                          ? AppColors.danger
                          : Theme.of(context).colorScheme.outline,
                      width: _titleInvalid ? 2 : 1,
                    ),
                    boxShadow: themeMode == ThemeMode.light
                        ? [
                            BoxShadow(
                              color: AppColors.netural.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        child: EmojiPickerButton(
                          selectedEmoji: _emoji,
                          onEmojiSelected: (String value) {
                            _emoji = value;
                            debugPrint(_title);
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
                    final categoryNotifier = ref.watch(categoryProvider);
                    final categories = categoryNotifier.getCategoriesByType(
                      _typeId,
                    );

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                        boxShadow: themeMode == ThemeMode.light
                            ? [
                                BoxShadow(
                                  color: AppColors.netural.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('No Category'),
                                  selected: _categoryId == null,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _categoryId = null;
                                      });
                                    }
                                  },
                                  selectedColor: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: _categoryId == null
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                    fontWeight: _categoryId == null
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
                                            fontSize: 14,
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
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                    boxShadow: themeMode == ThemeMode.light
                        ? [
                            BoxShadow(
                              color: AppColors.netural.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
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
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 0.5,
                        ),
                      ),
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
                ),
                // Add some bottom padding so it can scroll fully above keyboard
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
