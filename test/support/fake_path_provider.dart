import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform() : _tempDir = Directory.systemTemp.createTempSync();

  final Directory _tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return _tempDir.path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return _tempDir.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return _tempDir.path;
  }
}
