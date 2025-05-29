import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept_aom/viewmodels/theme_provider.dart';
import 'package:kept_aom/views/pages/quick_titles_page.dart';
import 'package:kept_aom/views/utils/styles.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 80,
        leadingWidth: 160,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
              //         Icons.settings,
              //         size: 24,
              //       ),
              //     )),
              // ส่วนแสดงข้อความ
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(8),
                  iconSize: 80,
                  color: AppColors.caution,
                  icon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.dark_mode),
                      const SizedBox(height: 8),
                      Text(
                          themeMode == ThemeMode.light
                              ? 'Light mode'
                              : 'Dark mode',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () {
                    themeNotifier.toggleTheme();
                  },
                ),
              ),

              // Quick Title Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(8),
                  iconSize: 80,
                  color: AppColors.primary,
                  icon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language_rounded),
                      const SizedBox(height: 8),
                      Text('English',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),

              // Placeholder for additional buttons
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(8),
                  iconSize: 80,
                  color: Colors.cyan,
                  icon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quickreply_rounded),
                      const SizedBox(height: 8),
                      Text('Quick Titles',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () {
                    context.push('/quick_titles');
                  },
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(8),
                  iconSize: 80,
                  color: Colors.redAccent,
                  icon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.savings_rounded),
                      const SizedBox(height: 8),
                      Text('Saving Goals',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () {
                    //context.push('/quick_titles');
                  },
                ),
              ),
            ],
          )),
    );
  }
}
