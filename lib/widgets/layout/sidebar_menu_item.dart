import 'package:flutter/material.dart';

class SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? badge;
  final bool highlight;
  final VoidCallback onTap;
  final Widget? trailing;

  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    this.badge,
    this.highlight = false,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color:
                highlight
                    ? const Color(0xFF2A5DB9)
                    : selected
                    ? Colors.grey.shade200
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                highlight
                    ? [
                      BoxShadow(
                        color: const Color(0xFF2A5DB9).withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    highlight
                        ? Colors.white
                        : selected
                        ? const Color(0xFF2A5DB9)
                        : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        highlight
                            ? Colors.white
                            : selected
                            ? const Color(0xFF2A5DB9)
                            : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: highlight ? Colors.white : const Color(0xFF2A5DB9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge.toString(),
                    style: TextStyle(
                      color: highlight ? const Color(0xFF2A5DB9) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
