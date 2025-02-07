import 'package:flutter/material.dart';

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
            onPressed: () {},
            icon: Icon(Icons.logout),
          )
        ],
      ),
    );
  }

  // Masih Belum ada
  void logout() {}
}
