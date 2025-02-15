import 'package:flutter/material.dart';
import '../widgets/nutrition_info.dart';
import '../widgets/long_button.dart';

class SaveMealScreen extends StatelessWidget {
  const SaveMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                const SizedBox(height: 8),
                const Text(
                  '저녁 PM 06:49',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: [
                        // 세로 구분선
                        Center(
                          child: Container(
                            width: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                        // 두 개의 버튼을 Row로 배치
                        Row(
                          children: [
                            Expanded(
                              child: _buildOptionButton(
                                context,
                                icon: Icons.photo_library_outlined,
                                title: '갤러리에서 선택',
                                subtitle: '사진 선택하기',
                                onTap: () {
                                  // TODO: 갤러리 실행
                                },
                                alignment: Alignment.center,
                              ),
                            ),
                            Expanded(
                              child: _buildOptionButton(
                                context,
                                icon: Icons.camera_alt_outlined,
                                title: '사진 촬영',
                                subtitle: '카메라로 촬영하기',
                                onTap: () {
                                  // TODO: 카메라 실행
                                },
                                alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const ExpandableNutritionItem(
                  title: '음식이름',
                  amount: '0kcal',
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.edit),
                    hintText: '세부 설명 추가',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 16),
                const LongButton(
                  text: '분석',
                  emoji: '😋',
                ),
                const SizedBox(height: 16),
                const LongButton(
                  text: '분석없이저장',
                  emoji: '🍴',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Alignment alignment,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          alignment: alignment,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(icon, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
