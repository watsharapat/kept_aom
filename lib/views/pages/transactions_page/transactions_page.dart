import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/pages/transactions_page/transaction_calendar_view.dart';
import 'package:kept_aom/views/pages/transactions_page/transaction_list_view.dart';
import 'package:kept_aom/views/utils/styles.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/models/transaction_model.dart';
import 'package:table_calendar/table_calendar.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(transactionProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'];
    final firstName = fullName.split(' ')[0];

    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              forceMaterialTransparency: true,
              toolbarHeight: 80,
              leadingWidth: 200,
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
                margin: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                child: Row(
                  children: [
                    // Padding(
                    //     padding: const EdgeInsets.all(4),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //           color: AppColors.primary,
                    //           borderRadius:
                    //               const BorderRadius.all(Radius.circular(99))),
                    //       height: 40,
                    //       width: 40,
                    //       child: Icon(
                    //         color: AppColors.lightBackground,
                    //         Icons.receipt_long_rounded,
                    //         size: 24,
                    //       ),
                    //     )),
                    // // ส่วนแสดงข้อความ
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Transactions',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                Container(
                    height: 60,
                    width: 150,
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
                    margin: const EdgeInsets.only(
                        left: 16, right: 16, top: 4, bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    child: const TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicator: BoxDecoration(),
                      dividerHeight: 0,
                      dividerColor: Colors.transparent,
                      tabs: <Widget>[
                        Tab(
                          icon: Icon(Icons.list),
                          //text: 'List',
                        ),
                        Tab(
                          icon: Icon(Icons.calendar_month_rounded),
                          //text: 'Calendar',
                        ),
                      ],
                    )),
              ],
            ),
            body: const TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [TransactionListView(), TransactionCalendarView()])));
  }
}
