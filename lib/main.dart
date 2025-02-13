import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/auth/login.dart';
import 'package:ukk_2025/pages/component/route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pindahkan ke atas

  await Supabase.initialize(
    url: 'https://mwnbghtiqyzlnyqscqap.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13bmJnaHRpcXl6bG55cXNjcWFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTM5MzQsImV4cCI6MjA1NDI4OTkzNH0.tYNgMOIO93c-YVnr_ZewbI80z8v4FdEptnz9ZZktiew',
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? route() : const Login(),
    );
  }
}
