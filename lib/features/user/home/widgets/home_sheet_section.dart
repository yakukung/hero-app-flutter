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
    required this.onShowAll,
  });

  final String title;
  final List<SheetModel> sheets;
  final ValueChanged<SheetModel> onOpenSheet;
  final ValueChanged<SheetModel> onFavoriteTap;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onShowAll,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'SukhumvitSet',
                  ),
                ),
                child: const Text('แสดงทั้งหมด'),
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
            crossAxisAlignment: CrossAxisAlignment.end,
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
                    featuredRank: index < 3 ? index + 1 : null,
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
