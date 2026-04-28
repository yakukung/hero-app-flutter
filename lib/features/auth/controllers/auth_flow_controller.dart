import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:hero_app_flutter/core/services/auth_service.dart';
import 'package:hero_app_flutter/core/session/app_session_coordinator.dart';
import 'package:hero_app_flutter/core/utils/api_utils.dart';
import 'package:hero_app_flutter/features/auth/models/auth_flow_result.dart';
import 'package:hero_app_flutter/validations/email_validators.dart';
import 'package:hero_app_flutter/validations/validation_messages.dart';

typedef LoginRequest =
    Future<http.Response> Function({
      required String usernameOrEmail,
      required String password,
      http.Client? client,
    });

typedef RegisterRequest =
    Future<http.Response> Function({
      required String username,
      required String email,
      required String password,
      required String confirmPassword,
      http.Client? client,
    });

class AuthFlowController {
  AuthFlowController({
    AuthService? authService,
    AppSessionCoordinator? sessionCoordinator,
    LoginRequest? loginRequest,
    RegisterRequest? registerRequest,
  }) : _authService = authService,
       _sessionCoordinator = sessionCoordinator,
       _loginRequest = loginRequest ?? AuthService.login,
       _registerRequest = registerRequest ?? AuthService.register;

  AuthService? _authService;
  AppSessionCoordinator? _sessionCoordinator;
  final LoginRequest _loginRequest;
  final RegisterRequest _registerRequest;

  AuthService get _resolvedAuthService => _authService ??= AuthService();
  AppSessionCoordinator get _resolvedSessionCoordinator =>
      _sessionCoordinator ??= AppSessionCoordinator();

  Future<AuthFlowResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    if (usernameOrEmail.trim().isEmpty || password.trim().isEmpty) {
      return AuthFlowResult.validation(
        title: ValidationMessages.incompleteInfoTitle,
        message: 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน',
      );
    }

    try {
      final response = await _loginRequest(
        usernameOrEmail: usernameOrEmail.trim(),
        password: password.trim(),
      );
      return _handleLoginResponse(response);
    } catch (_) {
      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่ในภายหลัง',
      );
    }
  }

  Future<AuthFlowResult> loginWithGoogle() async {
    try {
      final userCredential = await _resolvedAuthService.signInWithGoogle();
      if (userCredential == null || userCredential.user == null) {
        return AuthFlowResult.cancelled();
      }

      final response = await _resolvedAuthService.loginByGoogle(
        providerUserId: userCredential.user!.uid,
        providerName: 'GOOGLE',
        providerUsername: userCredential.user!.displayName ?? '',
        providerEmail: userCredential.user!.email ?? '',
        providerAvatar: userCredential.user!.photoURL ?? '',
      );

      return _handleLoginResponse(response);
    } catch (_) {
      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message:
            'ไม่สามารถเข้าสู่ระบบด้วย Google ได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตแล้วลองใหม่อีกครั้ง',
      );
    }
  }

  Future<AuthFlowResult> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (username.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return AuthFlowResult.validation(
        title: ValidationMessages.incompleteInfoTitle,
        message: 'กรุณากรอกข้อมูลให้ครบทุกช่อง',
      );
    }

    if (!isValidEmail(email.trim())) {
      return AuthFlowResult.validation(
        title: 'อีเมลไม่ถูกต้อง',
        message: 'กรุณากรอกอีเมลให้ถูกต้อง',
      );
    }

    if (password.length < 6) {
      return AuthFlowResult.validation(
        title: 'รหัสผ่านสั้นเกินไป',
        message: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
      );
    }

    if (password != confirmPassword) {
      return AuthFlowResult.validation(
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'กรุณายืนยันรหัสผ่านให้ถูกต้อง',
      );
    }

    try {
      final response = await _registerRequest(
        username: username.trim(),
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response.statusCode == 201) {
        return AuthFlowResult.needsVerification(
          title: 'สำเร็จ',
          message: 'ตรวจสอบข้อความในอีเมลของคุณ\nเพื่อยืนยันบัญชี',
        );
      }

      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message: getErrorMessage(response),
      );
    } catch (_) {
      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
    }
  }

  Future<AuthFlowResult> _handleLoginResponse(http.Response response) async {
    if (response.statusCode != 200) {
      return AuthFlowResult.failure(
        title: 'เข้าสู่ระบบไม่สำเร็จ',
        message: getErrorMessage(response),
      );
    }

    final payload = _decodePayload(response.body);
    if (payload == null) {
      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้',
      );
    }

    final apiCode = _parseApiCode(payload['code']);
    if (apiCode != 200) {
      return AuthFlowResult.failure(
        title: 'เข้าสู่ระบบไม่สำเร็จ',
        message:
            payload['message']?.toString() ??
            'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
      );
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้',
      );
    }

    final uid = _extractUid(data);
    if (uid == null || uid.isEmpty) {
      return AuthFlowResult.failure(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้',
      );
    }

    final destination = await _resolvedSessionCoordinator.completeLogin(
      uid: uid,
      userData: data,
    );
    return AuthFlowResult.success(destination);
  }

  Map<String, dynamic>? _decodePayload(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  int _parseApiCode(dynamic code) {
    if (code is int) return code;
    if (code is String) return int.tryParse(code) ?? 0;
    return 0;
  }

  String? _extractUid(Map<String, dynamic> data) {
    return (data['uid'] ?? data['id'])?.toString();
  }
}
