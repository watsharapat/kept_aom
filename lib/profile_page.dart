import 'package:flutter/material.dart';
import 'package:kept_aom/login_page.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in');
        return;
      }

      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      setState(() {
        transactions = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> _addTransaction() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final now = DateTime.now();
      final newTransaction = {
        'user_id': userId,
        'date': now.toIso8601String(),
        'amount': 1000,
        'via': 'Cash',
        'type_id': 1,
        'title': 'Newer Transaction',
        'description': 'This is a test transaction 2',
      };

      await supabase.from('transactions').insert(newTransaction);

      setState(() {
        transactions.insert(0, newTransaction);
      });
    } catch (error) {
      print('Error adding transaction: $error');
      // อาจจะเพิ่ม UI แจ้งเตือน error ให้ user ทราบ เช่น
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            child:
                const Text('Sign out', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (profileImageUrl != null)
            ClipOval(
              child: Image.network(
                profileImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            fullName ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(transaction['title'] ?? 'No Title'),
                  subtitle: Text(
                    'Date: ${transaction['date']}\nAmount: ${transaction['amount']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
