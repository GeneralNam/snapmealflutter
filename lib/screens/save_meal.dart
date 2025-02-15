import 'package:flutter/material.dart';
import '../widgets/nutrition_info.dart';
import '../widgets/long_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';

class SaveMealScreen extends StatefulWidget {
  const SaveMealScreen({super.key});

  @override
  State<SaveMealScreen> createState() => _SaveMealScreenState();
}

class _SaveMealScreenState extends State<SaveMealScreen> {
  String? _selectedImagePath;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 가져오는데 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _saveMealWithoutAnalysis() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 선택해주세요')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final date = '${now.year}년 ${now.month}월 ${now.day}일';
      final time =
          '저녁 PM ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      await DatabaseHelper.instance.saveMeal(
        date: date,
        time: time,
        imagePath: _selectedImagePath!,
        description: _descriptionController.text,
        nutrition: null,
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                  aspectRatio: 1,
                  child: _selectedImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOptionButton(
                                      context,
                                      icon: Icons.photo_library_outlined,
                                      title: '갤러리에서 선택',
                                      subtitle: '사진 선택하기',
                                      onTap: () =>
                                          _getImage(ImageSource.gallery),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildOptionButton(
                                      context,
                                      icon: Icons.camera_alt_outlined,
                                      title: '사진 촬영',
                                      subtitle: '카메라로 촬영하기',
                                      onTap: () =>
                                          _getImage(ImageSource.camera),
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
                  controller: _descriptionController,
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
                LongButton(
                  text: '분석없이저장',
                  emoji: '🍴',
                  onPressed: _saveMealWithoutAnalysis,
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
