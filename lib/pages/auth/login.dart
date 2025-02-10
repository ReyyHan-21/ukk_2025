import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/component/route.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObsecure = true;

  // Digunakan untuk menampilkan pesan dalam bentuk snackbar
  void _showField(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // Digunakan untuk Mengambil data dari table username
  Future<void> _login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty) {
      return _showField('Username Wajib Diisi');
    }

    if (password.isEmpty) {
      return _showField('password Wajib Diisi');
    }

    try {
      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      print(Text('Info Login $response'));

      if (mounted) {
        if (response != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => route(),
            ),
          );
        } else {
          _showField('Username dan Password Salah');
        }
      }
    } catch (error) {
      _showField('Error');
    }
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
                        icon: Icon(isObsecure
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                    obscureText: isObsecure,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(),
                    onPressed: _login,
                    child: Text('Masuk'),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
