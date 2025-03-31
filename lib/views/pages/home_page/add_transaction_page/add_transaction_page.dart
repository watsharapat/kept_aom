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
  Widget build(BuildContext context) {
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
                    onPressed: () {
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
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.success),
                        foregroundColor:
                            WidgetStateProperty.all(AppColors.lightSurface),
                      ),
                  onPressed: () {
                    provider.addTransaction(
                      Transaction(
                        userId: Supabase.instance.client.auth.currentUser!.id,
                        date: _date,
                        amount: _amount,
                        via: _via,
                        typeId: _typeId,
                        title: "$_emoji $_title",
                        description: _description,
                      ),
                    );

                    context.pop();
                  },
                  icon: const Icon(Icons.done_rounded),
                ),
              ),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              // boxShadow: const [
              //   BoxShadow(
              //     color: Colors.black12, // สีของเงา
              //     blurRadius: 10, // ระดับการเบลอของเงา
              //     offset: Offset(0, 4), // ตำแหน่งของเงา
              //   ),
              // ],
              //color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(32)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'via',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 60,
                      width: 120,
                      child: CustomToggleButton(
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
                  ),
                  Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 60,
                        child: DatepickerWidget(
                          onDateChange: (dateTime) {
                            setState(() {
                              _date = dateTime;
                            });
                          },
                        ),
                      ))
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'type',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 60,
                      width: 120,
                      child: CustomToggleButton(
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
                  ),
                  Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border:
                                  Theme.of(context).inputDecorationTheme.border,
                              focusedBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder),
                          onChanged: (value) {
                            //TO DO move to abs to Function add transaction to avoid using temporary value of _typeId
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
                      ))
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'title',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Container(
                height: 60,
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      //color: Colors.black12,
                      child: EmojiPickerButton(
                          selectedEmoji: _emoji,
                          onEmojiSelected: (String value) {
                            _emoji = value;
                            debugPrint(_title);
                          }),
                    ),
                    const SizedBox(width: 16),
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
                              border: Theme.of(context)
                                  .inputDecorationTheme
                                  .border),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 60,
                      width: 40,
                      child: QuickTitleButton(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'note',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                  height: 60,
                  child: Expanded(
                    flex: 2,
                    child: Container(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            focusedBorder: Theme.of(context)
                                .inputDecorationTheme
                                .focusedBorder,
                            border:
                                Theme.of(context).inputDecorationTheme.border),
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}
