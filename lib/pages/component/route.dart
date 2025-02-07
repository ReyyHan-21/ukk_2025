import 'package:flutter/material.dart';
import 'package:ukk_2025/pages/component/appbar.dart';
import 'package:ukk_2025/pages/ui/account.dart';
import 'package:ukk_2025/pages/ui/produk.dart';

class route extends StatefulWidget {
  const route({super.key});

  @override
  State<route> createState() => _NavbotState();
}

class _NavbotState extends State<route> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Produk(),
    Text('Halo'),
    Text('Halo'),
    Account(
      user: {},
    ),
  ];

  void _ontap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0, 65),
        child: Appbars(),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.six_ft_apart),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Nomor 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Nomor 4',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _ontap,
        fixedColor: Colors.red,
      ),
    );
  }
}
