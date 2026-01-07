import 'package:flutter/material.dart';
import 'package:flutter_application_1/app.dart';
import 'package:flutter_application_1/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const MyApp());
}
