import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/product_model.dart';
import 'package:hero_app_flutter/shared/widgets/product/product_card.dart';

void main() {
  const cardKey = Key('product_card_under_test');

  Product buildProduct() {
    return Product(
      id: 'sheet-1',
      title: 'ชีตตัวอย่าง',
      author: 'ผู้สอน',
      rating: 4.7,
      price: 'ฟรี',
    );
  }

  Future<void> pumpProductCard(
    WidgetTester tester, {
    bool isFeatured = false,
    int? featuredRank,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProductCard(
              key: cardKey,
              product: buildProduct(),
              isFeatured: isFeatured,
              featuredRank: featuredRank,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uses standard card size by default', (tester) async {
    await pumpProductCard(tester);

    final cardBody = find.descendant(
      of: find.byKey(cardKey),
      matching: find.byType(ClipRRect),
    );
    expect(tester.getSize(cardBody), const Size(180, 270));
  });

  testWidgets('uses descending card sizes for featured ranks', (tester) async {
    await pumpProductCard(tester, featuredRank: 1);

    var cardBody = find.descendant(
      of: find.byKey(cardKey),
      matching: find.byType(ClipRRect),
    );
    expect(tester.getSize(cardBody), const Size(215, 320));

    await pumpProductCard(tester, featuredRank: 2);
    cardBody = find.descendant(
      of: find.byKey(cardKey),
      matching: find.byType(ClipRRect),
    );
    expect(tester.getSize(cardBody), const Size(205, 305));

    await pumpProductCard(tester, featuredRank: 3);
    cardBody = find.descendant(
      of: find.byKey(cardKey),
      matching: find.byType(ClipRRect),
    );
    expect(tester.getSize(cardBody), const Size(195, 292));
  });

  testWidgets('uses larger rating style for the first featured rank', (
    tester,
  ) async {
    await pumpProductCard(tester, featuredRank: 1);

    final cardBody = find.descendant(
      of: find.byKey(cardKey),
      matching: find.byType(ClipRRect),
    );
    expect(tester.getSize(cardBody), const Size(215, 320));

    final ratingIcon = tester.widget<Icon>(
      find.byIcon(Icons.emoji_events_rounded),
    );
    expect(ratingIcon.size, 19);

    final ratingText = tester.widget<Text>(find.text('4.7'));
    expect(ratingText.style?.fontSize, 16);
    expect(ratingText.style?.fontWeight, FontWeight.w800);
  });
}
