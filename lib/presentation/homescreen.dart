import 'package:_abm/presentation/bottomscreen.dart/calculatescreen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'bottomscreen.dart/homepage.dart';
import 'bottomscreen.dart/lsitscreen.dart';
import 'bottomscreen.dart/profilescreen.dart';
import 'bottomscreen/documents_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomePage(studentsWithLessThanAmount: []),
      const ListScreen(),
      isDarkMode ? const DocumentsScreen() : const CalculateScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor, // Adapt to theme
        color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        buttonBackgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        height: 60, // Adjust the height if needed
        index: _selectedIndex,
        items: <Widget>[
          const Icon(Icons.home),
          const Icon(Icons.list, size: 30),
          Icon(isDarkMode ? Icons.folder : Icons.calculate, size: 30),
          // Icon(Icons.account_circle_rounded, size: 30),
        ],
        onTap: _onItemTapped,
        animationDuration:
            const Duration(milliseconds: 300), // Smooth animation
        animationCurve: Curves.easeInOut, // Animation curve for item switching
      ),
    );
  }
}
