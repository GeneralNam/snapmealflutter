import 'package:flutter/material.dart';

// 1. 영양소 아이템 빌더
class NutritionItem {
  static Widget build(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title),
          const Spacer(),
          Text(amount),
        ],
      ),
    );
  }
}

class ExpandableNutritionItem extends StatefulWidget {
  const ExpandableNutritionItem(
      {super.key, required this.title, required this.amount});

  final String title;
  final String amount;

  @override
  State<ExpandableNutritionItem> createState() =>
      _ExpandableNutritionItemState();
}

class _ExpandableNutritionItemState extends State<ExpandableNutritionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.amount,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            NutritionItem.build(
                '칼로리', '230kcal', Icons.local_fire_department, Colors.orange),
            NutritionItem.build('단백질', '50g', Icons.egg_outlined, Colors.red),
            NutritionItem.build(
                '지방', '23g', Icons.oil_barrel_outlined, Colors.yellow),
            NutritionItem.build(
                '식이섬유', '20g', Icons.eco_outlined, Colors.green),
            NutritionItem.build(
                '나트륨', '311mg', Icons.water_drop_outlined, Colors.grey),
            NutritionItem.build(
                '탄수화물', '300g', Icons.grain_outlined, Colors.amber),
            NutritionItem.build(
                '당류', '232mg', Icons.bubble_chart_outlined, Colors.orange),
          ],
        ],
      ),
    );
  }
}

// 3. 그리드 형태의 영양소 정보
class NutritionInfoGrid extends StatelessWidget {
  const NutritionInfoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: const [
          NutritionGridItem(
            icon: Icons.local_fire_department,
            title: '칼로리',
            amount: '480kcal',
            color: Colors.deepOrange,
          ),
          NutritionGridItem(
            icon: Icons.grain_outlined,
            title: '탄수화물',
            amount: '300g',
            color: Colors.amber,
          ),
          NutritionGridItem(
            icon: Icons.egg_outlined,
            title: '단백질',
            amount: '50g',
            color: Colors.redAccent,
          ),
          NutritionGridItem(
            icon: Icons.oil_barrel_outlined,
            title: '지방',
            amount: '23g',
            color: Colors.yellow,
          ),
          NutritionGridItem(
            icon: Icons.eco_outlined,
            title: '식이섬유',
            amount: '20g',
            color: Colors.green,
          ),
          NutritionGridItem(
            icon: Icons.water_drop_outlined,
            title: '나트륨',
            amount: '311mg',
            color: Colors.blueGrey,
          ),
          NutritionGridItem(
            icon: Icons.bubble_chart_outlined,
            title: '당류',
            amount: '232mg',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

// 4. 그리드 아이템
class NutritionGridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final Color color;

  const NutritionGridItem({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
