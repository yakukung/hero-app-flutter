import 'package:flutter/material.dart';

/// Circular price selector widget
class PriceSelector extends StatelessWidget {
  final List<String> prices;
  final String? selectedPrice;
  final Function(String) onSelect;

  const PriceSelector({
    super.key,
    required this.prices,
    required this.selectedPrice,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prices.map((price) {
          final isSelected = price == selectedPrice;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelect(price),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A5DB9)
                      : const Color(0xFFF5F5F7),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF7B7B7C),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
