import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'sheet_reader.dart';

class PreviewSheetPage extends StatefulWidget {
  final String productId;

  const PreviewSheetPage({super.key, required this.productId});

  @override
  State<PreviewSheetPage> createState() => _PreviewSheetPageState();
}

class _PreviewSheetPageState extends State<PreviewSheetPage> {
  Product? product;
  bool isLoading = true;
  String errorMessage = '';
  List<String> previewImages = [];

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/sheets/${widget.productId}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final sheetData = _extractSheetData(jsonResponse);

        if (sheetData == null) throw Exception('No data returned');

        final images = _extractImages(sheetData);
        final limitedPreview = images.take(2).toList();

        setState(() {
          product = Product(
            id: sheetData['id'],
            title: sheetData['title'],
            description: sheetData['description'] ?? '',
            price: sheetData['price'] ?? 'ฟรี',
            rating:
                double.tryParse(sheetData['rating']?.toString() ?? '0.0') ??
                0.0,
            author: sheetData['author_name'] ?? 'Unknown',
            imageUrl: images.isNotEmpty ? images.first : '',
            isFavorite: false,
          );
          previewImages = limitedPreview;
          isLoading = false;
        });
      } else {
        _setError('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching product details: $e');
      _setError('Error: $e');
    }
  }

  dynamic _extractSheetData(Map<String, dynamic> json) {
    dynamic data;
    if (json.containsKey('data')) {
      if (json['data'] is Map && json['data'].containsKey('sheet')) {
        data = json['data']['sheet'];
      } else {
        data = json['data'];
      }
    } else {
      data = json;
    }

    if (data is List) {
      return data.isNotEmpty ? data.first : null;
    }
    return data;
  }

  List<String> _extractImages(dynamic sheetData) {
    if (sheetData['files'] == null) return [];

    final files = List<dynamic>.from(sheetData['files'])
      ..sort((a, b) {
        final indexA = int.tryParse(a['index']?.toString() ?? '0') ?? 0;
        final indexB = int.tryParse(b['index']?.toString() ?? '0') ?? 0;
        return indexA.compareTo(indexB);
      });

    log('Sorted files by index: ${files.map((f) => f['index']).toList()}');

    return files.map<String>((file) {
      final path = file['thumbnail_path'] ?? file['original_path'] ?? '';
      if (path.startsWith('http')) return path;

      final uri = Uri.parse(apiEndpoint);
      return '${uri.scheme}://${uri.host}:${uri.port}/$path';
    }).toList();
  }

  void _setError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _openReader() {
    if (previewImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่มีตัวอย่างให้อ่าน')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SheetPreviewReader(
          images: previewImages,
          title: product?.title ?? 'Reading',
        ),
      ),
    );
  }

  void _toggleFavorite() {
    if (product == null) return;

    setState(() {
      product = Product(
        id: product!.id,
        title: product!.title,
        description: product!.description,
        price: product!.price,
        rating: product!.rating,
        imageUrl: product!.imageUrl,
        author: product!.author,
        isFavorite: !product!.isFavorite,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(body: Center(child: Text(errorMessage)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(slivers: [_buildHeader(), _buildContent()]),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildCircleButton(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _buildCircleButton(
          icon: product?.isFavorite == true
              ? Icons.favorite
              : Icons.favorite_border,
          iconColor: product?.isFavorite == true ? Colors.red : Colors.white,
          onPressed: _toggleFavorite,
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeaderBackground(),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildHeaderBackground() {
    return GestureDetector(
      onTap: _openReader,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'sheet_image_${product?.id}',
            child: product?.imageUrl != null
                ? Image.network(
                    product!.imageUrl!.replaceAll('`', '').trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          _buildGradientOverlay(),
          _buildPreviewHint(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.transparent,
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHint() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.fullscreen, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'แตะเพื่อดูตัวอย่าง',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final price = double.tryParse(product?.price ?? '0') ?? 0;
    final isFree = price == 0;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        transform: Matrix4.translationValues(0, -20, 0),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildTitleRow(isFree),
            const SizedBox(height: 16),
            _buildAuthorRow(),
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 24),
            _buildDescription(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitleRow(bool isFree) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product?.title ?? 'No Title',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isFree ? 'ฟรี' : '${product?.price}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isFree ? Colors.green : const Color(0xFF2A5DB9),
              ),
            ),
            if (!isFree)
              const Text(
                'บาท',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 18, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Text(
          product?.author ?? 'ไม่ระบุ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC107),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${product?.rating ?? 0.0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รายละเอียด',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          product?.description ?? 'ไม่มีรายละเอียด',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 40,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ElevatedButton(
          onPressed: _openReader,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A5DB9),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'เริ่มอ่านตัวอย่าง',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
