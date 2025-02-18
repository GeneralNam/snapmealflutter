import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final String text;
  final String emoji;
  final VoidCallback? onPressed;
  final Widget? child;

  const LongButton({
    Key? key,
    required this.text,
    required this.emoji,
    this.onPressed,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed ?? null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF8E7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child ??
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
