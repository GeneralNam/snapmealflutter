import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/save_meal.dart';
import '../database/database_helper.dart';
import 'dart:io';
import 'dart:convert';
import '../screens/saved_meal_to_meal_screen.dart';

//저장된 식사들 보여주는 위젯젯
class SavedMealsScreen extends ConsumerStatefulWidget {
  const SavedMealsScreen({super.key});

  @override
  ConsumerState<SavedMealsScreen> createState() => _SavedMealsScreenState();
}

class _SavedMealsScreenState extends ConsumerState<SavedMealsScreen> {
  List<Map<String, dynamic>> savedMeals = [];

  @override
  void initState() {
    super.initState();
    _loadSavedMeals();
  }

  Future<void> _loadSavedMeals() async {
    try {
      final meals = await DatabaseHelper.instance.getAllSavedMeals();
      if (mounted) {
        setState(() {
          savedMeals = meals;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장된 식사를 불러오는데 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '저장된 식사',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: savedMeals.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == savedMeals.length) {
                      return _buildAddMealCard(context);
                    }
                    return _buildSavedMealCard(savedMeals[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedMealCard(Map<String, dynamic> meal) {
    final nutritionData = jsonDecode(meal['nutrition']);
    final foodName = nutritionData['foodName'] as String;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavedMealToMealScreen(
              savedMeal: meal,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(meal['imagePath']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMealCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 정사각형 Container
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SaveMealScreen(
                        showTimeInput: false,
                      ),
                    ),
                  );
                  _loadSavedMeals();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 32,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '새로운 식사 추가',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '새로운 식사 저장하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 빈 공간 (음식이름이 있던 자리)
        const SizedBox(height: 12),
      ],
    );
  }
}
