import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DailyRoutineScreen extends StatelessWidget {
  const DailyRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'กิจวัตรบำรุงสมอง',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.access_time, size: 48, color: Colors.orange),
                  const SizedBox(height: 12),
                  const Text(
                    'กิจวัตรบำรุงสมอง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'กิจกรรมประจำวันที่ช่วยดูแลสมอง',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // กิจวัตรประจำวัน
            Text(
              'กิจวัตรประจำวัน',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            _buildRoutineCard(
              time: '06:00',
              emoji: '🌅',
              title: 'ตื่นนอน ดื่มน้ำ',
              description: 'เริ่มต้นวันด้วยการดื่มน้ำเปล่า 1-2 แก้ว เพื่อกระตุ้นการทำงานของสมอง',
              color: Colors.amber,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '06:30',
              emoji: '🧘',
              title: 'ทำสมาธิ 10 นาที',
              description: 'นั่งสมาธิหรือหายใจลึกๆ เพื่อลดความเครียดและเพิ่มสมาธิ',
              color: Colors.green,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '07:00',
              emoji: '🍳',
              title: 'อาหารเช้าบำรุงสมอง',
              description: 'กินอาหารเช้าที่มีโปรตีนและโอเมก้า 3 เช่น ไข่ ปลา ถั่ว',
              color: Colors.orange,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '09:00',
              emoji: '📱',
              title: 'ทำแบบทดสอบ PHQ-9',
              description: 'ประเมินสุขภาพจิตประจำวัน ติดตามแนวโน้มการเปลี่ยนแปลง',
              color: Colors.blue,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '12:00',
              emoji: '👁️',
              title: 'พักผ่อนสายตา',
              description: 'มองไกลทุกๆ 20 นาที ลดความเมื่อยล้าของดวงตาและสมอง',
              color: Colors.teal,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '15:00',
              emoji: '🧩',
              title: 'เล่นเกมบริหารสมอง',
              description: 'เล่นมินิเกมฝึกสมอง 15-20 นาที เพื่อเพิ่มความจำและสมาธิ',
              color: Colors.purple,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '18:00',
              emoji: '🏃',
              title: 'ออกกำลังกาย',
              description: 'ออกกำลังกายเบาๆ 30 นาที เพิ่มเลือดไปเลี้ยงสมอง',
              color: Colors.red,
            ),
            _buildTimelineDivider(),
            _buildRoutineCard(
              time: '22:00',
              emoji: '😴',
              title: 'เข้านอน',
              description: 'นอนหลับพักผ่อน 7-8 ชั่วโมง สมองจะจัดระเบียบข้อมูลขณะหลับ',
              color: Colors.indigo,
            ),

            const SizedBox(height: 24),

            // คำแนะนำ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'คำแนะนำ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ทำกิจวัตรเหล่านี้อย่างสม่ำเสมอจะช่วยให้สมองทำงานได้ดีขึ้น สามารถปรับเวลาให้เหมาะกับไลฟ์สไตล์ของคุณได้',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard({
    required String time,
    required String emoji,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Container(
        width: 2,
        height: 16,
        color: Colors.grey[300],
      ),
    );
  }
}
