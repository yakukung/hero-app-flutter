import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/features/user/search/search_results_page.dart';
import 'package:flutter_application_1/constants/app_colors.dart';

class SearchSheetBox extends StatefulWidget {
  const SearchSheetBox({super.key});

  @override
  State<SearchSheetBox> createState() => _SearchSheetBoxState();
}

class _SearchSheetBoxState extends State<SearchSheetBox> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Get.to(() => SearchResultsPage(searchQuery: query));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _onSearch(),
                        decoration: const InputDecoration(
                          hintText: 'ค้นหาชื่อชีต',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFFB2B2B2),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _onSearch,
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
