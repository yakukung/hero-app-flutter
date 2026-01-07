import 'package:flutter/material.dart';

class SearchSheetBox extends StatelessWidget {
  const SearchSheetBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 360,
      decoration: BoxDecoration(
        color: const Color(0xFFD6E3FF),
        borderRadius: BorderRadius.circular(45),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'เลือกค้นหาชื่อชีต\nที่คุณต้องการได้เลย',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ค้นหาชื่อชีต',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFFB2B2B2),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A5DB9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {},
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
