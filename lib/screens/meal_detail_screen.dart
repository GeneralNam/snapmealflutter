import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../widgets/nutrition_info.dart';
import '../database/database_helper.dart';
import '../widgets/long_button.dart';

class MealDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meal;
  final Function(String, String, Map<String, String>) changeInfo;

  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.changeInfo,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _descriptionController;
  late String _foodName;
  late String _amount;
  late Map<String, String> _nutrition;

  @override
  void initState() {
    super.initState();
    final nutritionData = jsonDecode(widget.meal['nutrition']);
    _descriptionController =
        TextEditingController(text: widget.meal['description']);
    _foodName = nutritionData['foodName'];
    _amount = nutritionData['amount'];
    _nutrition = Map<String, String>.from(nutritionData['nutrition']);
  }

  Future<void> _updateMeal() async {
    try {
      final nutritionData = {
        'foodName': _foodName,
        'amount': _amount,
        'nutrition': _nutrition,
      };

      await DatabaseHelper.instance.updateMeal(
        id: widget.meal['id'],
        description: _descriptionController.text,
        nutrition: jsonEncode(nutritionData),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정에 실패했습니다')),
        );
      }
    }
  }

  Future<void> _deleteMeal() async {
    try {
      await DatabaseHelper.instance.deleteMeal(widget.meal['id']);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했습니다')),
        );
      }
    }
  }

  void _updateNutrition(
      String foodName, String amount, Map<String, String> nutrition) {
    setState(() {
      _foodName = foodName;
      _amount = amount;
      _nutrition = nutrition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal['type'] ?? '식사 상세'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('식사 삭제'),
                  content: const Text('정말 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteMeal();
                      },
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMealDetail(),
                const SizedBox(height: 24),
                ExpandableNutritionItem(
                  nutrition: _nutrition,
                  foodName: _foodName,
                  amount: _amount,
                  changeInfo: _updateNutrition,
                  isEditing: _isEditing,
                ),
                if (widget.meal['description'] != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '설명',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.meal['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  LongButton(
                    text: '완료',
                    emoji: '✅',
                    onPressed: _updateMeal,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: widget.meal['imagePath'].isNotEmpty
                  ? Image.file(
                      File(widget.meal['imagePath']),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.meal['type'] ?? '식사이름',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.meal['time'] ?? '시간',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
