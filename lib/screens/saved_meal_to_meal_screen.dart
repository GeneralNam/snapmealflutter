import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../widgets/long_button.dart';
import '../widgets/nutrition_info.dart';
import 'dart:convert';
import 'dart:io';

class SavedMealToMealScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> savedMeal;

  const SavedMealToMealScreen({
    super.key,
    required this.savedMeal,
  });

  @override
  ConsumerState<SavedMealToMealScreen> createState() =>
      _SavedMealToMealScreenState();
}

class _SavedMealToMealScreenState extends ConsumerState<SavedMealToMealScreen> {
  final TextEditingController _timeController = TextEditingController();
  String _selectedType = '아침';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _timeController.text =
        '${now.hour > 11 ? "PM" : "AM"} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  Future<void> _saveMeal() async {
    try {
      await DatabaseHelper.instance.saveMeal(
        date: _getFormattedDate(),
        time: _timeController.text,
        type: _selectedType,
        imagePath: widget.savedMeal['imagePath'],
        description: widget.savedMeal['description'],
        nutrition: widget.savedMeal['nutrition'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('식사가 저장되었습니다')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutritionData = jsonDecode(widget.savedMeal['nutrition']);
    final foodName = nutritionData['foodName'] as String;
    final Map<String, String> formattedNutrition =
        Map<String, String>.from(nutritionData['nutrition'] ?? {});

    return Scaffold(
      appBar: AppBar(
        title: Text(foodName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(widget.savedMeal['imagePath']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          hintText: '시간 입력',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedType,
                        underline: Container(),
                        items:
                            const ['아침', '점심', '저녁', '간식'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ExpandableNutritionItem(
                  nutrition: formattedNutrition,
                  foodName: foodName,
                  amount: nutritionData['amount'] as String,
                  changeInfo: (_, __, ___) {},
                  isEditing: false,
                ),
                const SizedBox(height: 24),
                LongButton(
                  text: '추가',
                  emoji: '🍴',
                  onPressed: _saveMeal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }
}
