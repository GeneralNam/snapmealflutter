import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/nutrition_info.dart';

class TextInputScreen extends ConsumerStatefulWidget {
  const TextInputScreen({super.key});

  @override
  ConsumerState<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends ConsumerState<TextInputScreen> {
  String _foodName = '음식명';
  String _amount = '0인분';
  Map<String, String> _nutrition = {
    '칼로리': '0kcal',
    '단백질': '0g',
    '지방': '0g',
    '식이섬유': '0g',
    '나트륨': '0mg',
    '탄수화물': '0g',
    '당류': '0mg',
  };

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2025년 2월 8일',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '저녁 PM 06:49',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ExpandableNutritionItem(
                  nutrition: _nutrition,
                  foodName: _foodName,
                  amount: _amount,
                  changeInfo: _updateNutrition,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: '세부 설명 추가',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF8E7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '😋',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
