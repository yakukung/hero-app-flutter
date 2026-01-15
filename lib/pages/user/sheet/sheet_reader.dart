import 'package:flutter/material.dart';
import 'widgets/zoomable_image.dart';

/// Full screen image viewer with zoom controls and page navigation.
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
  bool _isScaling = false;
  late PageController _pageController;

  final Map<int, double> _scaleMap = {};
  final Map<int, TransformationController> _controllerMap = {};

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    for (int i = 0; i < widget.images.length; i++) {
      _scaleMap[i] = 1.0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get _isZoomedIn => (_scaleMap[_currentPage] ?? 1.0) > 1.1;
  bool get _shouldDisablePageScroll => _isZoomedIn || _isScaling;
  double get _currentScale => _scaleMap[_currentPage] ?? 1.0;
  int get _zoomPercent => (_currentScale * 100).toInt();

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _zoomIn() {
    final controller = _controllerMap[_currentPage];
    if (controller == null) return;

    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale + 0.5).clamp(0.25, 8.0);
    _applyZoom(controller, currentScale, newScale);
  }

  void _zoomOut() {
    final controller = _controllerMap[_currentPage];
    if (controller == null) return;

    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale - 0.5).clamp(0.25, 8.0);

    if (newScale <= 1.0) {
      controller.value = Matrix4.identity();
    } else {
      _applyZoom(controller, currentScale, newScale);
    }
  }

  void _resetZoom() {
    _controllerMap[_currentPage]?.value = Matrix4.identity();
  }

  void _applyZoom(TransformationController controller, double from, double to) {
    final screenSize = MediaQuery.of(context).size;
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final x = -center.dx * (to / from - 1);
    final y = -center.dy * (to / from - 1);

    controller.value = Matrix4.identity()
      ..translate(x, y)
      ..scale(to);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [_buildPageView(), _buildTopBar(), _buildBottomBar()],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      physics: _shouldDisablePageScroll
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      itemCount: widget.images.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (_, index) => ZoomableImage(
        imageUrl: widget.images[index],
        onScaleChanged: (scale) => setState(() => _scaleMap[index] = scale),
        onControllerCreated: (c) => _controllerMap[index] = c,
        onInteractionStart: () => setState(() => _isScaling = true),
        onInteractionEnd: () => setState(() => _isScaling = false),
      ),
    );
  }

  Widget _buildTopBar() {
    return AnimatedPositioned(
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
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: _showControls ? 40 : -100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildZoomButton(Icons.remove_rounded, _zoomOut),
              const SizedBox(width: 16),
              _buildZoomPercentage(),
              const SizedBox(width: 16),
              _buildZoomButton(Icons.add_rounded, _zoomIn),
              const SizedBox(width: 24),
              _buildPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildZoomPercentage() {
    return GestureDetector(
      onTap: _resetZoom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$_zoomPercent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentPage + 1} / ${widget.images.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
