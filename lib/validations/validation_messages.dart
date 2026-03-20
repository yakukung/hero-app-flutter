class ValidationMessages {
  static const String usernameOrEmailRequired = 'กรุณากรอกชื่อผู้ใช้หรืออีเมล';
  static const String passwordRequired = 'กรุณากรอกรหัสผ่าน';
  static String passwordMinLength(int minLength) {
    return 'รหัสผ่านต้องมีอย่างน้อย $minLength ตัวอักษร';
  }

  static const String emailRequired = 'กรุณากรอกอีเมล';

  static const String incompleteInfoTitle = 'ข้อมูลไม่ครบถ้วน';
  static const String incompleteInfoMessage = 'กรุณากรอกข้อมูลให้ครบถ้วน';
  static const String duplicateEmailTitle = 'อีเมลซ้ำ';
  static const String duplicateEmailMessage = 'อีเมลใหม่ต้องไม่ซ้ำกับอีเมลเดิม';
  static const String invalidFormatTitle = 'รูปแบบไม่ถูกต้อง';
  static const String invalidEmailMessage = 'รูปแบบอีเมลไม่ถูกต้อง';

  static const String uploadImageRequired = 'กรุณาเลือกรูปภาพชีต';
  static const String uploadTitleRequired = 'กรุณาใส่ชื่อหัวเรื่อง';
  static const String uploadDescriptionRequired = 'กรุณาใส่รายละเอียด';
  static const String uploadSubjectRequired = 'กรุณาเลือกรายวิชา';
  static const String uploadPriceRequired = 'กรุณาเลือกราคา';
  static String uploadQuestionRequired(int index) {
    return 'กรุณาใส่คำถามที่ $index';
  }

  static String uploadCorrectAnswerRequired(int index) {
    return 'กรุณาเลือกคำตอบที่ถูกต้องสำหรับคำถามที่ $index';
  }

  static String uploadAnswerRequired(String label, int index) {
    return 'กรุณาใส่คำตอบ $label ในคำถามที่ $index';
  }
}
