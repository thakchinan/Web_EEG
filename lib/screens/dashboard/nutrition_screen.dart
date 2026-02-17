import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

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
          'รู้โภชนา',
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
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.restaurant, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text(
                    'โภชนาการบำรุงสมอง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'อาหารที่ช่วยเสริมสร้างการทำงานของสมอง',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // อาหารบำรุงสมอง
            Text(
              'อาหารบำรุงสมอง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            _buildFoodCard(
              emoji: '🐟',
              name: 'ปลาแซลมอน',
              benefit: 'อุดมไปด้วยโอเมก้า 3 (DHA)',
              detail: 'ช่วยเสริมสร้างเซลล์สมอง ลดการอักเสบ เพิ่มความจำ',
              color: Colors.blue,
            ),
            _buildFoodCard(
              emoji: '🥜',
              name: 'ถั่วและเมล็ดพืช',
              benefit: 'วิตามิน E สูง',
              detail: 'ปกป้องเซลล์สมองจากอนุมูลอิสระ ช่วยชะลอการเสื่อมของสมอง',
              color: Colors.brown,
            ),
            _buildFoodCard(
              emoji: '🫐',
              name: 'เบอร์รี่',
              benefit: 'สารต้านอนุมูลอิสระ',
              detail: 'บลูเบอร์รี่ สตรอว์เบอร์รี่ ช่วยเพิ่มการสื่อสารระหว่างเซลล์สมอง',
              color: Colors.purple,
            ),
            _buildFoodCard(
              emoji: '🥚',
              name: 'ไข่',
              benefit: 'โคลีนและวิตามิน B',
              detail: 'ช่วยการทำงานของสารสื่อประสาท เพิ่มความจำและสมาธิ',
              color: Colors.orange,
            ),
            _buildFoodCard(
              emoji: '🥦',
              name: 'ผักใบเขียวเข้ม',
              benefit: 'โฟเลต วิตามิน K',
              detail: 'บรอกโคลี ผักโขม ช่วยชะลอการเสื่อมของสมองตามวัย',
              color: Colors.green,
            ),
            _buildFoodCard(
              emoji: '🍫',
              name: 'ดาร์กช็อกโกแลต',
              benefit: 'ฟลาโวนอยด์และคาเฟอีน',
              detail: 'เพิ่มการไหลเวียนของเลือดไปเลี้ยงสมอง เพิ่มความตื่นตัว',
              color: Colors.brown.shade800,
            ),

            const SizedBox(height: 24),

            // เคล็ดลับ
            Text(
              'เคล็ดลับโภชนาการ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            _buildTipCard('💧', 'ดื่มน้ำให้เพียงพอ', 'สมองต้องการน้ำในการทำงาน ควรดื่มน้ำอย่างน้อย 8 แก้วต่อวัน'),
            _buildTipCard('🍽️', 'กินอาหารเช้าทุกวัน', 'อาหารเช้าช่วยเพิ่มสมาธิและพลังงานให้สมองตลอดวัน'),
            _buildTipCard('🚫', 'ลดน้ำตาลและอาหารแปรรูป', 'น้ำตาลมากเกินไปส่งผลเสียต่อการทำงานของสมอง'),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard({
    required String emoji,
    required String name,
    required String benefit,
    required String detail,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(benefit, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(detail, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String emoji, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
