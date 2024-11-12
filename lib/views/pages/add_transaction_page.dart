import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:kept_aom/viewmodels/home_provider.dart';
import 'package:kept_aom/views/widgets/date_picker.dart';
import 'package:kept_aom/views/widgets/toggle_button.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});
  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  String _via = 'Cash';
  DateTime _date = DateTime.now();
  int _typeId = 1;
  String _title = '';
  String _description = '';
  double _amount = 0.0;

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(homeProvider);

    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          forceMaterialTransparency: true,
          toolbarHeight: 80,
          leadingWidth: 250,
          leading: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
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
                          splashColor:
                              Colors.black.withOpacity(0.1), // สีตอนกดค้าง
                          highlightColor:
                              Colors.black.withOpacity(0.1), // สีตอนกดแล้วปล่อย
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
                style: const ButtonStyle(
                    iconColor: WidgetStatePropertyAll(Colors.green),
                    backgroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: () {
                  provider.addTransaction(
                    Transaction(
                      //id: 0,
                      userId: Supabase.instance.client.auth.currentUser!.id,
                      date: _date,
                      amount: _amount,
                      via: _via,
                      typeId: _typeId,
                      title: _title,
                      description: _description,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.done_rounded,
                  weight: 32,
                ),
              ),
            )
          ],
        ),
        body: Container(
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     colors: [Colors.indigo, Colors.indigoAccent],
            //   ),
            // ),
            child: Container(
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
              color: Colors.black12, // สีของเงา
              blurRadius: 10, // ระดับการเบลอของเงา
              offset: Offset(0, 4), // ตำแหน่งของเงา
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(32)),
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
                child: const Text(
                  'via',
                  style: TextStyle(fontSize: 12),
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
                child: const Text(
                  'type',
                  style: TextStyle(fontSize: 12),
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
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.indigo, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            suffixIcon: Icon(Icons.attach_money_rounded),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black26, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                          ),
                          onChanged: (value) {
                            //TO DO move to abs to Function add transaction to avoid using temporary value of _typeId
                            setState(() {
                              try {
                                double doubleValue = double.parse(value);
                                if (_typeId == 1) {
                                  _amount = -(doubleValue.abs());
                                } else {
                                  _amount = doubleValue.abs();
                                }
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
                child: const Text(
                  'title',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Container(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 60,
                        color: Colors.black12,
                        // child: IconPickerWidget(
                        //   onIconPicked: (icon) {
                        //     setState(() {
                        //       _title = icon;
                        //     });
                        //   },
                        // ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 7,
                      child: Container(
                          height: 60,
                          color: Colors.black26,
                          child: TextField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.indigo, width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black26, width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _title = value;
                              });
                            },
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 60,
                        color: Colors.black38,
                        // child: QuickTitleDropdownWidget(
                        //   onTitleSelected: (title) {
                        //     setState(() {
                        //       _title = title;
                        //     });
                        //   },
                        // ),
                      ),
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
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.indigo, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black26, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                        ),
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
        )));
  }
}
