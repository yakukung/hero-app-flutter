import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/features/user/profile/profile_top_ups_page.dart';

void main() {
  testWidgets('profile top ups page shows all top up statuses', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final topUps = [
      for (final status in PaymentStatus.values)
        ProfileTopUpHistoryItem(
          id: 'test-top-up-${status.name}',
          amount: '฿100.00',
          status: status,
          createdAt: DateTime(2026, 5, 5, 16, 48),
          reference: status == PaymentStatus.PENDING
              ? 'REF-TU-001'
              : 'REF-TU-${status.name}',
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: ProfileTopUpsPage(topUps: topUps)),
    );

    expect(find.text('รายการเติมเงินทั้งหมดของคุณ'), findsOneWidget);
    expect(find.text('ทั้งหมด 4 รายการ'), findsOneWidget);
    expect(find.text('REF-TU-001'), findsOneWidget);

    for (final status in PaymentStatus.values) {
      expect(
        find.byKey(Key('profile_top_up_status_chip_${status.name}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('profile top ups page shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileTopUpsPage(topUps: <ProfileTopUpHistoryItem>[]),
      ),
    );

    expect(find.text('รายการเติมเงินทั้งหมดของคุณ'), findsOneWidget);
    expect(find.text('ยังไม่มีรายการเติมเงิน'), findsOneWidget);
    expect(find.text('ทั้งหมด 0 รายการ'), findsNothing);
  });

  testWidgets('tapping top up item opens top up payment status page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final topUps = [
      ProfileTopUpHistoryItem(
        id: 'test-top-up-success',
        amount: '฿500.00',
        status: PaymentStatus.SUCCESSFUL,
        createdAt: DateTime(2026, 5, 5, 10, 15),
        reference: 'REF-TU-TEST',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: ProfileTopUpsPage(topUps: topUps)),
    );

    await tester.tap(
      find.byKey(const Key('profile_top_up_item_test-top-up-success')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('profile_payment_status_page')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('payment_current_status_SUCCESSFUL')),
      findsOneWidget,
    );
    expect(find.text('เติมเงินกระเป๋า'), findsOneWidget);
    expect(find.text('รายการ'), findsOneWidget);
    expect(
      find.text('เติมเงินสำเร็จ ยอดเงินพร้อมใช้งาน'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('ชำระเงินสำเร็จ แพ็กเกจของคุณพร้อมใช้งาน'), findsNothing);
  });
}
