import 'package:flutter/material.dart';

class NutritionInfoExpanded extends StatefulWidget {
  const NutritionInfoExpanded({super.key});

  @override
  State<NutritionInfoExpanded> createState() => _NutritionInfoExpandedState();
}

class _NutritionInfoExpandedState extends State<NutritionInfoExpanded> {
  final List<bool> _isExpanded = [false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildExpandedItem('만두국', '1인분 312g', 0),
        _buildExpandedItem('김치', '1접시 59g', 1),
      ],
    );
  }

  Widget _buildExpandedItem(String title, String amount, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Row(
                children: [
                  Text(amount),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    },
                    icon: Icon(
                      _isExpanded[index]
                          ? Icons.expand_more
                          : Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isExpanded[index]) ...[
            _buildNutritionItem(
                '칼로리', '230kcal', Icons.local_fire_department, Colors.orange),
            _buildNutritionItem('단백질', '50g', Icons.egg_outlined, Colors.red),
            _buildNutritionItem(
                '지방', '23g', Icons.oil_barrel_outlined, Colors.yellow),
            _buildNutritionItem(
                '식이섬유', '20g', Icons.eco_outlined, Colors.green),
            _buildNutritionItem(
                '나트륨', '311mg', Icons.water_drop_outlined, Colors.grey),
            _buildNutritionItem(
                '탄수화물', '300g', Icons.grain_outlined, Colors.amber),
            _buildNutritionItem(
                '당류', '232mg', Icons.bubble_chart_outlined, Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
      String title, String amount, IconData icon, Color color) {
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
