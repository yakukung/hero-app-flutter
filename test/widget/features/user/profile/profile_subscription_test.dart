import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/payment_history_model.dart';
import 'package:hero_app_flutter/core/models/service_result.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payment_status_page.dart';
import 'package:hero_app_flutter/features/user/profile/widgets/profile_subscription.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('subscription sheet has drag handle and dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const ProfileSubscription(),
                  );
                },
                child: const Text('open subscription'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open subscription'));
    await tester.pumpAndSettle();

    expect(find.text('แพ็กเกจสมาชิกพรีเมียม'), findsOneWidget);
    expect(find.byKey(const Key('subscription_drag_handle')), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('แพ็กเกจสมาชิกพรีเมียม'), findsNothing);
  });

  testWidgets('opens payment sheet from subscription package', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileSubscription())),
    );

    await tester.tap(find.text('ชำระเงินในราคา ฿79.00'));
    await tester.pumpAndSettle();

    expect(find.text('ชำระเงิน'), findsOneWidget);
    expect(find.text('สแกน QR เพื่อชำระเงิน'), findsOneWidget);
    expect(find.text('แนบภาพสลิป'), findsOneWidget);
  });

  testWidgets('loads subscription plans from backend when provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileSubscription(
            fetchPlans: () async => const ServiceResult(
              success: true,
              statusCode: 200,
              message: 'ok',
              data: [
                SubscriptionPlanModel(
                  id: 'plan-week',
                  title: 'รายสัปดาห์',
                  price: 29,
                  intervalLabel: 'WEEK',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('รายสัปดาห์'), findsOneWidget);
    expect(find.text('฿29.00/สัปดาห์'), findsOneWidget);
    expect(find.text('ชำระเงินในราคา ฿29.00'), findsOneWidget);
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

  testWidgets(
    'confirm payment pushes pending status page after slip is attached',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tempDir = Directory.systemTemp.createTempSync(
        'profile_subscription_test',
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

      expect(
        find.byKey(const Key('profile_payment_status_page')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('payment_current_status_PENDING')),
        findsOneWidget,
      );
    },
  );

  testWidgets('confirm payment from package closes both sheets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final tempDir = Directory.systemTemp.createTempSync(
      'profile_subscription_test',
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
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ProfileSubscription(
                      pickSlipImage: () async => XFile(slipFile.path),
                      submitPayment: (_) async => const ServiceResult(
                        success: true,
                        statusCode: 201,
                        message: 'ok',
                        data: PaymentStatus.PENDING,
                      ),
                    ),
                  );
                },
                child: const Text('open subscription'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open subscription'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ชำระเงินในราคา ฿79.00'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('payment_slip_picker')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('payment_confirm_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('profile_payment_status_page')),
      findsOneWidget,
    );
    expect(find.text('แพ็กเกจสมาชิกพรีเมียม'), findsNothing);
    expect(find.text('สแกน QR เพื่อชำระเงิน'), findsNothing);
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
    testWidgets('payment status page renders ${status.name}', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePaymentStatusPage(
            status: status,
            packageTitle: 'รายเดือน',
            price: '฿79.00/เดือน',
            amount: '฿79.00',
          ),
        ),
      );

      expect(
        find.byKey(Key('payment_current_status_${status.name}')),
        findsOneWidget,
      );
      expect(find.text(status.name), findsAtLeastNWidgets(1));
      expect(
        find.byKey(const Key('payment_status_page_close_button')),
        findsOneWidget,
      );
      for (final paymentStatus in PaymentStatus.values) {
        expect(
          find.byKey(Key('payment_status_item_${paymentStatus.name}')),
          findsOneWidget,
        );
      }
    });
  }
}
