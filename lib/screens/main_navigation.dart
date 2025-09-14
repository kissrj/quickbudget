import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/bottom_navigation.dart';

class MainNavigation extends StatefulWidget {
  final Function(String)? onLanguageChange;
  final Locale? currentLocale;

  const MainNavigation({Key? key, this.onLanguageChange, this.currentLocale})
    : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const HistoryScreen(),
      SettingsScreen(
        onLanguageChange: widget.onLanguageChange,
        currentLocale: widget.currentLocale,
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF122118),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
