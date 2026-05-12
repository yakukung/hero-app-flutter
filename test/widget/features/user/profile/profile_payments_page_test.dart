import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/features/user/profile/profile_payments_page.dart';

void main() {
  testWidgets('profile payments page shows all payment statuses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: ProfilePaymentsPage()));

    expect(find.text('รายการชำระเงินทั้งหมดของคุณ'), findsOneWidget);
    expect(find.text('ทั้งหมด 4 รายการ'), findsOneWidget);

    for (final status in PaymentStatus.values) {
      expect(
        find.byKey(Key('profile_payment_status_chip_${status.name}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('tapping payment item opens payment status page', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: ProfilePaymentsPage()));

    await tester.tap(
      find.byKey(const Key('profile_payment_item_mock-payment-001')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('profile_payment_status_page')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('payment_current_status_PENDING')),
      findsOneWidget,
    );
  });
}
