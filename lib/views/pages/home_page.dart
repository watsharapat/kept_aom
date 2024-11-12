import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/viewmodels/home_provider.dart';
import 'package:kept_aom/views/pages/add_transaction_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/widgets/bottom_nav.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(homeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    final firstName = fullName.split(' ')[0];

    return Scaffold(
      extendBodyBehindAppBar: false,
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0,
      ),
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
                  padding: EdgeInsets.all(4),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.black.withOpacity(0.1), // สีตอนกดค้าง
                      highlightColor:
                          Colors.black.withOpacity(0.1), // สีตอนกดแล้วปล่อย
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
                              child: Ink.image(
                              image: NetworkImage(profileImageUrl),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ))
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
                  style: const TextStyle(
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
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: IconButton.filledTonal(
              onPressed: () {
                provider.fetchTransactions();
              },
              icon: const Icon(Icons.replay_outlined),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
