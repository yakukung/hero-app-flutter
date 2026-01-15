import 'package:flutter/material.dart';

/// Quiz question section widget with multiple questions and answers
class QuestionSection extends StatelessWidget {
  final bool isEnabled;
  final int questionCount;
  final Map<int, int> answerCounts;
  final Map<int, int> correctAnswers;
  final Map<int, TextEditingController> questionControllers;
  final Map<int, TextEditingController> explanationControllers;
  final Map<int, Map<int, TextEditingController>> answerControllers;
  final Function(bool) onToggle;
  final Function(int) onQuestionCountChanged;
  final Function(int questionIndex, int count) onAnswerCountChanged;
  final Function(int questionIndex, int answerIndex) onCorrectAnswerChanged;

  const QuestionSection({
    super.key,
    required this.isEnabled,
    required this.questionCount,
    required this.answerCounts,
    required this.correctAnswers,
    required this.questionControllers,
    required this.explanationControllers,
    required this.answerControllers,
    required this.onToggle,
    required this.onQuestionCountChanged,
    required this.onAnswerCountChanged,
    required this.onCorrectAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (isEnabled) ...[
          const SizedBox(height: 16),
          _buildQuestionCountSelector(),
          const SizedBox(height: 16),
          ...List.generate(questionCount, (index) => _buildQuestion(index)),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
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
          value: isEnabled,
          onChanged: onToggle,
          activeThumbColor: const Color(0xFF2A5DB9),
        ),
      ],
    );
  }

  Widget _buildQuestionCountSelector() {
    return Row(
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
        CounterControl(
          label: 'จำนวน',
          value: questionCount,
          onChanged: (val) {
            if (val <= 10) onQuestionCountChanged(val);
          },
        ),
      ],
    );
  }

  Widget _buildQuestion(int index) {
    final currentAnswerCount = answerCounts[index] ?? 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(thickness: 4, color: Color(0xFFE0E0E0)),
          ),
        const Text('คำถาม', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: 'คำถามที่ ${index + 1}',
          controller: questionControllers[index] ?? TextEditingController(),
        ),
        const SizedBox(height: 12),
        const Text(
          'คำอธิบายเฉลย',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: 'ใส่คำอธิบาย (Optional)',
          controller: explanationControllers[index] ?? TextEditingController(),
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
            CounterControl(
              label: 'จำนวน',
              value: currentAnswerCount,
              onChanged: (val) {
                if (val <= 6) onAnswerCountChanged(index, val);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(currentAnswerCount, (answerIndex) {
          return _buildAnswerRow(index, answerIndex);
        }),
      ],
    );
  }

  Widget _buildAnswerRow(int questionIndex, int answerIndex) {
    final label = String.fromCharCode(65 + answerIndex);
    final isCorrect = correctAnswers[questionIndex] == answerIndex;
    final controller =
        answerControllers[questionIndex]?[answerIndex] ??
        TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onCorrectAnswerChanged(questionIndex, answerIndex),
            child: Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? const Color(0xFF2A5DB9) : Colors.grey[500],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTextField(
              hintText: 'ใส่คำตอบ',
              controller: controller,
              isCorrect: isCorrect,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
}

/// Counter control widget for incrementing/decrementing values
class CounterControl extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const CounterControl({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                onTap: () => onChanged(value + 1),
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
}
