import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/router/router.dart';
import 'package:kept_aom/viewmodels/login_provider.dart';
import 'package:kept_aom/viewmodels/theme_provider.dart';
import 'package:kept_aom/views/pages/home_page/home_page.dart';
import 'package:kept_aom/views/pages/login_page.dart';
import 'package:kept_aom/views/utils/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://emnwnqgvnxwbskdyiizj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtbnducWd2bnh3YnNrZHlpaXpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA1NjQ5NzIsImV4cCI6MjA0NjE0MDk3Mn0.YCtH2DYN1XKOe6V_o2uS0nMEKrLk9FWdSYDVafQZro4',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final loginState = ref.watch(loginProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'KeptAom',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      //   useMaterial3: true,
      // ),
    );
  }
}
