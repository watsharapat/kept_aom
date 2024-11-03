import 'package:flutter/material.dart';
import 'package:kept_aom/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://emnwnqgvnxwbskdyiizj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtbnducWd2bnh3YnNrZHlpaXpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA1NjQ5NzIsImV4cCI6MjA0NjE0MDk3Mn0.YCtH2DYN1XKOe6V_o2uS0nMEKrLk9FWdSYDVafQZro4',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
