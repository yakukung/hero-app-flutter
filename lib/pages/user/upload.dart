import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';

class _UploadState {
  final double progress;
  final bool isUploading;
  final bool isSuccess;
  final String? errorMessage;

  _UploadState({
    this.progress = 0.0,
    this.isUploading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  _UploadState copyWith({
    double? progress,
    bool? isUploading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return _UploadState(
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? selectedSubject;
  String? selectedPrice;
  // State for dynamic categories
  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$apiEndpoint/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data['data']['categories'];
          _isLoadingCategories = false;
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  final List<String> prices = ['0', '50', '100', '150', '200', '250', '300'];
  List<String> keywords = [];

  int questionCount = 1;
  bool isQuestionsEnabled = false;

  // Existing state variables (Restored)
  final Map<int, int> _answerCounts = {0: 2};
  final Map<int, int> _correctAnswers = {};

  List<File> uploadedImages = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Controllers
  final Map<int, TextEditingController> _questionControllers = {};
  final Map<int, TextEditingController> _explanationControllers = {};
  final Map<int, Map<int, TextEditingController>> _answerControllers = {};

  @override
  void dispose() {
    _keywordController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _questionControllers.values) {
      controller.dispose();
    }
    for (var controller in _explanationControllers.values) {
      controller.dispose();
    }
    for (var questionMap in _answerControllers.values) {
      for (var controller in questionMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        uploadedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('รูปภาพชีต'),
                    const SizedBox(height: 12),
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('ชื่อหัวเรื่อง'),
                    const SizedBox(height: 12),
                    _buildTextFieldTitle(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('รายละเอียด'),
                    const SizedBox(height: 12),
                    _buildTextFieldDescription(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('รายวิชา :'),
                    const SizedBox(height: 12),
                    _buildSubjectSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('คีย์เวิร์ด :'),
                    const SizedBox(height: 12),
                    _buildKeywordSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('ราคา :'),
                    const SizedBox(height: 12),
                    _buildPriceSelector(),
                    const SizedBox(height: 32),
                    _buildQuestionSection(),
                    const SizedBox(height: 32),
                    _buildUploadButton(),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'อัปโหลดชีต',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'คุณสามารถอัปโหลดชีตของคุณได้ที่นี่',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey[200], thickness: 1),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 200,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final File item = uploadedImages.removeAt(oldIndex);
            uploadedImages.insert(newIndex, item);
          });
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                color: Colors.transparent,
                elevation: 0,
                child: child,
              );
            },
            child: child,
          );
        },
        footer: GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 140,
            height: 180,
            margin: const EdgeInsets.only(
              left: 10,
            ), // Margin left to separate from list
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 48, color: Colors.black54),
            ),
          ),
        ),
        children: [
          for (int index = 0; index < uploadedImages.length; index++)
            Container(
              key: ValueKey(uploadedImages[index].path),
              margin: const EdgeInsets.only(
                right: 0,
              ), // Use padding/gap logic if possible or keep consistent
              // ReorderableListView doesn't support separators easily.
              // To ensure consistent spacing, let's put margin on the RIGHT of items,
              // BUT check if footer margin logic lines up.
              // Footer is at the end.
              // Current logic: Items have margin right 16. Footer has margin right 16 (in previous code).
              // Let's change: Items have margin Right 16. Footer has Margin Left 0 if it directly follows?
              // The footer follows the last item. Last item has margin Right 16.
              // So footer will be 16px away from last item.
              // Footer itself doesn't need left margin if previous item has right margin.
              // But if list is empty? Footer is first. Then no margin left?
              // Let's use Padding in ListView for edge insets, and uniform margin.
              padding: const EdgeInsets.only(
                right: 16,
              ), // Padding inside container to create gap?
              // Or just Container width includes gap? No, we want visual gap.
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(uploadedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          uploadedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFieldAnswer({
    required String hintText,
    required TextEditingController controller,
    bool isCorrect = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0F5FF) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: isCorrect
            ? Border.all(color: const Color(0xFF2A5DB9), width: 1)
            : null,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldTitle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'ใส่ชื่อหัวเรื่องที่นี่',
          hintStyle: TextStyle(color: Color(0xFF7B7B7C), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldDescription() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'ใส่รายละเอียดที่นี่',
          hintStyle: TextStyle(color: Color(0xFF7B7B7C), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return const Text('ไม่พบข้อมูลรายวิชา');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final String name = category['name'];
          final isSelected = name == selectedSubject;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedSubject = name),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A5DB9)
                      : const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
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

  Widget _buildKeywordSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...keywords.map(
          (keyword) => Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2A5DB9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  keyword,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      keywords.remove(keyword);
                    });
                  },
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _showAddKeywordDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'เพิ่มคีย์เวิร์ด',
              style: TextStyle(color: Color(0xFF7B7B7C), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddKeywordDialog() {
    _keywordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มคีย์เวิร์ด'),
        content: TextField(
          controller: _keywordController,
          decoration: const InputDecoration(
            hintText: 'ใส่คีย์เวิร์ด',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_keywordController.text.isNotEmpty) {
                setState(() {
                  keywords.add(_keywordController.text);
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5DB9),
            ),
            child: const Text('เพิ่ม', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prices.map((price) {
          final isSelected = price == selectedPrice;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedPrice = price),
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
                    color: isSelected ? Colors.white : Color(0xFF7B7B7C),
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

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'คำถามท้ายบท',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Switch(
              value: isQuestionsEnabled,
              onChanged: (val) {
                setState(() {
                  isQuestionsEnabled = val;
                });
              },
              activeThumbColor: const Color(0xFF2A5DB9),
            ),
          ],
        ),
        if (isQuestionsEnabled) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'เลือกจำนวนคำถาม',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              _buildCounterControl('จำนวน', questionCount, (val) {
                if (val <= 10) {
                  setState(() {
                    questionCount = val;
                    if (!_answerCounts.containsKey(val - 1)) {
                      _answerCounts[val - 1] = 2;
                    }
                  });
                }
              }),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(questionCount, (index) {
            int currentAnswerCount = _answerCounts[index] ?? 2;

            // Get controllers
            if (!_questionControllers.containsKey(index)) {
              _questionControllers[index] = TextEditingController();
            }
            if (!_explanationControllers.containsKey(index)) {
              _explanationControllers[index] = TextEditingController();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(thickness: 4, color: Color(0xFFE0E0E0)),
                  ),
                const Text(
                  'คำถาม',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTextFieldAnswer(
                  hintText: 'คำถามที่ ${index + 1}',
                  controller: _questionControllers[index]!,
                ),
                const SizedBox(height: 12),
                const Text(
                  'คำอธิบายเฉลย',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTextFieldAnswer(
                  hintText: 'ใส่คำอธิบาย (Optional)',
                  controller: _explanationControllers[index]!,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'เลือกจำนวนคำตอบ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    _buildCounterControl('จำนวน', currentAnswerCount, (val) {
                      if (val <= 6) {
                        setState(() {
                          _answerCounts[index] = val;
                        });
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(currentAnswerCount, (answerIndex) {
                  final label = String.fromCharCode(65 + answerIndex);
                  final isCorrect = _correctAnswers[index] == answerIndex;

                  if (!_answerControllers.containsKey(index)) {
                    _answerControllers[index] = {};
                  }
                  if (!_answerControllers[index]!.containsKey(answerIndex)) {
                    _answerControllers[index]![answerIndex] =
                        TextEditingController();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _correctAnswers[index] = answerIndex;
                            });
                          },
                          child: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? const Color(0xFF2A5DB9)
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextFieldAnswer(
                            hintText: 'ใส่คำตอบ',
                            controller:
                                _answerControllers[index]![answerIndex]!,
                            isCorrect: isCorrect,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ],
    );
  }

  Widget _buildCounterControl(
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 1) onChanged(value - 1);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-', style: TextStyle(fontSize: 18)),
                ),
              ),
              Container(width: 1, height: 16, color: Colors.grey[400]),
              GestureDetector(
                onTap: () {
                  onChanged(value + 1);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('+', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> uploadSheet() async {
    final storage = GetStorage();
    final String? token = storage.read('token');

    var uri = Uri.parse('$apiEndpoint/sheets/create');
    var request = http.MultipartRequest('POST', uri);

    // Headers
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // Fields
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    // Find category ID
    String categoryId = '';
    final selectedCategory = _categories.firstWhere(
      (cat) => cat['name'] == selectedSubject,
      orElse: () => null,
    );
    if (selectedCategory != null) {
      categoryId = selectedCategory['id'];
    }

    request.fields['category'] = categoryId;
    request.fields['keywords'] = jsonEncode(keywords);
    // Convert '0' to 'ฟรี' if needed by backend, or just send selectedPrice
    // Based on user edit, prices list has '0', logic below assumes backend handles it or we send as is.
    // If backend expects 'ฟรี' for 0, we might need a mapping.
    // Assuming sending what is in the list is fine for now.
    request.fields['price'] = selectedPrice ?? '';

    // Questions
    if (isQuestionsEnabled) {
      List<Map<String, dynamic>> questionsList = [];
      for (int i = 0; i < questionCount; i++) {
        List<Map<String, dynamic>> answersList = [];
        int answerCount = _answerCounts[i] ?? 2;

        for (int j = 0; j < answerCount; j++) {
          answersList.add({
            'index': j + 1,
            'answer_text': _answerControllers[i]?[j]?.text ?? '',
            'is_correct': _correctAnswers[i] == j,
          });
        }

        questionsList.add({
          'index': i + 1,
          'question_text': _questionControllers[i]?.text ?? '',
          'explanation': _explanationControllers[i]?.text ?? '',
          'answers': answersList,
        });
      }
      request.fields['questions'] = jsonEncode(questionsList);
    } else {
      request.fields['questions'] = '[]';
    }

    // Files (Images)
    for (var file in uploadedImages) {
      String mimeType = 'image/jpeg'; // Default
      if (file.path.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    // Progress Dialog
    if (!mounted) return;
    final ValueNotifier<_UploadState> stateNotifier = ValueNotifier(
      _UploadState(isUploading: true),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: ValueListenableBuilder<_UploadState>(
            valueListenable: stateNotifier,
            builder: (context, state, child) {
              if (state.isUploading) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'กำลังอัปโหลด...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: state.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2A5DB9),
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text('${(state.progress * 100).toStringAsFixed(0)}%'),
                  ],
                );
              } else if (state.isSuccess) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'อัปโหลดเสร็จสิ้น',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          // Optionally navigate to another tab or reset form here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A5DB9),
                        ),
                        child: const Text(
                          'ตกลง',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'เกิดข้อผิดพลาด',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          'ปิด',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );

    try {
      final progressRequest = ProgressMultipartRequest(
        'POST',
        uri,
        onProgress: (int bytes, int total) {
          final progress = bytes / total;
          stateNotifier.value = stateNotifier.value.copyWith(
            progress: progress,
          );
        },
      );

      progressRequest.headers.addAll(request.headers);
      progressRequest.fields.addAll(request.fields);
      progressRequest.files.addAll(request.files);

      final streamedResponse = await progressRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: true,
          progress: 1.0,
        );
      } else {
        print('Upload failed: ${response.statusCode}');
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: 'อัปโหลดล้มเหลว: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error uploading: $e');
      if (mounted) {
        stateNotifier.value = stateNotifier.value.copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: 'เกิดข้อผิดพลาด: $e',
        );
      }
    }
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          uploadSheet();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A5DB9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'อัปโหลดชีต',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ProgressMultipartRequest extends http.MultipartRequest {
  final void Function(int bytes, int total) onProgress;

  ProgressMultipartRequest(String method, Uri url, {required this.onProgress})
    : super(method, url);

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
