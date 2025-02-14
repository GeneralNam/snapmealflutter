import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/meal_detail_screen.dart';
import '../screens/saved_meals_screen.dart';
import '../screens/text_input_screen.dart';

class AddMealScreen extends ConsumerWidget {
  const AddMealScreen({super.key});

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (context.mounted && image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 가져오는데 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저녁 PM 06:49'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAddButton(
                context,
                icon: Icons.camera_alt,
                title: '촬영',
                subtitle: '카메라로 촬영',
                color: const Color(0xFFFCF2FF),
                onTap: () => _getImage(context, ImageSource.camera),
              ),
              const SizedBox(height: 16),
              _buildAddButton(
                context,
                icon: Icons.photo_library,
                title: '갤러리',
                subtitle: '갤러리에서 찾기',
                color: const Color(0xFFF2FFF5),
                onTap: () => _getImage(context, ImageSource.gallery),
              ),
              const SizedBox(height: 16),
              _buildAddButton(
                context,
                icon: Icons.restaurant_menu,
                title: '저장된 식사',
                subtitle: '저장된 식사 기록에서 선택',
                color: const Color(0xFFFFF8F2),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedMealsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAddButton(
                context,
                icon: Icons.text_fields,
                title: '텍스트로 입력',
                subtitle: '음식 정보를 텍스트로 입력',
                color: const Color(0xFFF2FBFF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TextInputScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
