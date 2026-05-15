import 'dart:io';
import 'package:flutter/material.dart';

/// Widget for uploading and managing sheet images with reordering support
class ImageUploadSection extends StatelessWidget {
  final List<File> images;
  final VoidCallback onPickImage;
  final VoidCallback onPickPdf;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onRemove;

  const ImageUploadSection({
    super.key,
    required this.images,
    required this.onPickImage,
    required this.onPickPdf,
    required this.onReorder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        onReorder: onReorder,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                color: Colors.transparent,
                elevation: 0,
                child: child,
              );
            },
            child: child,
          );
        },
        footer: _buildAddButton(context),
        children: [
          for (int index = 0; index < images.length; index++)
            _buildImageCard(index),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      key: const Key('add_sheet_file_button'),
      onTap: () => _showPickFileSheet(context),
      child: Container(
        width: 140,
        height: 180,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 48, color: Colors.black54),
            SizedBox(height: 10),
            Text(
              'เพิ่มไฟล์',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickFileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                _buildPickOption(
                  key: const Key('pick_image_option'),
                  icon: Icons.add_photo_alternate_outlined,
                  title: 'รูปภาพ',
                  subtitle: 'เลือกรูปภาพชีตจากเครื่อง',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onPickImage();
                  },
                ),
                _buildPickOption(
                  key: const Key('pick_pdf_option'),
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'ไฟล์ PDF',
                  subtitle: 'แยก PDF เป็นรูปทีละหน้า',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onPickPdf();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickOption({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      key: key,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
      onTap: onTap,
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      key: ValueKey(images[index].path),
      margin: const EdgeInsets.only(right: 0),
      padding: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
