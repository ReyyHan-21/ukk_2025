import 'package:flutter/material.dart';
import 'package:ukk_2025/pages/component/appbar.dart';
import 'package:ukk_2025/pages/ui/dashboard.dart';

class route extends StatefulWidget {
  const route({super.key});

  @override
  State<route> createState() => _NavbotState();
}

class _NavbotState extends State<route> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Dashboard(
      user: {},
    ),
    Text('Halo'),
    Text('Halo'),
    Text('Halo'),
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
            icon: Icon(Icons.production_quantity_limits),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Nomor 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Nomor 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Nomor 4',
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
