import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import 'caretaker_screen.dart';
import 'daily_routine_screen.dart';
import 'mini_games_screen.dart';
import 'nutrition_screen.dart';
import 'settings_screen.dart';

class ActivitiesDashboardScreen extends StatefulWidget {
  final User user;

  const ActivitiesDashboardScreen({super.key, required this.user});

  @override
  State<ActivitiesDashboardScreen> createState() => _ActivitiesDashboardScreenState();
}

class _ActivitiesDashboardScreenState extends State<ActivitiesDashboardScreen> {
  List<Map<String, dynamic>> schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    
    final result = await ApiService.getSchedules(widget.user.id);
    
    if (result['success'] == true && result['schedules'] != null) {
      setState(() {
        schedules = List<Map<String, dynamic>>.from(result['schedules']);
        _isLoading = false;
      });
    } else {
      // Use default schedules if API fails
      setState(() {
        schedules = [
          {
            'id': 0,
            'time': '09:00',
            'title': 'ทดสอบความเครียด',
            'description': 'แบบทดสอบรายสัปดาห์',
            'icon_name': 'quiz',
            'color': 'blue',
          },
          {
            'id': 0,
            'time': '12:00',
            'title': 'พักผ่อนสายตา',
            'description': 'มองไกลทุกๆ 20 นาที',
            'icon_name': 'visibility',
            'color': 'green',
          },
          {
            'id': 0,
            'time': '15:00',
            'title': 'เล่นเกมบริหารสมอง',
            'description': 'มินิเกม 15 นาที',
            'icon_name': 'games',
            'color': 'orange',
          },
        ];
        _isLoading = false;
      });
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'quiz': return Icons.quiz;
      case 'visibility': return Icons.visibility;
      case 'games': return Icons.games;
      case 'event': return Icons.event;
      case 'alarm': return Icons.alarm;
      case 'fitness': return Icons.fitness_center;
      case 'restaurant': return Icons.restaurant;
      case 'book': return Icons.book;
      default: return Icons.event;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      default: return Colors.purple;
    }
  }

  Future<void> _addSchedule(String title, String time, String description) async {
    final result = await ApiService.addSchedule(
      userId: widget.user.id,
      title: title,
      description: description,
      time: time,
    );
    
    if (result['success'] == true) {
      await _loadSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มกำหนดการแล้ว')),
        );
      }
    } else {
      // Add locally if API fails
      setState(() {
        schedules.add({
          'id': 0,
          'time': time,
          'title': title,
          'description': description,
          'icon_name': 'event',
          'color': 'purple',
        });
      });
    }
  }

  Future<void> _deleteSchedule(int index, int scheduleId, String title) async {
    if (scheduleId > 0) {
      final result = await ApiService.deleteSchedule(
        scheduleId: scheduleId,
        userId: widget.user.id,
      );
      
      if (result['success'] == true) {
        await _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ลบ "$title" แล้ว')),
          );
        }
      }
    } else {
      setState(() {
        schedules.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบ "$title" แล้ว')),
      );
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
          'กิจกรรม',
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
                MaterialPageRoute(builder: (_) => SettingsScreen(user: widget.user)),
              );
            },
            icon: Icon(Icons.settings, color: AppColors.primaryBlue),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadSchedules,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ลำดับคิดแข่งขัน ตัวคุณเองด้วยมินิเกม',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - 16) / 2;
                          final itemHeight = itemWidth * 0.9;
                          
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: _buildActivityCard(
                                  context,
                                  icon: Icons.people,
                                  label: 'ผู้ดูแล',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const CaretakerScreen()),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: _buildActivityCard(
                                  context,
                                  icon: Icons.games,
                                  label: 'เกมคลายเครียด',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => MiniGamesScreen(user: widget.user)),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: _buildActivityCard(
                                  context,
                                  icon: Icons.restaurant,
                                  label: 'รู้โภชนา',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const NutritionScreen()),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: _buildActivityCard(
                                  context,
                                  icon: Icons.access_time,
                                  label: 'จากกิจวัตร',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const DailyRoutineScreen()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Schedule Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'กำหนดการ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddScheduleDialog(context),
                            icon: Icon(Icons.add, size: 18, color: AppColors.primaryBlue),
                            label: Text('เพิ่ม', style: TextStyle(color: AppColors.primaryBlue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (schedules.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('ยังไม่มีกำหนดการ')),
                        )
                      else
                        ...schedules.asMap().entries.map((entry) {
                          final index = entry.key;
                          final schedule = entry.value;
                          final scheduleId = schedule['id'] is int ? schedule['id'] : int.tryParse(schedule['id'].toString()) ?? 0;
                          
                          return _buildScheduleCard(
                            context,
                            index: index,
                            scheduleId: scheduleId,
                            time: schedule['time'] ?? '',
                            title: schedule['title'] ?? '',
                            desc: schedule['description'] ?? '',
                            icon: _getIcon(schedule['icon_name'] ?? 'event'),
                            color: _getColor(schedule['color'] ?? 'purple'),
                          );
                        }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context, {
    required int index,
    required int scheduleId,
    required String time,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _confirmDelete(context, index, scheduleId, title),
            icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, int scheduleId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ลบกำหนดการ'),
        content: Text('คุณต้องการลบ "$title" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule(index, scheduleId, title);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('เพิ่มกำหนดการ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'ชื่อกำหนดการ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'เวลา',
                  hintText: '09:00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'รายละเอียด',
                  hintText: 'กิจกรรมที่ต้องทำ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && timeController.text.isNotEmpty) {
                Navigator.pop(context);
                _addSchedule(
                  titleController.text,
                  timeController.text,
                  descController.text.isEmpty ? 'กิจกรรมใหม่' : descController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  Widget _buildActivityCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.primaryBlue),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}
