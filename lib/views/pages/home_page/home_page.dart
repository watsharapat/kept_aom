import 'package:decimal/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept_aom/viewmodels/theme_provider.dart';
import 'package:kept_aom/viewmodels/transaction_provider.dart';
import 'package:kept_aom/views/pages/home_page/add_transaction_page/add_transaction_page.dart';
import 'package:kept_aom/views/pages/home_page/today_transaction.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase/supabase.dart';
import 'package:decimal/decimal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(transactionProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    final firstName = fullName.split(' ')[0];

    final balance = provider.transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 80,
        leadingWidth: 280,
        leading: Container(
          height: 60,
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
          margin:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Row(
            children: [
              // แยกส่วนปุ่มรูปโปรไฟล์
              Padding(
                  padding: const EdgeInsets.all(4),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor:
                          Colors.black.withValues(alpha: 0.1), // สีตอนกดค้าง
                      highlightColor: Colors.black.withValues(alpha: 0.1),
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        }
                      },
                      child: (profileImageUrl != null)
                          ? ClipOval(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.network(
                                  profileImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.account_circle,
                              size: 40,
                            ),
                    ),
                  )),
              // ส่วนแสดงข้อความ
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hey! $firstName',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              )
            ],
          ),
        ),
        actions: [
          Center(
            child: Container(
              height: 50,
              width: 50,
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
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              child: Center(
                child: IconButton.filledTonal(
                  onPressed: () {
                    provider.fetchTransactions();
                  },
                  icon: const Icon(Icons.replay_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          accountCard(balance),
          const Expanded(child: TodayTransactions())
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        //shape: const CircleBorder(),
        isExtended: true,
        onPressed: () {
          context.push('/addTransaction');
        },
        label: Text(
          'Add Transaction',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
        ),
        icon: const Icon(Icons.add, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget accountCard(double balance) {
    String balanceString = NumberFormat("#,##0.00").format(balance.toDouble());
    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.bottomRight,
          radius: 3,
          colors: [
            Color(0xFF3F51B5),
            Colors.black87,
          ],
        ),

        //color: Colors.indigo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Current Account',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  balanceString,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
