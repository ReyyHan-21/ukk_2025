import 'package:flutter/material.dart';
import 'package:ukk_2025/pages/component/appbar.dart';
import 'package:ukk_2025/pages/ui/account.dart';
import 'package:ukk_2025/pages/ui/listproduk.dart';
import 'package:ukk_2025/pages/ui/pelanggan.dart';
import 'package:ukk_2025/pages/ui/produk.dart';
import 'package:ukk_2025/pages/ui/transaction.dart';

class route extends StatefulWidget {
  const route({super.key});

  @override
  State<route> createState() => _NavbotState();
}

class _NavbotState extends State<route> {
  int _selectedIndex = 2;

  final List<Widget> _pages = <Widget>[
    Produk(),
    Listproduk(),
    Transaction(),
    Pelanggan(),
    Account(),
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
        preferredSize: Size(0, 45),
        child: Appbars(),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_sharp),
            label: 'List Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customer',
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
