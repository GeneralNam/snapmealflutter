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
      {super.key,
      required this.nutrition,
      required this.foodName,
      required this.amount,
      required this.changeInfo});

  final Map<String, String> nutrition;
  final String foodName;
  final String amount;
  final Function(String, String, Map<String, String>) changeInfo;
  @override
  State<ExpandableNutritionItem> createState() =>
      _ExpandableNutritionItemState();
}

class _ExpandableNutritionItemState extends State<ExpandableNutritionItem> {
  bool _isExpanded = false;
  bool _isEditing = true;
  late TextEditingController _foodNameController;
  late TextEditingController _amountController;
  late Map<String, TextEditingController> _nutritionControllers;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.foodName);
    _amountController = TextEditingController(text: widget.amount);

    // 각 영양소별 컨트롤러 초기화
    _nutritionControllers = {
      for (var entry in widget.nutrition.entries)
        entry.key: TextEditingController(text: entry.value)
    };
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _amountController.dispose();
    _nutritionControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

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
                  Expanded(
                    child: Row(
                      children: [
                        if (_isEditing) ...[
                          Expanded(
                            child: TextField(
                              controller: _foodNameController,
                              decoration: const InputDecoration(
                                labelText: '음식 이름',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                widget.changeInfo(
                                  value,
                                  _amountController.text,
                                  widget.nutrition,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: '양',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                widget.changeInfo(
                                  _foodNameController.text,
                                  value,
                                  widget.nutrition,
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Text(
                              widget.foodName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            widget.amount,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
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
            if (_isEditing) ...[
              _buildNutritionInput(
                  '칼로리', Icons.local_fire_department, Colors.orange),
              _buildNutritionInput('단백질', Icons.egg_outlined, Colors.red),
              _buildNutritionInput(
                  '지방', Icons.oil_barrel_outlined, Colors.yellow),
              _buildNutritionInput('식이섬유', Icons.eco_outlined, Colors.green),
              _buildNutritionInput(
                  '나트륨', Icons.water_drop_outlined, Colors.grey),
              _buildNutritionInput('탄수화물', Icons.grain_outlined, Colors.amber),
              _buildNutritionInput(
                  '당류', Icons.bubble_chart_outlined, Colors.orange),
            ] else ...[
              NutritionItem.build('칼로리', widget.nutrition['칼로리'] ?? '0',
                  Icons.local_fire_department, Colors.orange),
              NutritionItem.build('단백질', widget.nutrition['단백질'] ?? '0',
                  Icons.egg_outlined, Colors.red),
              NutritionItem.build('지방', widget.nutrition['지방'] ?? '0',
                  Icons.oil_barrel_outlined, Colors.yellow),
              NutritionItem.build('식이섬유', widget.nutrition['식이섬유'] ?? '0',
                  Icons.eco_outlined, Colors.green),
              NutritionItem.build('나트륨', widget.nutrition['나트륨'] ?? '0',
                  Icons.water_drop_outlined, Colors.grey),
              NutritionItem.build('탄수화물', widget.nutrition['탄수화물'] ?? '0',
                  Icons.grain_outlined, Colors.amber),
              NutritionItem.build('당류', widget.nutrition['당류'] ?? '0',
                  Icons.bubble_chart_outlined, Colors.orange),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionInput(String title, IconData icon, Color color) {
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
          SizedBox(
            width: 100,
            child: TextField(
              controller: _nutritionControllers[title],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final updatedNutrition =
                    Map<String, String>.from(widget.nutrition);
                updatedNutrition[title] = value;
                widget.changeInfo(
                  _foodNameController.text,
                  _amountController.text,
                  updatedNutrition,
                );
              },
            ),
          ),
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
