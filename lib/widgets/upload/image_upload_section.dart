import 'dart:io';
import 'package:flutter/material.dart';

/// Widget for uploading and managing sheet images with reordering support
class ImageUploadSection extends StatelessWidget {
  final List<File> images;
  final VoidCallback onPickImage;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onRemove;

  const ImageUploadSection({
    super.key,
    required this.images,
    required this.onPickImage,
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
        footer: _buildAddButton(),
        children: [
          for (int index = 0; index < images.length; index++)
            _buildImageCard(index),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: 140,
        height: 180,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 48, color: Colors.black54),
        ),
      ),
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
