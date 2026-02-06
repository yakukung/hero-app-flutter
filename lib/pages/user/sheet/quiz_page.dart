import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/question_model.dart';
import 'package:flutter_application_1/services/app_data.dart';
import 'package:flutter_application_1/widgets/custom_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class QuizPage extends StatefulWidget {
  final String id;
  final String title;
  final List<QuestionModel> questions;

  const QuizPage({
    super.key,
    required this.id,
    required this.title,
    required this.questions,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  Map<int, int?> _selectedAnswers = {};
  bool _showScore = false;
  bool _revealedAll = false;
  final _storage = GetStorage();

  String get _storageKey => 'quiz_progress_${widget.id}';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final saved = _storage.read(_storageKey);
    if (saved != null && saved is Map) {
      setState(() {
        _currentIndex = saved['currentIndex'] ?? 0;
        final answers = saved['selectedAnswers'] as Map?;
        if (answers != null) {
          _selectedAnswers = answers.map(
            (key, value) => MapEntry(int.parse(key.toString()), value as int?),
          );
        }
      });
    }
  }

  void _saveProgress() {
    final answersToSave = _selectedAnswers.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    _storage.write(_storageKey, {
      'currentIndex': _currentIndex,
      'selectedAnswers': answersToSave,
    });
  }

  void _clearProgress() {
    _storage.remove(_storageKey);
  }

  int get _score {
    int s = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final selectedIndex = _selectedAnswers[i];
      if (selectedIndex != null &&
          question.answers != null &&
          question.answers![selectedIndex].isCorrect) {
        s++;
      }
    }
    return s;
  }

  void _onAnswerSelected(int answerIndex) {
    if (_showScore || _revealedAll || _selectedAnswers[_currentIndex] != null)
      return;

    showCustomDialog(
      title: 'ยืนยันคำตอบ',
      message:
          'คุณยืนยันตอบตัวเลือกนี้แล้วใช่ไหม? (ตอบแล้วจะไม่สามารถกลับมาแก้ไขได้)',
      isConfirm: true,
      onOk: () {
        setState(() {
          _selectedAnswers[_currentIndex] = answerIndex;
        });
        _saveProgress();
      },
    );
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _saveProgress();
    } else {
      setState(() {
        _showScore = true;
      });
      _clearProgress();
    }
  }

  void _revealAllAnswers() {
    setState(() {
      _revealedAll = true;
      if (_showScore) {
        _showScore = false;
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Appdata>().user;
    final rName = user?.roleName?.toUpperCase() ?? '';
    final rId = user?.roleId ?? '';
    final isPremium =
        rName.contains('PREMIUM') ||
        rId == '019affa1-0872-78cb-b4ff-5376279dba2d';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: _showScore
                  ? _buildScoreScreen(isPremium)
                  : _buildQuizContent(isPremium),
            ),
            _buildFooter(isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ตอบคำถามท้ายบท',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'คำถามจากผู้สร้างชีทนี้',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(bool isPremium) {
    final question = widget.questions[_currentIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'คำถามที่ ${_currentIndex + 1}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(question.answers?.length ?? 0, (index) {
            final answer = question.answers![index];
            return _buildAnswerOption(index, answer);
          }),
          if (_revealedAll &&
              question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เฉลย/คำอธิบาย:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(question.explanation!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index, dynamic answer) {
    final label = String.fromCharCode(65 + index); // A, B, C, D
    final isSelected = _selectedAnswers[_currentIndex] == index;
    final isCorrect = answer.isCorrect;

    Color bgColor = const Color(0xFFF5F5F7);
    Color textColor = Colors.black;
    Color labelColor = Colors.black;
    double borderWidth = 0;
    Color borderColor = Colors.transparent;

    final hasSelected = _selectedAnswers[_currentIndex] != null;

    if (_revealedAll) {
      if (isCorrect) {
        bgColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        borderWidth = 1;
        labelColor = Colors.green;
      } else if (isSelected) {
        bgColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        borderWidth = 1;
        labelColor = Colors.red;
      }
    } else if (hasSelected && isSelected) {
      if (isCorrect) {
        bgColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        borderWidth = 1;
        labelColor = Colors.green;
      } else {
        bgColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        borderWidth = 1;
        labelColor = Colors.red;
      }
    } else if (isSelected) {
      bgColor = const Color(0xFF2A5DB9).withOpacity(0.1);
      borderColor = const Color(0xFF2A5DB9);
      borderWidth = 1;
      labelColor = const Color(0xFF2A5DB9);
    }

    return GestureDetector(
      onTap: () => _onAnswerSelected(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: borderWidth > 0
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                answer.answerText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreScreen(bool isPremium) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'สรุปคะแนนของคุณ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '$_score / ${widget.questions.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A5DB9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เก่งมาก! พยายามต่อไปนะ',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (isPremium) ...[
              const SizedBox(height: 48),
              SizedBox(
                width: 240,
                child: ElevatedButton.icon(
                  onPressed: _revealAllAnswers,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'ดูเฉลยละเอียดทุกข้อ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.amber.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isPremium) {
    final hasSelected = _selectedAnswers[_currentIndex] != null;
    final isLast = _currentIndex == widget.questions.length - 1;

    if (_showScore) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0F0F0),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'กลับหน้าเริ่มต้น',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: const Color(0xFFF0F0F0),
                    alignment: Alignment.center,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'ออกไปหน้าหลัก',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: (hasSelected || _revealedAll)
                    ? ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _revealedAll
                              ? Colors.amber[800]
                              : const Color(0xFF2A5DB9),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLast
                              ? (_revealedAll ? 'กลับหน้าสรุป' : 'ดูผลคะแนน')
                              : 'ข้อถัดไป',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
