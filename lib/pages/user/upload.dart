import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/enums.dart';
import 'package:flutter_application_1/services/sheet_upload_service.dart';
import 'package:flutter_application_1/widgets/upload/image_upload_section.dart';
import 'package:flutter_application_1/widgets/upload/keyword_section.dart';
import 'package:flutter_application_1/widgets/upload/price_selector.dart';
import 'package:flutter_application_1/widgets/upload/question_section.dart';
import 'package:flutter_application_1/widgets/upload/subject_selector.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // Form state
  String? selectedSubject;
  String? selectedPrice;
  List<String> keywords = [];
  List<File> uploadedImages = [];

  // Categories
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  // Price options
  final List<String> prices = ['0', '50', '100', '150', '200', '250', '300'];

  // Questions state
  int questionCount = 1;
  bool isQuestionsEnabled = false;
  final Map<int, int> _answerCounts = {0: 2};
  final Map<int, int> _correctAnswers = {};

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Map<int, TextEditingController> _questionControllers = {};
  final Map<int, TextEditingController> _explanationControllers = {};
  final Map<int, Map<int, TextEditingController>> _answerControllers = {};

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
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

  Future<void> _fetchCategories() async {
    try {
      final gs = GetStorage();
      final String? token = gs.read('token')?.toString();

      final response = await http.get(
        Uri.parse('$apiEndpoint/categories'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> categoryList = data['data']['categories'];
        if (!mounted) return;
        setState(() {
          _categories = categoryList
              .map((json) => CategoryModel.fromJson(json))
              .toList();
          _isLoadingCategories = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        uploadedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _ensureControllers(int questionIndex) {
    if (!_questionControllers.containsKey(questionIndex)) {
      _questionControllers[questionIndex] = TextEditingController();
    }
    if (!_explanationControllers.containsKey(questionIndex)) {
      _explanationControllers[questionIndex] = TextEditingController();
    }
    if (!_answerCounts.containsKey(questionIndex)) {
      _answerCounts[questionIndex] = 2;
    }

    final answerCount = _answerCounts[questionIndex] ?? 2;
    if (!_answerControllers.containsKey(questionIndex)) {
      _answerControllers[questionIndex] = {};
    }
    for (int i = 0; i < answerCount; i++) {
      if (!_answerControllers[questionIndex]!.containsKey(i)) {
        _answerControllers[questionIndex]![i] = TextEditingController();
      }
    }
  }

  List<Map<String, dynamic>> _buildQuestionsData() {
    if (!isQuestionsEnabled) return [];

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
    return questionsList;
  }

  String? _validateForm() {
    if (uploadedImages.isEmpty) {
      return 'กรุณาเลือกรูปภาพชีต';
    }
    if (_titleController.text.trim().isEmpty) {
      return 'กรุณาใส่ชื่อหัวเรื่อง';
    }
    if (_descriptionController.text.trim().isEmpty) {
      return 'กรุณาใส่รายละเอียด';
    }
    if (selectedSubject == null) {
      return 'กรุณาเลือกรายวิชา';
    }
    if (selectedPrice == null) {
      return 'กรุณาเลือกราคา';
    }

    if (isQuestionsEnabled) {
      for (int i = 0; i < questionCount; i++) {
        final questionText = _questionControllers[i]?.text.trim() ?? '';
        if (questionText.isEmpty) {
          return 'กรุณาใส่คำถามที่ ${i + 1}';
        }

        if (!_correctAnswers.containsKey(i)) {
          return 'กรุณาเลือกคำตอบที่ถูกต้องสำหรับคำถามที่ ${i + 1}';
        }
        final answerCount = _answerCounts[i] ?? 2;
        for (int j = 0; j < answerCount; j++) {
          final answerText = _answerControllers[i]?[j]?.text.trim() ?? '';
          if (answerText.isEmpty) {
            final label = String.fromCharCode(65 + j); // A, B, C, D...
            return 'กรุณาใส่คำตอบ $label ในคำถามที่ ${i + 1}';
          }
        }
      }
    }

    return null;
  }

  void _showValidationError(String message) {
    showCustomDialog(title: 'ข้อมูลไม่ครบถ้วน', message: message);
  }

  Future<void> _uploadSheet() async {
    final validationError = _validateForm();
    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    String categoryId = '';
    final selectedCategory = _categories.firstWhere(
      (cat) => cat.name == selectedSubject,
      orElse: () => CategoryModel(
        id: '',
        name: '',
        visibleFlag: false,
        statusFlag: StatusFlag.fromString('INACTIVE'),
      ),
    );
    if (selectedCategory.id.isNotEmpty) {
      categoryId = selectedCategory.id;
    }

    final data = SheetUploadData(
      title: _titleController.text,
      description: _descriptionController.text,
      categoryId: categoryId,
      keywords: keywords,
      price: selectedPrice ?? '',
      images: uploadedImages,
      questions: _buildQuestionsData(),
    );

    await SheetUploadService.uploadSheet(context: context, data: data);
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < questionCount; i++) {
      _ensureControllers(i);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
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
                      ImageUploadSection(
                        images: uploadedImages,
                        onPickImage: _pickImage,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) newIndex -= 1;
                            final item = uploadedImages.removeAt(oldIndex);
                            uploadedImages.insert(newIndex, item);
                          });
                        },
                        onRemove: (index) {
                          setState(() => uploadedImages.removeAt(index));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('ชื่อหัวเรื่อง'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'ใส่ชื่อหัวเรื่องที่นี่',
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('รายละเอียด'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'ใส่รายละเอียดที่นี่',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('รายวิชา :'),
                      const SizedBox(height: 12),
                      SubjectSelector(
                        categories: _categories,
                        selectedSubject: selectedSubject,
                        isLoading: _isLoadingCategories,
                        onSelect: (subject) {
                          setState(() => selectedSubject = subject);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('คีย์เวิร์ด :'),
                      const SizedBox(height: 12),
                      KeywordSection(
                        keywords: keywords,
                        onAddKeyword: () async {
                          final keyword = await KeywordSection.showAddDialog(
                            context,
                          );
                          if (keyword != null) {
                            if (!mounted) return;
                            setState(() => keywords.add(keyword));
                          }
                        },
                        onRemoveKeyword: (keyword) {
                          setState(() => keywords.remove(keyword));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('ราคา :'),
                      const SizedBox(height: 12),
                      PriceSelector(
                        prices: prices,
                        selectedPrice: selectedPrice,
                        onSelect: (price) {
                          setState(() => selectedPrice = price);
                        },
                      ),
                      const SizedBox(height: 32),
                      QuestionSection(
                        isEnabled: isQuestionsEnabled,
                        questionCount: questionCount,
                        answerCounts: _answerCounts,
                        correctAnswers: _correctAnswers,
                        questionControllers: _questionControllers,
                        explanationControllers: _explanationControllers,
                        answerControllers: _answerControllers,
                        onToggle: (enabled) {
                          setState(() => isQuestionsEnabled = enabled);
                        },
                        onQuestionCountChanged: (count) {
                          setState(() => questionCount = count);
                        },
                        onAnswerCountChanged: (questionIndex, count) {
                          setState(() => _answerCounts[questionIndex] = count);
                        },
                        onCorrectAnswerChanged: (questionIndex, answerIndex) {
                          setState(
                            () => _correctAnswers[questionIndex] = answerIndex,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildUploadButton(),
                      const SizedBox(height: 100),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF7B7B7C), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _uploadSheet,
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
