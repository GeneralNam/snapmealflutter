import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/meal_detail_screen.dart';
import '../widgets/nutrition_info.dart';
import '../screens/add_meal_screen.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'dart:io';
import 'dart:convert';
import '../screens/calendar_screen.dart';
import '../screens/saved_meals_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Map<String, dynamic>> mealsInfo = [];
  String _foodName = '음식이름';
  String _amount = '0g';
  Map<String, String> _nutrition = {
    '칼로리': '0kcal',
    '단백질': '0g',
    '지방': '0g',
    '식이섬유': '0g',
    '나트륨': '0mg',
    '탄수화물': '0g',
    '당류': '0mg',
  };
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }

  Future<void> _loadTodayMeals() async {
    try {
      final now = DateTime.now();
      final date = '${now.year}년 ${now.month}월 ${now.day}일';

      final meals = await DatabaseHelper.instance.getMealsByDate(date);
      if (mounted) {
        setState(() {
          mealsInfo = meals;
        });
      }
    } catch (e) {
      print('Error loading meals: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('식사 기록을 불러오는데 실패했습니다')),
        );
      }
    }
  }

  Future<void> _loadMealsByDate(DateTime date) async {
    try {
      final formattedDate = '${date.year}년 ${date.month}월 ${date.day}일';
      final meals = await DatabaseHelper.instance.getMealsByDate(formattedDate);
      if (mounted) {
        setState(() {
          mealsInfo = meals;
        });
      }
    } catch (e) {
      print('Error loading meals: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('식사 기록을 불러오는데 실패했습니다')),
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

  Map<String, double> _calculateTotalNutrition() {
    Map<String, double> totalNutrition = {
      '칼로리': 0,
      '단백질': 0,
      '지방': 0,
      '식이섬유': 0,
      '나트륨': 0,
      '탄수화물': 0,
      '당류': 0,
    };

    for (var meal in mealsInfo) {
      try {
        final nutritionJson = jsonDecode(meal['nutrition']);
        final nutritionData =
            nutritionJson['nutrition'] as Map<String, dynamic>;

        nutritionData.forEach((key, value) {
          if (totalNutrition.containsKey(key)) {
            final numericValue = double.tryParse(
                  value.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0;
            totalNutrition[key] = totalNutrition[key]! + numericValue;
          }
        });
      } catch (e) {
        print('Error calculating nutrition: $e');
        print('Problematic meal data: ${meal['nutrition']}');
      }
    }
    return totalNutrition;
  }

  String get formattedDate =>
      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일';

  @override
  Widget build(BuildContext context) {
    final totalNutrition = _calculateTotalNutrition();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Text(
                        '📅',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: CalendarScreen(
                              onDateSelected: (selectedDate) {
                                setState(() {
                                  _selectedDate = selectedDate;
                                });
                                _loadMealsByDate(selectedDate);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    if (mealsInfo.isNotEmpty) ...[
                      ...mealsInfo.asMap().entries.map((entry) {
                        final index = entry.key;
                        final meal = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () {
                              // 이미지 클릭시 MealDetailPage로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealDetailScreen(
                                    meal: meal,
                                    changeInfo: _updateNutrition,
                                  ),
                                ),
                              );
                            },
                            child: _buildMealItem(
                              meal['type'] ?? '식사이름',
                              meal['time'] ?? '시간',
                              meal['imagePath'] ?? '',
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    _plusItem(context),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 섭취한 총 영양소',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    NutritionInfoGrid(
                      nutrition: {
                        '칼로리':
                            '${totalNutrition['칼로리']?.toStringAsFixed(1)}kcal',
                        '단백질': '${totalNutrition['단백질']?.toStringAsFixed(1)}g',
                        '지방': '${totalNutrition['지방']?.toStringAsFixed(1)}g',
                        '식이섬유':
                            '${totalNutrition['식이섬유']?.toStringAsFixed(1)}g',
                        '나트륨': '${totalNutrition['나트륨']?.toStringAsFixed(1)}mg',
                        '탄수화물':
                            '${totalNutrition['탄수화물']?.toStringAsFixed(1)}g',
                        '당류': '${totalNutrition['당류']?.toStringAsFixed(1)}mg',
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealItem(String title, String time, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath.isNotEmpty
              ? Image.file(
                  File(imagePath),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey[300],
                ),
        ),
        const SizedBox(height: 4),
        Text(title),
        Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _plusItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMealScreen(),
              ),
            ).then((_) => _loadTodayMeals());
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 120,
              width: 120,
              color: Colors.grey[300],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '추가',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 41),
      ],
    );
  }

  String _getSuffix(String key) {
    switch (key) {
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
