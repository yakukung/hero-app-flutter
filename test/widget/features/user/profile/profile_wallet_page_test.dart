import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/features/user/profile/profile_wallet_page.dart';

void main() {
  testWidgets('wallet page shows current balance and amount options', (
    tester,
  ) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(home: ProfileWalletPage(currentWallet: 125)),
    );

    expect(find.text('ยอดเงินปัจจุบัน'), findsOneWidget);
    expect(find.byKey(const Key('wallet_current_balance')), findsOneWidget);
    expect(find.text('125 บาท'), findsOneWidget);
    expect(find.text('ยอดเติมที่เลือก'), findsOneWidget);
    expect(find.byKey(const Key('wallet_selected_amount')), findsOneWidget);
    expect(find.text('0 บาท'), findsOneWidget);
    expect(find.byKey(const Key('wallet_pay_button')), findsOneWidget);
    expect(
      find.byKey(const Key('wallet_top_up_history_button')),
      findsOneWidget,
    );
    expect(find.text('รายการเติมเงินทั้งหมด'), findsOneWidget);

    for (final amount in [10, 20, 30, 40, 50, 100, 200, 300, 500]) {
      expect(find.byKey(Key('wallet_amount_button_$amount')), findsOneWidget);
      expect(find.text('$amount'), findsOneWidget);
    }
  });

  testWidgets('wallet page replaces selected amount without accumulating', (
    tester,
  ) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(home: ProfileWalletPage(currentWallet: 125)),
    );

    await tester.tap(find.byKey(const Key('wallet_amount_button_100')));
    await tester.pump();

    expect(find.text('100 บาท'), findsOneWidget);
    expect(find.text('125 บาท'), findsOneWidget);

    await tester.tap(find.byKey(const Key('wallet_amount_button_500')));
    await tester.pump();

    expect(find.text('500 บาท'), findsOneWidget);
    expect(find.text('125 บาท'), findsOneWidget);
    expect(find.text('600 บาท'), findsNothing);
    expect(find.text('625 บาท'), findsNothing);
  });

  testWidgets('wallet pay button is disabled until amount is selected', (
    tester,
  ) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ProfileWalletPage()));

    final disabledButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('wallet_pay_button')),
    );
    expect(disabledButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('wallet_amount_button_100')));
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('wallet_pay_button')),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('wallet pay button opens pending payment status', (tester) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ProfileWalletPage()));

    await tester.tap(find.byKey(const Key('wallet_amount_button_100')));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('wallet_pay_button')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('wallet_pay_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('profile_payment_status_page')),
      findsOneWidget,
    );
    expect(find.text('เติมเงินกระเป๋า'), findsOneWidget);
    expect(
      find.byKey(const Key('payment_current_status_PENDING')),
      findsOneWidget,
    );
    expect(
      find.text('ระบบได้รับข้อมูลแล้ว กรุณารอการตรวจสอบสลิป'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('wallet top up history button sits below balance', (
    tester,
  ) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(home: ProfileWalletPage(currentWallet: 125)),
    );

    final balanceBottom = tester.getBottomLeft(
      find.byKey(const Key('wallet_current_balance')),
    );
    final historyTop = tester.getTopLeft(
      find.byKey(const Key('wallet_top_up_history_button')),
    );
    final selectedAmountTop = tester.getTopLeft(
      find.byKey(const Key('wallet_selected_amount')),
    );

    expect(historyTop.dy, greaterThan(balanceBottom.dy));
    expect(historyTop.dy, lessThan(selectedAmountTop.dy));
  });

  testWidgets('wallet top up controls sit at the bottom', (tester) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(home: ProfileWalletPage(currentWallet: 125)),
    );

    final historyBottom = tester.getBottomLeft(
      find.byKey(const Key('wallet_top_up_history_button')),
    );
    final selectedAmountTop = tester.getTopLeft(
      find.byKey(const Key('wallet_selected_amount')),
    );
    final payButtonBottom = tester.getBottomLeft(
      find.byKey(const Key('wallet_pay_button')),
    );

    expect(selectedAmountTop.dy, greaterThan(historyBottom.dy));
    expect(payButtonBottom.dy, greaterThan(2280));
  });

  testWidgets('wallet top up history button opens top ups page', (
    tester,
  ) async {
    _setLargeWalletViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ProfileWalletPage()));

    await tester.ensureVisible(
      find.byKey(const Key('wallet_top_up_history_button')),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('wallet_top_up_history_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_top_ups_page')), findsOneWidget);
    expect(find.text('รายการเติมเงินทั้งหมดของคุณ'), findsOneWidget);
  });
}

void _setLargeWalletViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
