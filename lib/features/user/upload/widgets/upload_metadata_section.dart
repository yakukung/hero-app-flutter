import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/category_model.dart';
import 'package:hero_app_flutter/shared/widgets/upload/keyword_section.dart';
import 'package:hero_app_flutter/shared/widgets/upload/price_selector.dart';
import 'package:hero_app_flutter/shared/widgets/upload/subject_selector.dart';

class UploadMetadataSection extends StatelessWidget {
  const UploadMetadataSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.categories,
    required this.selectedSubject,
    required this.isLoadingCategories,
    required this.onSelectSubject,
    required this.keywords,
    required this.onAddKeyword,
    required this.onRemoveKeyword,
    required this.prices,
    required this.selectedPrice,
    required this.onSelectPrice,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<CategoryModel> categories;
  final String? selectedSubject;
  final bool isLoadingCategories;
  final ValueChanged<String> onSelectSubject;
  final List<String> keywords;
  final VoidCallback onAddKeyword;
  final ValueChanged<String> onRemoveKeyword;
  final List<String> prices;
  final String? selectedPrice;
  final ValueChanged<String> onSelectPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UploadSectionTitle(title: 'ชื่อหัวเรื่อง'),
        const SizedBox(height: 12),
        _UploadTextField(
          controller: titleController,
          hintText: 'ใส่ชื่อหัวเรื่องที่นี่',
        ),
        const SizedBox(height: 24),
        _UploadSectionTitle(title: 'รายละเอียด'),
        const SizedBox(height: 12),
        _UploadTextField(
          controller: descriptionController,
          hintText: 'ใส่รายละเอียดที่นี่',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _UploadSectionTitle(title: 'รายวิชา :'),
        const SizedBox(height: 12),
        SubjectSelector(
          categories: categories,
          selectedSubject: selectedSubject,
          isLoading: isLoadingCategories,
          onSelect: onSelectSubject,
        ),
        const SizedBox(height: 24),
        _UploadSectionTitle(title: 'คีย์เวิร์ด :'),
        const SizedBox(height: 12),
        KeywordSection(
          keywords: keywords,
          onAddKeyword: onAddKeyword,
          onRemoveKeyword: onRemoveKeyword,
        ),
        const SizedBox(height: 24),
        _UploadSectionTitle(title: 'ราคา :'),
        const SizedBox(height: 12),
        PriceSelector(
          prices: prices,
          selectedPrice: selectedPrice,
          onSelect: onSelectPrice,
        ),
      ],
    );
  }
}

class _UploadSectionTitle extends StatelessWidget {
  const _UploadSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class _UploadTextField extends StatelessWidget {
  const _UploadTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration:
            const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ).copyWith(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF7B7B7C),
                fontSize: 16,
              ),
            ),
      ),
    );
  }
}
