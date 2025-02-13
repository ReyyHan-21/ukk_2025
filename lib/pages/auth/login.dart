// ignore_for_file: use_build_context_synchronously

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/component/route.dart';
import 'package:ukk_2025/pages/helper/notification.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObsecure = true;
  late SharedPreferences _prefs;

  // * Digunakan untuk Mengambil data dari table username
  Future<void> _login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return NotificationHelper.showError(
          context, 'Wajib Mengisi Username Dan Password');
    }

    try {
      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (kDebugMode) {
        print(Text('Info Login $response'));
      }

      if (mounted) {
        if (response != null) {
          NotificationHelper.showSuccess(context, 'Berhasil Login ');

          await _prefs.setBool('isLoggedIn', true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => route(),
            ),
          );
        } else {
          NotificationHelper.showError(context, 'Username Dan Password Salah');
        }
      }
    } catch (e) {
      NotificationHelper.showError(context, e);
    }
  }

  // *
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    _initPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;
        return Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            width: isWideScreen ? 400 : double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/coffe.png',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFBB784C),
                      // color: const Color(0xFFFF6D0D),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'di ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: 'Coffee Shop ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF6D0D),
                            // color: const Color(0xFFBB784C),
                          ),
                        ),
                        TextSpan(
                          text: 'Kami',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      label: Text('Username'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      label: Text('Password'),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObsecure = !isObsecure;
                          });
                        },
                        icon: Icon(
                          isObsecure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: isObsecure,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Cek apakah sudah login sebelumnya
                      bool isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
                      if (isLoggedIn) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => route(),
                          ),
                        );
                      } else {
                        await _login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF4E342E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
