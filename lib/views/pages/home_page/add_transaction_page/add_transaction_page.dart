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
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});
  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final TextEditingController _titleController = TextEditingController();
  late ThemeMode themeMode;
  String _via = 'Cash';
  DateTime _date = DateTime.now();
  int _typeId = 1;
  String _title = '';
  String _description = '';
  double _amount = 0.0;
  String _emoji = "😊"; // อีโมจิเริ่มต้น

  @override
  void initState() {
    super.initState();
    // เพิ่ม Listener เพื่อตรวจจับการเปลี่ยนแปลงของข้อความ
    // ref.watch(themeProvider);
    _titleController.addListener(() {
      setState(() {
        _title = _titleController.text;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeMode = ref.watch(themeProvider); // ย้ายมาที่นี่
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _amount > 0 && _title.isNotEmpty && _date != null;
    final provider = ref.watch(transactionProvider);
    //final theme = ref.watch(themeProvider);

    return Scaffold(
      //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  onPressed: _amount > 0 ||
                          _title.isNotEmpty ||
                          _description.isNotEmpty
                      ? () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                titleTextStyle: TextTheme.of(context)
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                contentTextStyle:
                                    TextTheme.of(context).bodyMedium,
                                backgroundColor: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text('Unsaved transaction'),
                                content: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: const Text(
                                      'Are you sure you want to discard this transaction?'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        )),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context.pop();
                                    },
                                    child: const Text('Discard',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                        )),
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
              ),
              // ส่วนแสดงข้อความ
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Add transaction',
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
                  color: Colors.black12, // สีของเงา
                  blurRadius: 10, // ระดับการเบลอของเงา
                  offset: Offset(0, 4), // ตำแหน่งของเงา
                ),
              ],
            ),
            margin: const EdgeInsets.only(right: 16, top: 4, bottom: 16),
            child: Container(
              width: 36,
              height: 36,
              child: IconButton(
                style: Theme.of(context).iconButtonTheme.style?.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        isFormValid
                            ? AppColors.success
                            : AppColors.disabledWidget,
                      ),
                      foregroundColor:
                          WidgetStateProperty.all(AppColors.lightSurface),
                    ),
                onPressed: isFormValid
                    ? () {
                        provider.addTransaction(
                          Transaction(
                            userId:
                                Supabase.instance.client.auth.currentUser!.id,
                            date: _date,
                            amount: _amount,
                            via: _via,
                            typeId: _typeId,
                            title: "$_emoji $_title",
                            description: _description,
                          ),
                        );
                        context.pop();
                        provider.fetchTransactions();
                      }
                    : null,
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
          //mainAxisSize: MainAxisSize.min,
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
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          // height: 48,
                          // width: 100,
                          child: CustomToggleButton(
                            selectedIndex: _via == "Cash" ? 0 : 1,
                            colors: [Theme.of(context).primaryColor],
                            onSelectionChanged: (int value) {
                              setState(() {
                                _via = value == 0 ? 'Cash' : 'Credit Card';
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
                          // height: 48,
                          // width: 100,
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
                        //),
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
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        decoration: InputDecoration(
                          labelStyle:
                              Theme.of(context).inputDecorationTheme.labelStyle,
                          border: Theme.of(context).inputDecorationTheme.border,
                          focusedBorder: Theme.of(context)
                              .inputDecorationTheme
                              .focusedBorder,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 8), // Adjust padding
                        ),
                        onChanged: (value) {
                          setState(() {
                            try {
                              double doubleValue = double.parse(value);
                              _amount = doubleValue;
                            } catch (e) {
                              debugPrint("Invalid input: $value");
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
                          _emoji = value;
                          debugPrint(_title);
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
                            focusedBorder: Theme.of(context)
                                .inputDecorationTheme
                                .focusedBorder,
                            border:
                                Theme.of(context).inputDecorationTheme.border),
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
