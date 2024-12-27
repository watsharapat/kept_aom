import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/quick_title_provider.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/date_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/emoji_picker.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/quick_title_button.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/toggle_button.dart';
import 'package:kept_aom/views/pages/login_page.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                          splashColor: Colors.black
                              .withValues(alpha: 0.1), // สีตอนกดค้าง
                          highlightColor: Colors.black
                              .withValues(alpha: 0.1), // สีตอนกดแล้วปล่อย
                          onTap: () {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 24,
                            ),
                          )),
                    )),
                // ส่วนแสดงข้อความ
                const SizedBox(width: 8),
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
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, // สีของเงา
                    blurRadius: 10, // ระดับการเบลอของเงา
                    offset: Offset(0, 4), // ตำแหน่งของเงา
                  ),
                ],
              ),
              margin: const EdgeInsets.only(
                  left: 16, right: 16, top: 4, bottom: 16),
              child: IconButton.filledTonal(
                style: Theme.of(context).iconButtonTheme.style,
                //TO DO ดักการใส่ข้อมูลเปล่า
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
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.done_rounded,
                  weight: 128,
                  color: Colors.green,
                ),
              ),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12, // สีของเงา
                  blurRadius: 10, // ระดับการเบลอของเงา
                  offset: Offset(0, 4), // ตำแหน่งของเงา
                ),
              ],
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(32)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
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
                        colors: const [Color(0xff4A73FA)],
                        onSelectionChanged: (int value) {
                          setState(() {
                            _via = value == 0 ? 'Cash' : 'Credit Card';
                          });
                        },
                        icons: const [
                          Icon(Icons.attach_money),
                          Icon(Icons.credit_card_rounded)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 60,
                        child: DatepickerWidget(
                          onDateChange: (DateTime) {
                            setState(() {
                              _date = DateTime;
                            });
                          },
                        ),
                      ))
                ],
              ),
              SizedBox(height: 12),
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
                        colors: const [Color(0xff4A73FA)],
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
                              focusedBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder,
                              border: Theme.of(context)
                                  .inputDecorationTheme
                                  .border),
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
