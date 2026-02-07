import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/sheet_model.dart';
import 'package:flutter_application_1/services/sheets.service.dart';
import 'package:flutter_application_1/services/posts_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/pages/user/sheet/preview_sheet.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  SheetModel? _selectedSheet;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _openSheetSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SheetSelectionModal(
        onSheetSelected: (sheet) {
          setState(() {
            _selectedSheet = sheet;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'สร้างโพสต์',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณาใส่ข้อความ')),
                );
                return;
              }

              final success = await PostsService.createPost(
                content: _contentController.text,
                sheetId: _selectedSheet?.id,
              );

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('สร้างโพสต์สำเร็จ')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('เกิดข้อผิดพลาดในการสร้างโพสต์'),
                  ),
                );
              }
            },
            child: const Text(
              'โพสต์',
              style: TextStyle(
                color: Color(0xFF2A5DB9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'คุณกำลังคิดอะไรอยู่...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_selectedSheet != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PreviewSheetPage(sheetId: _selectedSheet!.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _selectedSheet!.thumbnail.isNotEmpty
                              ? Image.network(
                                  _selectedSheet!.thumbnail,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedSheet!.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '฿${_selectedSheet!.price}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedSheet = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เพิ่มชีตลงในโพสต์ของคุณ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _openSheetSelection,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F0FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF2A5DB9),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'เลือกชีตสรุป',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SheetSelectionModal extends StatefulWidget {
  final Function(SheetModel) onSheetSelected;

  const SheetSelectionModal({super.key, required this.onSheetSelected});

  @override
  State<SheetSelectionModal> createState() => _SheetSelectionModalState();
}

class _SheetSelectionModalState extends State<SheetSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<SheetModel> _filteredSheets = [];

  @override
  void initState() {
    super.initState();
    // Fetch sheets when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sheetData = Provider.of<SheetData>(context, listen: false);
      sheetData.fetchSheets();
      _filteredSheets = sheetData.sheets;
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final sheetData = Provider.of<SheetData>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSheets = sheetData.sheets.where((sheet) {
        return sheet.title.toLowerCase().contains(query);
      }).toList();
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
                child: Consumer<SheetData>(
                  builder: (context, sheetData, child) {
                    if (sheetData.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Use _filteredSheets if search is active, otherwise all sheets (or update _filteredSheets in listen)
                    // Better to just use _filteredSheets which is initialized with all sheets
                    // But we need to update it if sheetData changes (e.g. initial load)
                    if (_filteredSheets.isEmpty &&
                        _searchController.text.isEmpty &&
                        sheetData.sheets.isNotEmpty) {
                      _filteredSheets = sheetData.sheets;
                    }

                    if (_filteredSheets.isEmpty) {
                      return Center(
                        child: Text(
                          sheetData.sheets.isEmpty
                              ? 'ไม่มีชีตสรุปในระบบ'
                              : 'ไม่พบชีตที่ค้นหา',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredSheets.length,
                      itemBuilder: (context, index) {
                        final sheet = _filteredSheets[index];
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '฿${sheet.price}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onTap: () => widget.onSheetSelected(sheet),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
