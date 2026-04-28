import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hero_app_flutter/features/user/community/controllers/create_post_page_controller.dart';
import 'package:hero_app_flutter/features/user/community/create_post_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('shows snackbar when create post form is empty', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: CreatePostPage()));

    await tester.tap(find.byKey(const Key('create_post_submit_button')));
    await tester.pump();

    expect(find.text('กรุณาใส่ข้อความ'), findsOneWidget);
  });

  testWidgets('pops with true when create post succeeds', (tester) async {
    final controller = CreatePostPageController(
      submitPost: ({required content, sheetId}) async => true,
    );
    Object? routeResult;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    routeResult = await Get.to(
                      () => CreatePostPage(controller: controller),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'โพสต์สำเร็จ');
    await tester.tap(find.byKey(const Key('create_post_submit_button')));
    await tester.pumpAndSettle();

    expect(routeResult, isTrue);
    controller.dispose();
  });
}
