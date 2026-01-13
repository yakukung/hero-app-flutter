import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? selectedSubject;
  String? selectedPrice;
  final List<String> subjects = [
    'วิทยาศาสตร์',
    'คณิตศาสตร์',
    'ภาษาคอมพิวเตอร์',
    'ภาษาอังกฤษ',
    'เนื้อหาทั่วไป',
  ];
  final List<String> prices = ['ฟรี', '50', '100', '150', '200', '250', '300'];
  List<String> keywords = [];

  int questionCount = 1;
  bool isQuestionsEnabled = false;
  final Map<int, int> _answerCounts = {0: 2};
  final Map<int, int> _correctAnswers = {};

  List<File> uploadedImages = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...uploadedImages.map(
            (image) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(image),
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
                          uploadedImages.remove(image);
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
          ),
          // Add Button
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 48, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldAnswer({
    required String hintText,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: subjects.map((subject) {
          final isSelected = subject == selectedSubject;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedSubject = subject),
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
                  subject,
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(thickness: 4, color: Color(0xFFE0E0E0)),
                  ),
                _buildTextFieldAnswer(hintText: 'คำถามที่ ${index + 1}'),
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
                  final label = String.fromCharCode(
                    65 + answerIndex,
                  ); // A, B, C...
                  final isCorrect = _correctAnswers[index] == answerIndex;

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

  void uploadSheet() async {
    print(_titleController.text);
    print(_descriptionController.text);
    print(selectedSubject);
    print(selectedPrice);
    print(keywords);
    if (isQuestionsEnabled == false) {
      print("ไม่มีคำถาม");
    } else {
      print(questionCount);
    }

    final storage = GetStorage();
    final String? token = storage.read('token');

    final response = await http.post(
      Uri.parse('$apiEndpoint/sheets/create'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': selectedPrice,
        'keywords': keywords,
      }),
    );
    print(response.body);
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
