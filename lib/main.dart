import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/auth/login.dart';
import 'package:ukk_2025/pages/component/route.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://mwnbghtiqyzlnyqscqap.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13bmJnaHRpcXl6bG55cXNjcWFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTM5MzQsImV4cCI6MjA1NDI4OTkzNH0.tYNgMOIO93c-YVnr_ZewbI80z8v4FdEptnz9ZZktiew',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const route(),
    );
  }
}
