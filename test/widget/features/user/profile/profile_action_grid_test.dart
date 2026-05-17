import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero_app_flutter/features/user/profile/widgets/profile_action_grid.dart';

void main() {
  testWidgets('profile action grid opens wallet from balance button', (
    tester,
  ) async {
    var openedWallet = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileActionGrid(
            wallet: 0,
            onEditProfile: () {},
            onShowSubscriptions: () {},
            onOpenUserSheets: () {},
            onOpenPayments: () {},
            onOpenWallet: () {
              openedWallet = true;
            },
            onOpenPreferences: () {},
            onOpenNotifications: () {},
          ),
        ),
      ),
    );

    expect(find.text('ยอดเงินคงเหลือ\n0 บาท'), findsOneWidget);

    await tester.tap(find.text('ยอดเงินคงเหลือ\n0 บาท'));

    expect(openedWallet, isTrue);
  });

  testWidgets('profile action grid shows payment list button', (tester) async {
    var openedPayments = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileActionGrid(
            wallet: 0,
            onEditProfile: () {},
            onShowSubscriptions: () {},
            onOpenUserSheets: () {},
            onOpenPayments: () {
              openedPayments = true;
            },
            onOpenWallet: () {},
            onOpenPreferences: () {},
            onOpenNotifications: () {},
          ),
        ),
      ),
    );

    expect(find.text('รายการชำระเงิน\nทั้งหมดของคุณ'), findsOneWidget);

    await tester.tap(find.text('รายการชำระเงิน\nทั้งหมดของคุณ'));

    expect(openedPayments, isTrue);
  });
}
