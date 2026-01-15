import 'package:flutter/material.dart';

/// A widget that displays an image with pinch-to-zoom and double-tap zoom.
class ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<TransformationController>? onControllerCreated;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;

  const ZoomableImage({
    super.key,
    required this.imageUrl,
    required this.onScaleChanged,
    this.onControllerCreated,
    this.onInteractionStart,
    this.onInteractionEnd,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  final TransformationController _controller = TransformationController();
  Offset? _doubleTapPosition;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_notifyScaleChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onControllerCreated?.call(_controller);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_notifyScaleChange);
    _controller.dispose();
    super.dispose();
  }

  void _notifyScaleChange() {
    widget.onScaleChanged(_controller.value.getMaxScaleOnAxis());
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final currentScale = _controller.value.getMaxScaleOnAxis();

    if (currentScale > 1.1) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _doubleTapPosition ?? Offset.zero;
      const targetScale = 2.0;
      final x = -position.dx * (targetScale - 1);
      final y = -position.dy * (targetScale - 1);

      _controller.value = Matrix4.identity()
        ..translate(x, y)
        ..scale(targetScale);
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
          minScale: 0.25,
          maxScale: 8.0,
          interactionEndFrictionCoefficient: 0.00001,
          panEnabled: true,
          scaleEnabled: true,
          scaleFactor: 1000,
          onInteractionStart: (_) => widget.onInteractionStart?.call(),
          onInteractionEnd: (_) => widget.onInteractionEnd?.call(),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _buildLoader();
            },
            errorBuilder: (_, __, ___) => _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
      ),
    );
  }
}
