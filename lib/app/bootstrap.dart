import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:flutter_application_1/core/services/navigation_service.dart';
import 'package:flutter_application_1/firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await _lockPortraitOrientation();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(NavigationService());
}

Future<void> _lockPortraitOrientation() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
