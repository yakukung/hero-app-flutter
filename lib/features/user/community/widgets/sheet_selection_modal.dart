import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/constants/app_colors.dart';
import 'package:hero_app_flutter/core/controllers/sheets_controller.dart';
import 'package:hero_app_flutter/core/models/sheet_model.dart';

class SheetSelectionModal extends StatefulWidget {
  const SheetSelectionModal({
    super.key,
    required this.onSheetSelected,
    this.sheetsController,
  });

  final ValueChanged<SheetModel> onSheetSelected;
  final SheetsController? sheetsController;

  @override
  State<SheetSelectionModal> createState() => _SheetSelectionModalState();
}

class _SheetSelectionModalState extends State<SheetSelectionModal> {
  late final SheetsController _sheetsController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _sheetsController = widget.sheetsController ?? Get.find<SheetsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetsController.fetchSheets();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อชีต...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final allSheets = _sheetsController.sheets.toList();
                  final filteredSheets = allSheets.where((sheet) {
                    return sheet.title.toLowerCase().contains(_query);
                  }).toList();

                  if (_sheetsController.isLoading.value && allSheets.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (filteredSheets.isEmpty) {
                    return Center(
                      child: Text(
                        allSheets.isEmpty
                            ? 'ไม่มีชีตสรุปในระบบ'
                            : 'ไม่พบชีตที่ค้นหา',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSheets.length,
                    itemBuilder: (context, index) {
                      final sheet = filteredSheets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: sheet.thumbnail.isNotEmpty
                                ? Image.network(
                                    sheet.thumbnail,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.description,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          title: Text(
                            sheet.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '฿${sheet.price}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onTap: () {
                            widget.onSheetSelected(sheet);
                            Get.back();
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
