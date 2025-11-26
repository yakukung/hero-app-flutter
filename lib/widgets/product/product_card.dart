import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onFavoriteTap;
  final Color? backgroundColor;

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 270,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFEEF0FD),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ? Image.network(
                        product.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.title ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'ผู้โพส ${product.author ?? "-"}',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'คะแนนชีท ${product.rating?.toStringAsFixed(1) ?? "-"}',
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                product.price ?? '-',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      Icons.star_rounded,
                      color: product.isFavorite ? Colors.amber : Colors.black12,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
