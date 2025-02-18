import 'package:flutter/material.dart';
import '../widgets/nutrition_info.dart';
import '../widgets/long_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SaveMealScreen extends ConsumerStatefulWidget {
  final String? initialTime;
  final bool showTimeInput;

  const SaveMealScreen({
    super.key,
    this.initialTime,
    this.showTimeInput = false,
  });

  @override
  ConsumerState<SaveMealScreen> createState() => _SaveMealScreenState();
}

class _SaveMealScreenState extends ConsumerState<SaveMealScreen> {
  String? _selectedImagePath;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _selectedType = '아침';
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
  Map<String, TextEditingController> _controllers = {};
  bool _isAnalyzed = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _timeController.text = widget.initialTime ?? '';
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {
      '칼로리': TextEditingController(text: '0'),
      '단백질': TextEditingController(text: '0'),
      '지방': TextEditingController(text: '0'),
      '식이섬유': TextEditingController(text: '0'),
      '나트륨': TextEditingController(text: '0'),
      '탄수화물': TextEditingController(text: '0'),
      '당류': TextEditingController(text: '0'),
    };
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

  void changeInfo(
      String foodName, String amount, Map<String, String> nutrition) {
    setState(() {
      _foodName = foodName;
      _amount = amount.contains('g') ? amount : '${amount}g';
      _nutrition = nutrition;
      print('changeInfo 호출됨:');
      print('foodName: $_foodName');
      print('amount: $_amount');
      print('nutrition: $_nutrition');
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _timeController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
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

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  Future<void> _saveMeal() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 선택해주세요')),
      );
      return;
    }

    try {
      final nutritionData = {
        'foodName': _foodName,
        'amount': _amount,
        'nutrition': _nutrition,
      };

      if (widget.showTimeInput) {
        // 일반 식사 기록 저장
        await DatabaseHelper.instance.saveMeal(
          date: _getFormattedDate(),
          time: _timeController.text,
          type: _selectedType,
          imagePath: _selectedImagePath!,
          description: _descriptionController.text,
          nutrition: jsonEncode(nutritionData),
        );
      } else {
        // 저장된 식사 템플릿으로 저장
        await DatabaseHelper.instance.saveMealTemplate(
          imagePath: _selectedImagePath!,
          description: _descriptionController.text,
          nutrition: jsonEncode(nutritionData),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.showTimeInput ? '식사가 저장되었습니다' : '식사 템플릿이 저장되었습니다'),
          ),
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

  Future<void> _analyzeImage() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 이미지를 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      var uri = Uri.parse('http://192.168.0.7:8000/analyze-image');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedImagePath!,
      ));

      request.fields['prompt'] = '''이 음식 사진을 분석해서 다음 형식의 JSON으로 응답해주세요:
{
  "foodName": "음식이름",
  "amount": "양(g/ml)",
  "nutrition": {
    "칼로리": "0kcal",
    "단백질": "0g",
    "지방": "0g",
    "식이섬유": "0g",
    "나트륨": "0mg",
    "탄수화물": "0g",
    "당류": "0mg"
  }
}''';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }

        var nutritionData = jsonDecode(data['result']);
        print('영양정보: $nutritionData'); // 디버깅용

        setState(() {
          _foodName = nutritionData['foodName'];
          _amount = nutritionData['amount'];
          Map<String, dynamic> rawNutrition = nutritionData['nutrition'];
          _nutrition = {
            '칼로리': rawNutrition['칼로리'],
            '단백질': rawNutrition['단백질'],
            '지방': rawNutrition['지방'],
            '식이섬유': rawNutrition['식이섬유'],
            '나트륨': rawNutrition['나트륨'],
            '탄수화물': rawNutrition['탄수화물'],
            '당류': rawNutrition['당류'],
          };
          _isAnalyzed = true;

          // changeInfo 호출하여 ExpandableNutritionItem 업데이트
          changeInfo(_foodName, _amount, _nutrition);
        });

        // 분석 완료 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('분석이 완료되었습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('Analysis error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('분석 중 오류가 발생했습니다.\n${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
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
                const SizedBox(height: 8),
                if (widget.showTimeInput) ...[
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
                          items: const ['아침', '점심', '저녁', '간식']
                              .map((String value) {
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
                ],
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
                ExpandableNutritionItem(
                  nutrition: _nutrition,
                  foodName: _foodName,
                  amount: _amount,
                  changeInfo: changeInfo,
                  isEditing: true,
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
                _isAnalyzed
                    ? LongButton(
                        text: '저장',
                        emoji: '💾',
                        onPressed: _saveMeal,
                      )
                    : Column(
                        children: [
                          LongButton(
                            text: '분석',
                            emoji: '😋',
                            onPressed: _isAnalyzing ? null : _analyzeImage,
                            child: _isAnalyzing
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          LongButton(
                            text: '분석없이저장',
                            emoji: '🍴',
                            onPressed: _saveMeal,
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

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required Color color,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              suffixText: suffix,
              suffixStyle: const TextStyle(fontSize: 12),
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            onChanged: (value) {
              // 숫자만 입력되도록 검증
              if (value.isNotEmpty) {
                final numericValue = double.tryParse(value);
                if (numericValue == null) {
                  controller.text = '0';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
