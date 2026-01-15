import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/product_model.dart';

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
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        dynamic sheetData;
        if (jsonResponse.containsKey('data')) {
          if (jsonResponse['data'] is Map &&
              jsonResponse['data'].containsKey('sheet')) {
            sheetData = jsonResponse['data']['sheet'];
          } else {
            sheetData = jsonResponse['data'];
          }
        } else {
          sheetData = jsonResponse;
        }

        if (sheetData is List) {
          if (sheetData.isNotEmpty) {
            sheetData = sheetData.first;
          } else {
            throw Exception('Product not found');
          }
        }

        if (sheetData == null) throw Exception('No data returned');

        List<String> images = [];
        if (sheetData['files'] != null) {
          List<dynamic> files = List.from(sheetData['files']);

          // Sort by index (handle both int and String types)
          files.sort((a, b) {
            final indexA = int.tryParse(a['index']?.toString() ?? '0') ?? 0;
            final indexB = int.tryParse(b['index']?.toString() ?? '0') ?? 0;
            return indexA.compareTo(indexB);
          });

          log(
            'Sorted files by index: ${files.map((f) => f['index']).toList()}',
          );

          for (var file in files) {
            String path = file['thumbnail_path'] ?? file['original_path'];
            String fullUrl = '';
            if (!path.startsWith('http')) {
              final uri = Uri.parse(apiEndpoint);
              final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
              fullUrl = '$baseUrl/$path';
            } else {
              fullUrl = path;
            }
            images.add(fullUrl);
          }
        }

        List<String> limitedPreview = images.take(2).toList();
        String coverUrl = images.isNotEmpty ? images.first : '';
        String author = sheetData['author_name'] ?? 'Unknown';

        final productModel = Product(
          id: sheetData['id'],
          title: sheetData['title'],
          description: sheetData['description'] ?? '',
          price: sheetData['price'] ?? 'ฟรี',
          rating:
              double.tryParse(sheetData['rating']?.toString() ?? '0.0') ?? 0.0,
          author: author,
          imageUrl: coverUrl,
          isFavorite: false,
        );

        setState(() {
          product = productModel;
          previewImages = limitedPreview;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load product: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching product details: ${e.toString()}');
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _openReader() {
    if (previewImages.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetPreviewReader(
            images: previewImages,
            title: product?.title ?? 'Reading',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่มีตัวอย่างให้อ่าน')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Collapsing Header
                    SliverAppBar(
                      expandedHeight: 400.0,
                      pinned: true,
                      stretch: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              product?.isFavorite == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product?.isFavorite == true
                                  ? Colors.red
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (product != null) {
                                product = Product(
                                  id: product!.id,
                                  title: product!.title,
                                  description: product!.description,
                                  price: product!.price,
                                  rating: product!.rating,
                                  imageUrl: product!.imageUrl,
                                  author: product!.author,
                                  isFavorite: !(product!.isFavorite),
                                );
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: GestureDetector(
                          onTap: _openReader,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'sheet_image_${product?.id}',
                                child: product?.imageUrl != null
                                    ? Image.network(
                                        product!.imageUrl!
                                            .replaceAll('`', '')
                                            .trim(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image),
                                      ),
                              ),
                              Container(
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
                              ),
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'แตะเพื่อดูตัวอย่าง',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        transform: Matrix4.translationValues(0, -20, 0),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Row(
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
                                      double.tryParse(product?.price ?? '0') ==
                                              0
                                          ? 'ฟรี'
                                          : '${product?.price}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            double.tryParse(
                                                  product?.price ?? '0',
                                                ) ==
                                                0
                                            ? Colors.green
                                            : const Color(0xFF2A5DB9),
                                      ),
                                    ),
                                    if (double.tryParse(
                                          product?.price ?? '0',
                                        ) !=
                                        0)
                                      const Text(
                                        'บาท',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product?.author ?? 'ไม่ระบุ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
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
                            ),
                            const SizedBox(height: 32),
                            const Divider(height: 1),
                            const SizedBox(height: 24),
                            const Text(
                              'รายละเอียด',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Button
                Positioned(
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
                ),
              ],
            ),
    );
  }
}

// ============================================================================
// SHEET PREVIEW READER - Optimized for smooth zoom and pan
// ============================================================================

class SheetPreviewReader extends StatefulWidget {
  final List<String> images;
  final String title;

  const SheetPreviewReader({
    super.key,
    required this.images,
    required this.title,
  });

  @override
  State<SheetPreviewReader> createState() => _SheetPreviewReaderState();
}

class _SheetPreviewReaderState extends State<SheetPreviewReader> {
  int _currentPage = 0;
  bool _showControls = true;
  late PageController _pageController;

  // Track zoom state per page
  final Map<int, double> _scaleMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Initialize scale for all pages
    for (int i = 0; i < widget.images.length; i++) {
      _scaleMap[i] = 1.0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  bool get _isZoomedIn => (_scaleMap[_currentPage] ?? 1.0) > 1.1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Main PageView - Only scrollable when not zoomed
            PageView.builder(
              controller: _pageController,
              physics: _isZoomedIn
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _ZoomableImage(
                  imageUrl: widget.images[index],
                  onScaleChanged: (scale) {
                    setState(() {
                      _scaleMap[index] = scale;
                    });
                  },
                );
              },
            ),

            // Top Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              top: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 16,
                  left: 8,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${((_scaleMap[_currentPage] ?? 1.0) * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              bottom: _showControls ? 40 : -80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '${_currentPage + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ZOOMABLE IMAGE WIDGET - Isolated for clean state management
// ============================================================================

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<double> onScaleChanged;

  const _ZoomableImage({required this.imageUrl, required this.onScaleChanged});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _controller = TransformationController();
  Offset? _doubleTapPosition;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onScaleChanged(scale);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final currentScale = _controller.value.getMaxScaleOnAxis();

    if (currentScale > 1.1) {
      // Zoomed in -> reset to 1x
      _controller.value = Matrix4.identity();
    } else {
      // Zoom to 2x at the tap position
      final position = _doubleTapPosition ?? Offset.zero;
      const double scale = 2.0;

      // Calculate the focal point offset
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);

      _controller.value = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
