import 'package:flutter/material.dart';
import 'package:sayfbolt/screens/client/account_screen.dart';
import 'package:sayfbolt/screens/client/home_screen.dart';
import 'package:sayfbolt/screens/client/rides_screen.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final Color _primaryColor = const Color(0xFF4A98FF);
  final Color _secondaryColor = const Color(0xFF626EE3);

  late AnimationController _animationController;

  final List<Widget> _pages = [
    const SearchRidesPage(),  // Previously HomePage
    const MyTripsPage(),      // Previously RidesPage
    const AccountPage(),      // Previously SettingsPage
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBar(
                height: 64,
                selectedIndex: _selectedIndex,
                backgroundColor: Colors.white,
                indicatorColor: _primaryColor.withOpacity(0.1),
                elevation: 0,
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                animationDuration: const Duration(milliseconds: 400),
                onDestinationSelected: _onItemTapped,
                destinations: [
                  _buildNavItem(
                    Icons.search_outlined,
                    Icons.search_rounded,
                    'Search',
                    0,
                  ),
                  _buildNavItem(
                    Icons.directions_car_outlined,
                    Icons.directions_car_filled_rounded,
                    'My Trips',
                    1,
                  ),
                  _buildNavItem(
                    Icons.person_outline_rounded,
                    Icons.person_rounded,
                    'Account',
                    2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index, {
    bool hasBadge = false,
  }) {
    final isSelected = _selectedIndex == index;

    Widget icon = Icon(
      outlinedIcon,
      size: 26,
      color: isSelected ? _primaryColor : Colors.grey.shade600,
    );

    Widget selectedIcon = Icon(
      filledIcon,
      size: 26,
      color: _primaryColor,
    );

    if (hasBadge) {
      icon = Badge(
        smallSize: 8,
        backgroundColor: _secondaryColor,
        isLabelVisible: true,
        child: icon,
      );

      selectedIcon = Badge(
        smallSize: 8,
        backgroundColor: _secondaryColor,
        isLabelVisible: true,
        child: selectedIcon,
      );
    }

    return NavigationDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: icon,
      ),
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: selectedIcon,
      ),
      label: label,
    );
  }
}
