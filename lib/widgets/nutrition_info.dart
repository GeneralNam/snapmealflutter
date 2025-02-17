import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 1. 영양소 아이템 빌더
class NutritionItem {
  static Widget build(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    String displayAmount = amount;
    if (!amount.contains('g') &&
        !amount.contains('kcal') &&
        !amount.contains('mg')) {
      displayAmount = amount + _getSuffix(title);
    }

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
          Text(displayAmount),
        ],
      ),
    );
  }

  static String _getSuffix(String title) {
    switch (title) {
      case '칼로리':
        return 'kcal';
      case '나트륨':
      case '당류':
        return 'mg';
      default:
        return 'g';
    }
  }
}

class ExpandableNutritionItem extends StatefulWidget {
  const ExpandableNutritionItem({
    super.key,
    required this.nutrition,
    required this.foodName,
    required this.amount,
    required this.changeInfo,
    this.isEditing = false,
  });

  final Map<String, String> nutrition;
  final String foodName;
  final String amount;
  final Function(String, String, Map<String, String>) changeInfo;
  final bool isEditing;
  @override
  State<ExpandableNutritionItem> createState() =>
      _ExpandableNutritionItemState();
}

class _ExpandableNutritionItemState extends State<ExpandableNutritionItem> {
  bool _isExpanded = false;
  late TextEditingController _foodNameController;
  late TextEditingController _amountController;
  late Map<String, TextEditingController> _nutritionControllers;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.foodName);
    _amountController = TextEditingController(
      text: widget.amount.replaceAll('g', ''),
    );

    _nutritionControllers = {
      for (var entry in widget.nutrition.entries)
        entry.key: TextEditingController(
          text: entry.value.replaceAll(RegExp(r'[a-zA-Z]'), ''),
        )
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
                        if (widget.isEditing) ...[
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
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
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
                                const SizedBox(width: 4),
                                const Text(
                                  'g',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
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
                            widget.amount + 'g',
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
            if (widget.isEditing) ...[
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
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _nutritionControllers[title],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
              const SizedBox(width: 4),
              Text(
                _getSuffix(title),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSuffix(String title) {
    switch (title) {
      case '칼로리':
        return 'kcal';
      case '나트륨':
      case '당류':
        return 'mg';
      default:
        return 'g';
    }
  }
}

class NutritionInfoGrid extends StatefulWidget {
  final Map<String, String>? nutrition;
  final bool isEditing;
  final Function(Map<String, String>)? onNutritionChanged;

  const NutritionInfoGrid({
    super.key,
    this.nutrition,
    this.isEditing = false,
    this.onNutritionChanged,
  });

  @override
  State<NutritionInfoGrid> createState() => _NutritionInfoGridState();
}

class _NutritionInfoGridState extends State<NutritionInfoGrid> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // widget.nutrition이 변경될 때 컨트롤러 값 업데이트
  @override
  void didUpdateWidget(NutritionInfoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nutrition != oldWidget.nutrition) {
      _controllers['칼로리']?.text =
          widget.nutrition?['칼로리']?.replaceAll('kcal', '') ?? '0';
      _controllers['탄수화물']?.text =
          widget.nutrition?['탄수화물']?.replaceAll('g', '') ?? '0';
      _controllers['단백질']?.text =
          widget.nutrition?['단백질']?.replaceAll('g', '') ?? '0';
      _controllers['지방']?.text =
          widget.nutrition?['지방']?.replaceAll('g', '') ?? '0';
      _controllers['식이섬유']?.text =
          widget.nutrition?['식이섬유']?.replaceAll('g', '') ?? '0';
      _controllers['나트륨']?.text =
          widget.nutrition?['나트륨']?.replaceAll('mg', '') ?? '0';
      _controllers['당류']?.text =
          widget.nutrition?['당류']?.replaceAll('mg', '') ?? '0';
    }
  }

  void _initializeControllers() {
    _controllers = {
      '칼로리': TextEditingController(
          text: widget.nutrition?['칼로리']?.replaceAll('kcal', '') ?? '0'),
      '탄수화물': TextEditingController(
          text: widget.nutrition?['탄수화물']?.replaceAll('g', '') ?? '0'),
      '단백질': TextEditingController(
          text: widget.nutrition?['단백질']?.replaceAll('g', '') ?? '0'),
      '지방': TextEditingController(
          text: widget.nutrition?['지방']?.replaceAll('g', '') ?? '0'),
      '식이섬유': TextEditingController(
          text: widget.nutrition?['식이섬유']?.replaceAll('g', '') ?? '0'),
      '나트륨': TextEditingController(
          text: widget.nutrition?['나트륨']?.replaceAll('mg', '') ?? '0'),
      '당류': TextEditingController(
          text: widget.nutrition?['당류']?.replaceAll('mg', '') ?? '0'),
    };
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

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
        childAspectRatio: widget.isEditing ? 1.2 : 1.8,
        children: [
          _buildGridItem(
            icon: Icons.local_fire_department,
            title: '칼로리',
            controller: _controllers['칼로리']!,
            color: Colors.deepOrange,
            suffix: 'kcal',
          ),
          _buildGridItem(
            icon: Icons.grain_outlined,
            title: '탄수화물',
            controller: _controllers['탄수화물']!,
            color: Colors.amber,
            suffix: 'g',
          ),
          _buildGridItem(
            icon: Icons.egg_outlined,
            title: '단백질',
            controller: _controllers['단백질']!,
            color: Colors.redAccent,
            suffix: 'g',
          ),
          _buildGridItem(
            icon: Icons.oil_barrel_outlined,
            title: '지방',
            controller: _controllers['지방']!,
            color: Colors.yellow,
            suffix: 'g',
          ),
          _buildGridItem(
            icon: Icons.eco_outlined,
            title: '식이섬유',
            controller: _controllers['식이섬유']!,
            color: Colors.green,
            suffix: 'g',
          ),
          _buildGridItem(
            icon: Icons.water_drop_outlined,
            title: '나트륨',
            controller: _controllers['나트륨']!,
            color: Colors.blueGrey,
            suffix: 'mg',
          ),
          _buildGridItem(
            icon: Icons.bubble_chart_outlined,
            title: '당류',
            controller: _controllers['당류']!,
            color: Colors.orange,
            suffix: 'mg',
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required Color color,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.isEditing) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (widget.onNutritionChanged != null) {
                        final updatedNutrition = {
                          for (var entry in _controllers.entries)
                            entry.key:
                                '${entry.value.text}${_getSuffix(entry.key)}'
                        };
                        widget.onNutritionChanged!(updatedNutrition);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${controller.text}$suffix',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSuffix(String title) {
    switch (title) {
      case '칼로리':
        return 'kcal';
      case '나트륨':
      case '당류':
        return 'mg';
      default:
        return 'g';
    }
  }
}
