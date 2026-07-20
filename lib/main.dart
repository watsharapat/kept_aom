import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/core/router/router.dart';
import 'package:kept_aom/core/theme/theme_provider.dart';
import 'package:kept_aom/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'KeptAom',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
    );
  }
}
