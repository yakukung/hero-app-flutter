import 'package:flutter/material.dart';
import 'package:hero_app_flutter/app/app.dart';
import 'package:hero_app_flutter/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const HeroApp());
}
