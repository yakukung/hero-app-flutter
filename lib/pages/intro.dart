import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/widgets/animation/animated_background_intropage.dart';
import 'package:get/get.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    const double whiteContainerHeight = 380.0;
    const double borderRadiusAmount = 65;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: whiteContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadiusAmount),
                  topRight: Radius.circular(borderRadiusAmount),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'ฮีโร่สรุปชีต',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'แอปฮีโร่ช่วยให้คุณเข้าถึงความรู้ได้ง่าย\nและรวดเร็ว พร้อมสร้างรายได้จากการแบ่งปัน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B6B6B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: () => nextPage(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Color(0xFF2A5DB9),
                        foregroundColor: Colors.white,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void nextPage() {
    Get.to(() => const LoginPage());
  }
}
