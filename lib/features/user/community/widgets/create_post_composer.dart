import 'package:flutter/material.dart';

class CreatePostComposer extends StatelessWidget {
  const CreatePostComposer({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 8,
      decoration: const InputDecoration(
        hintText: 'คุณกำลังคิดอะไรอยู่...',
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
