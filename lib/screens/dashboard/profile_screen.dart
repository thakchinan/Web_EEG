import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'saved_items_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final Function(User)? onUserUpdated;

  const ProfileScreen({super.key, required this.user, this.onUserUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadProfile(); // โหลดข้อมูลจาก Supabase ทันที
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ถ้า parent ส่ง user ใหม่มา → อัปเดต
    if (oldWidget.user.id != widget.user.id ||
        oldWidget.user.fullName != widget.user.fullName ||
        oldWidget.user.email != widget.user.email ||
        oldWidget.user.phone != widget.user.phone) {
      setState(() => _currentUser = widget.user);
    }
  }

  /// โหลดข้อมูลล่าสุดจาก Supabase
  Future<void> _loadProfile() async {
    try {
      final result = await ApiService.getProfile(_currentUser.id);
      if (result['success'] == true && result['profile'] != null) {
        final freshUser = User.fromJson(result['profile']);
        if (mounted) {
          setState(() {
            _currentUser = freshUser;
            _isLoading = false;
          });
          widget.onUserUpdated?.call(freshUser);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// เปิดหน้า Edit Profile แล้วรับ updated user กลับมา
  Future<void> _openEditProfile() async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _currentUser)),
    );

    if (updatedUser != null) {
      setState(() => _currentUser = updatedUser);
      widget.onUserUpdated?.call(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'โปรไฟล์',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SettingsScreen(user: _currentUser)),
              );
            },
            icon: Icon(Icons.settings, color: AppColors.primaryBlue),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ===== Avatar =====
                    GestureDetector(
                      onTap: _openEditProfile,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          image: _currentUser.avatarUrl != null &&
                                  _currentUser.avatarUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_currentUser.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _currentUser.avatarUrl == null ||
                                _currentUser.avatarUrl!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== ชื่อ =====
                    Text(
                      _currentUser.fullName ?? _currentUser.username,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser.email ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),

                    const SizedBox(height: 24),

                    // ===== ข้อมูลส่วนตัว Card =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ข้อมูลส่วนตัว',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProfileField(
                            Icons.person_outline,
                            'ชื่อจริง-นามสกุล',
                            _currentUser.fullName ?? '-',
                          ),
                          _buildProfileField(
                            Icons.phone_outlined,
                            'เบอร์โทรศัพท์',
                            _currentUser.phone ?? '-',
                          ),
                          _buildProfileField(
                            Icons.email_outlined,
                            'อีเมล',
                            _currentUser.email ?? '-',
                          ),
                          _buildProfileField(
                            Icons.cake_outlined,
                            'วันเกิด',
                            _currentUser.birthDate ?? '-',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== เมนู =====
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      label: 'แก้ไขข้อมูลส่วนตัว',
                      onTap: _openEditProfile,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.bookmark_outline,
                      label: 'บันทึกไว้',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      label: 'ตั้งค่า',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SettingsScreen(user: _currentUser)),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      label: 'ช่วยเหลือ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HelpScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      label: 'ออกจากระบบ',
                      isDestructive: true,
                      onTap: () => _showLogoutConfirmation(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ===== Profile Field Widget =====
  Widget _buildProfileField(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  // ===== เมนูรายการ =====
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive ? Colors.red : AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }


  // ===== ออกจากระบบ =====
  void _showLogoutConfirmation(BuildContext context) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
