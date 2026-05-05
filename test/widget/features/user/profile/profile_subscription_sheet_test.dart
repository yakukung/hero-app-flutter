import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_subscription_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens payment sheet from subscription package', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileSubscriptionSheet())),
    );

    await tester.tap(find.text('ชำระเงินในราคา ฿79.00'));
    await tester.pumpAndSettle();

    expect(find.text('ชำระเงิน'), findsOneWidget);
    expect(find.text('สแกน QR เพื่อชำระเงิน'), findsOneWidget);
    expect(find.text('แนบภาพสลิป'), findsOneWidget);
  });

  testWidgets('payment confirm button is disabled without slip', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfilePaymentSheet(
            packageTitle: 'รายเดือน',
            price: '฿79.00/เดือน',
            amount: '฿79.00',
          ),
        ),
      ),
    );

    final confirmButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('payment_confirm_button')),
    );

    expect(confirmButton.onPressed, isNull);
  });

  testWidgets('confirm payment shows pending status after slip is attached', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final tempDir = Directory.systemTemp.createTempSync(
      'profile_subscription_sheet_test',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final slipFile = File('${tempDir.path}/slip.png')
      ..writeAsBytesSync(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
          'AAAADUlEQVR42mP8z8BQDwAFgwJ/lQZkWQAAAABJRU5ErkJggg==',
        ),
      );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePaymentSheet(
            packageTitle: 'รายเดือน',
            price: '฿79.00/เดือน',
            amount: '฿79.00',
            pickSlipImage: () async => XFile(slipFile.path),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('payment_slip_picker')));
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('payment_confirm_button')),
    );
    expect(confirmButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('payment_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('payment_status_PENDING')), findsOneWidget);
  });

  testWidgets('shows inline message when slip image cannot be loaded', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePaymentSheet(
            packageTitle: 'รายเดือน',
            price: '฿79.00/เดือน',
            amount: '฿79.00',
            pickSlipImage: () async => throw PlatformException(
              code: 'invalid_image',
              message: 'Cannot load representation of type public.jpeg',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('payment_slip_picker')));
    await tester.pump();

    expect(
      find.text('ไม่สามารถโหลดรูปนี้ได้ กรุณาเลือกรูปอื่น'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('payment_slip_error_message')), findsOneWidget);

    final confirmButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('payment_confirm_button')),
    );
    expect(confirmButton.onPressed, isNull);
  });

  for (final status in PaymentStatus.values) {
    testWidgets('payment status dialog renders ${status.name}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProfilePaymentStatusDialog(status: status)),
        ),
      );

      expect(find.byKey(Key('payment_status_${status.name}')), findsOneWidget);
      expect(find.text(status.name), findsOneWidget);
      expect(
        find.byKey(const Key('payment_status_close_button')),
        findsOneWidget,
      );
    });
  }
}
