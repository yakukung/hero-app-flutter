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

    final payments = [
      for (final status in PaymentStatus.values)
        ProfilePaymentHistoryItem(
          id: 'test-payment-${status.name}',
          packageTitle: 'แพ็กเกจ ${status.name}',
          price: '฿79.00',
          amount: '฿79.00',
          status: status,
          createdAt: DateTime(2026, 5, 5, 16, 48),
          reference: 'REF-${status.name}',
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: ProfilePaymentsPage(payments: payments)),
    );

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

    final payments = [
      ProfilePaymentHistoryItem(
        id: 'test-payment-pending',
        packageTitle: 'รายเดือน',
        price: '฿79.00',
        amount: '฿79.00',
        status: PaymentStatus.PENDING,
        createdAt: DateTime(2026, 5, 5, 16, 48),
        reference: 'REF-PM-001',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: ProfilePaymentsPage(payments: payments)),
    );

    await tester.tap(
      find.byKey(const Key('profile_payment_item_test-payment-pending')),
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
