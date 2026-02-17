import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/recommendation_screen.dart';
import 'dashboard/profile_screen.dart';
import 'dashboard/activities_dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  final User user;

  const MainNavigation({super.key, required this.user});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  /// เมื่อ user ถูกอัปเดต (เช่น จาก EditProfileScreen)
  void _onUserUpdated(User updatedUser) {
    setState(() => _currentUser = updatedUser);
  }

  List<Widget> get _screens => [
    HomeScreen(user: _currentUser),
    RecommendationScreen(user: _currentUser),
    ProfileScreen(user: _currentUser, onUserUpdated: _onUserUpdated),
    ActivitiesDashboardScreen(user: _currentUser),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'หน้าแรก'),
                _buildNavItem(1, Icons.chat_bubble_outline_rounded, 'คำแนะนำ'),
                _buildNavItem(2, Icons.person_outline_rounded, 'โปรไฟล์'),
                _buildNavItem(3, Icons.calendar_today_outlined, 'กิจกรรม'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
