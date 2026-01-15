import 'package:flutter/material.dart';

/// Horizontal scrollable subject/category selector
class SubjectSelector extends StatelessWidget {
  final List<dynamic> categories;
  final String? selectedSubject;
  final bool isLoading;
  final Function(String) onSelect;

  const SubjectSelector({
    super.key,
    required this.categories,
    required this.selectedSubject,
    required this.isLoading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return const Text('ไม่พบข้อมูลรายวิชา');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final String name = category['name'];
          final isSelected = name == selectedSubject;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelect(name),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A5DB9)
                      : const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF7B7B7C),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
