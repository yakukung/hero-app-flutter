import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/product_model.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';
import 'package:hero_app_flutter/shared/widgets/product/product_card.dart';

class HomeSheetSection extends StatelessWidget {
  const HomeSheetSection({
    super.key,
    required this.title,
    required this.sheets,
    required this.onOpenSheet,
    required this.onFavoriteTap,
  });

  final String title;
  final List<SheetModel> sheets;
  final ValueChanged<SheetModel> onOpenSheet;
  final ValueChanged<SheetModel> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const Text(
                'แสดงทั้งหมด',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            children: [
              for (int index = 0; index < sheets.length; index++)
                GestureDetector(
                  onTap: () => onOpenSheet(sheets[index]),
                  child: ProductCard(
                    product: Product(
                      id: sheets[index].id,
                      imageUrl: sheets[index].thumbnail,
                      title: sheets[index].title,
                      author: sheets[index].authorName ?? 'Unknown',
                      rating: sheets[index].rating ?? 0.0,
                      price:
                          sheets[index].price == 0 ||
                              sheets[index].price == null
                          ? 'ฟรี'
                          : '${sheets[index].price} บาท',
                      isFavorite: sheets[index].isFavorite,
                    ),
                    colorIndex: index,
                    onFavoriteTap: () => onFavoriteTap(sheets[index]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
