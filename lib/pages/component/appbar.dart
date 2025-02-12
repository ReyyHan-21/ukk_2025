import 'package:flutter/material.dart';
import 'package:ukk_2025/pages/auth/login.dart';

class Appbars extends StatelessWidget {
  final Widget? customeIcon;

  const Appbars({super.key, this.customeIcon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CircleAvatar(
          backgroundColor: Colors.white,
          child: Image.asset('profile.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
              );
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
    );
  }
}
