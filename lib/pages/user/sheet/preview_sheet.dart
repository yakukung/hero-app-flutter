import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/sheet_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_application_1/services/sheets.service.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'sheet_reader.dart';
import 'quiz_page.dart';

class PreviewSheetPage extends StatefulWidget {
  final String sheetId;

  const PreviewSheetPage({super.key, required this.sheetId});

  @override
  State<PreviewSheetPage> createState() => _PreviewSheetPageState();
}

class _PreviewSheetPageState extends State<PreviewSheetPage> {
  SheetModel? sheet;
  bool isLoading = true;
  String errorMessage = '';
  List<String> previewImages = [];

  @override
  void initState() {
    super.initState();
    _fetchSheetDetails();
  }

  Future<void> _fetchSheetDetails() async {
    try {
      final gs = GetStorage();
      final String? token = gs.read('token')?.toString();

      final sheetData = context.read<SheetData>();
      if (token != null && sheetData.favoriteSheets.isEmpty) {
        await sheetData.fetchFavorites();
      }

      final response = await http.get(
        Uri.parse('$apiEndpoint/sheets/${widget.sheetId}'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        log('Sheet details response: ${response.body}');
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final dynamic data =
            jsonResponse['data']?['sheet'] ?? jsonResponse['data'];

        if (data == null) throw Exception('No data returned');

        final newSheet = SheetModel.fromJson(data is List ? data.first : data);
        final images =
            newSheet.files?.map((f) => f.fullOriginalUrl).toList() ?? [];
        final limitedPreview = images.take(2).toList();

        // Cross-reference with SheetData to ensure isFavorite is accurate
        final sheetData = context.read<SheetData>();
        final isFavorited = sheetData.favoriteSheets.any(
          (fav) => fav.id == newSheet.id,
        );

        setState(() {
          sheet = SheetModel(
            id: newSheet.id,
            authorId: newSheet.authorId,
            title: newSheet.title,
            description: newSheet.description,
            rating: newSheet.rating,
            price: newSheet.price,
            visibleFlag: newSheet.visibleFlag,
            statusFlag: newSheet.statusFlag,
            createdAt: newSheet.createdAt,
            createdBy: newSheet.createdBy,
            updatedAt: newSheet.updatedAt,
            updatedBy: newSheet.updatedBy,
            authorName: newSheet.authorName,
            authorAvatar: newSheet.authorAvatar,
            files: newSheet.files,
            questions: newSheet.questions,
            categoryIds: newSheet.categoryIds,
            keywordIds: newSheet.keywordIds,
            isPurchased: newSheet.isPurchased,
            isFavorite: isFavorited,
          );
          previewImages = limitedPreview;
          isLoading = false;
        });
      } else {
        _setError('Failed to load sheet: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching sheet details: $e');
      _setError('Error: $e');
    }
  }

  void _setError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _openReader({bool fullVersion = false}) {
    if (previewImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่มีเนื้อหาให้อ่าน')));
      return;
    }

    // In a real app, fullVersion would fetch all images
    final imagesToRead = fullVersion
        ? (sheet?.files?.map((f) => f.fullOriginalUrl).toList() ??
              previewImages)
        : previewImages;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SheetPreviewReader(
          images: imagesToRead,
          title: fullVersion
              ? '${sheet?.title ?? 'Reading'} (ฉบับเต็ม)'
              : sheet?.title ?? 'Reading',
        ),
      ),
    );
  }

  void _buySheet() {
    // Show payment dialog or navigate to payment page
    showCustomDialog(
      title: 'ยืนยันการซื้อ',
      message: 'คุณต้องการซื้อ "${sheet?.title}" ในราคา ${sheet?.price} บาท?',
      isConfirm: true,
      onOk: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ระบบชำระเงินกำลังจะมาเร็วๆ นี้')),
        );
      },
    );
  }

  void _openQuiz() {
    if (sheet?.questions == null || sheet!.questions!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('หน้านี้ยังไม่มีโจทย์ท้ายบท')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          id: sheet!.id,
          title: 'โจทย์ท้ายบท: ${sheet?.title}',
          questions: sheet!.questions!,
        ),
      ),
    );
  }

  void _toggleFavorite() {
    if (sheet == null) return;

    final isCurrentlyFavorite = sheet!.isFavorite;
    final sheetData = context.read<SheetData>();

    showCustomDialog(
      title: isCurrentlyFavorite ? 'นำออกจากรายการโปรด' : 'เพิ่มเป็นรายการโปรด',
      message: isCurrentlyFavorite
          ? 'คุณต้องการลบจากรายการโปรดไหม'
          : 'คุณยืนยันที่จะเพิ่มเป็นรายการโปรดไหม',
      isConfirm: true,
      onOk: () async {
        bool success;
        if (isCurrentlyFavorite) {
          success = await sheetData.removeFavorite(sheet!.id);
        } else {
          success = await sheetData.addFavorite(sheet!.id);
        }

        if (mounted) {
          if (success) {
            setState(() {
              sheet = SheetModel(
                id: sheet!.id,
                authorId: sheet!.authorId,
                title: sheet!.title,
                description: sheet!.description,
                rating: sheet!.rating,
                price: sheet!.price,
                visibleFlag: sheet!.visibleFlag,
                statusFlag: sheet!.statusFlag,
                createdAt: sheet!.createdAt,
                createdBy: sheet!.createdBy,
                updatedAt: sheet!.updatedAt,
                updatedBy: sheet!.updatedBy,
                authorName: sheet!.authorName,
                authorAvatar: sheet!.authorAvatar,
                files: sheet!.files,
                questions: sheet!.questions,
                categoryIds: sheet!.categoryIds,
                keywordIds: sheet!.keywordIds,
                isPurchased: sheet!.isPurchased,
                isFavorite: !isCurrentlyFavorite,
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isCurrentlyFavorite
                      ? 'ลบจากรายการโปรดแล้ว'
                      : 'เพิ่มเป็นรายการโปรดแล้ว',
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(body: Center(child: Text(errorMessage)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(slivers: [_buildHeader(), _buildContent()]),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildCircleButton(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _buildCircleButton(
          icon: (sheet?.isFavorite ?? false)
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          iconColor: (sheet?.isFavorite ?? false) ? Colors.amber : Colors.white,
          onPressed: _toggleFavorite,
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeaderBackground(),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return IconButton(
      icon: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildHeaderBackground() {
    return GestureDetector(
      onTap: () => _openReader(fullVersion: sheet?.isPurchased ?? false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'sheet_image_${sheet?.id}',
            child: sheet?.thumbnail != null && sheet!.thumbnail.isNotEmpty
                ? Image.network(
                    sheet!.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          _buildGradientOverlay(),
          _buildPreviewHint(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 60),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.35),
            Colors.transparent,
            Colors.black.withOpacity(0.15),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHint() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'แตะเพื่อดูตัวอย่าง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final price = sheet?.price ?? 0;
    final isFree = price == 0;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        transform: Matrix4.translationValues(0, -20, 0),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildTitleRow(isFree),
            const SizedBox(height: 16),
            _buildAuthorRow(),
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 24),
            _buildDescription(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitleRow(bool isFree) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            sheet?.title ?? 'No Title',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isFree ? 'ฟรี' : '${sheet?.price}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isFree ? Colors.green : const Color(0xFF2A5DB9),
              ),
            ),
            if (!isFree)
              const Text(
                'บาท',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 18, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Text(
          sheet?.authorName ?? 'ไม่ระบุ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC107),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${sheet?.rating ?? 0.0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รายละเอียด',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          sheet?.description ?? 'ไม่มีรายละเอียด',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final price = sheet?.price ?? 0;
    final isFree = price == 0;
    final isPurchased = sheet?.isPurchased ?? false;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 40,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: (isFree || isPurchased)
            ? _buildPurchasedButtons()
            : _buildPreviewAndBuyButtons(),
      ),
    );
  }

  Widget _buildPurchasedButtons() {
    final hasQuestions =
        sheet?.questions != null && sheet!.questions!.isNotEmpty;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: ElevatedButton(
            onPressed: () => _openReader(fullVersion: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5DB9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'อ่านฉบับเต็ม',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasQuestions) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: OutlinedButton(
              onPressed: _openQuiz,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2A5DB9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ทำโจทย์บทนี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A5DB9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewAndBuyButtons() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: OutlinedButton(
            onPressed: () => _openReader(fullVersion: false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2A5DB9)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'เริ่มอ่านตัวอย่าง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A5DB9),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: ElevatedButton(
            onPressed: _buySheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5DB9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'ซื้อ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
