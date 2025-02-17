import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../widgets/nutrition_info.dart';

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> mealsInfo;
  final Function(String, String, Map<String, String>) changeInfo;

  const MealDetailScreen({
    super.key,
    required this.mealsInfo,
    required this.changeInfo,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> nutritionData =
        jsonDecode(mealsInfo['nutrition'] ?? '{}');

    final Map<String, String> formattedNutrition =
        Map<String, String>.from(nutritionData['nutrition'] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 섹션
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
              child: mealsInfo['imagePath'].isNotEmpty
                  ? Image.file(
                      File(mealsInfo['imagePath']),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 식사 정보 섹션
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              mealsInfo['type'] ?? '식사이름',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              mealsInfo['time'] ?? '시간',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 영양 정보 섹션
        ExpandableNutritionItem(
          nutrition: formattedNutrition,
          foodName: nutritionData['foodName'] ?? '음식이름',
          amount: nutritionData['amount'] ?? '0g',
          changeInfo: changeInfo,
          isEditing: false,
        ),
      ],
    );
  }
}
