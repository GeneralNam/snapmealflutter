import 'package:flutter/material.dart';
import '../widgets/nutrition_info.dart';
import '../database/database_helper.dart';
import 'dart:convert';
import '../widgets/long_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditing = false;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  Map<String, String> _nutritionGoals = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper.instance.getSettings();
    setState(() {
      _heightController.text = settings['height'];
      _weightController.text = settings['weight'];
      _targetWeightController.text = settings['target_weight'];
      _nutritionGoals =
          Map<String, String>.from(jsonDecode(settings['nutrition_goals']));
    });
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper.instance.saveSettings(
      height: _heightController.text,
      weight: _weightController.text,
      targetWeight: _targetWeightController.text,
      nutritionGoals: _nutritionGoals,
    );
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _updateNutritionGoals(Map<String, String> newGoals) {
    setState(() {
      _nutritionGoals = newGoals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '개인설정',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isEditing)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: const Text(
                              '✏️',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildInfoItem(
                    icon: Icons.height,
                    title: '키',
                    controller: _heightController,
                    suffix: 'cm',
                  ),
                  _buildInfoItem(
                    icon: Icons.monitor_weight_outlined,
                    title: '몸무게',
                    controller: _weightController,
                    suffix: 'kg',
                  ),
                  _buildInfoItem(
                    icon: Icons.fitness_center,
                    title: '희망 몸무게',
                    controller: _targetWeightController,
                    suffix: 'kg',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '하루 섭취 영양소 목표',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        NutritionInfoGrid(
                          nutrition: _nutritionGoals,
                          isEditing: _isEditing,
                          onNutritionChanged: _updateNutritionGoals,
                        ),
                      ],
                    ),
                  ),
                  if (_isEditing) const SizedBox(height: 80),
                ],
              ),
            ),
            if (_isEditing)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: LongButton(
                  text: '완료',
                  emoji: '✅',
                  onPressed: _saveSettings,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (_isEditing) ...[
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffix: Text(suffix),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            Text(
              '${controller.text}$suffix',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
