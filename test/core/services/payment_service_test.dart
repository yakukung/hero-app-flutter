import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/session/session_store.dart';
import 'package:hero_app_flutter/core/services/payment_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../support/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    dotenv.loadFromString(
      envString: 'HTTP_SCHEME=http\nAPI_HOST=localhost\nAPI_PORT=3000',
    );
    await GetStorage.init();
  });

  setUp(() async {
    await GetStorage().erase();
    SessionStore().write(SessionStore.tokenKey, 'token-123');
    SessionStore().write(SessionStore.uidKey, 'user-1');
  });

  test(
    'purchaseSheet posts wallet payload and parses wallet balance',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/sheets/sheet-1/purchase');
        expect(request.headers['authorization'], 'Bearer token-123');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['payment_method'], 'WALLET');
        expect(body['amount'], 100);

        return _jsonResponse({
          'data': {
            'is_purchased': true,
            'wallet': {'balance': 25.5},
          },
        }, 201);
      });

      final result = await PaymentService.purchaseSheet(
        sheetId: 'sheet-1',
        amount: 100,
        client: client,
      );

      expect(result.success, isTrue);
      expect(result.data?.isPurchased, isTrue);
      expect(result.data?.walletBalance, 25.5);
    },
  );

  test('fetchSubscriptionStatus parses premium state', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/subscriptions/me');

      return _jsonResponse({
        'data': {
          'is_premium': true,
          'plan_id': 'plan-1',
          'plan_name': 'รายเดือน',
          'expires_at': '2026-06-01T00:00:00.000Z',
          'auto_renew': false,
        },
      }, 200);
    });

    final result = await PaymentService.fetchSubscriptionStatus(client: client);

    expect(result.success, isTrue);
    expect(result.data?.isPremium, isTrue);
    expect(result.data?.planId, 'plan-1');
    expect(result.data?.planName, 'รายเดือน');
  });

  test('fetchPlans parses backend plan list', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/subscriptions/plans');

      return _jsonResponse({
        'data': {
          'plans': [
            {
              'id': 'plan-3m',
              'name': 'ราย 3 เดือน',
              'price': '229.00',
              'billing_interval': 'MONTH',
              'billing_interval_count': 3,
            },
          ],
        },
      }, 200);
    });

    final result = await PaymentService.fetchPlans(client: client);

    expect(result.success, isTrue);
    expect(result.data, hasLength(1));
    expect(result.data!.first.id, 'plan-3m');
    expect(result.data!.first.intervalCount, 3);
  });

  test('fetchPaymentHistory reads Thai backend error message', () async {
    final client = MockClient((request) async {
      return _jsonResponse({
        'error': {
          'message': {'th': 'โหลดรายการไม่สำเร็จ', 'en': 'failed'},
        },
      }, 500);
    });

    final result = await PaymentService.fetchPaymentHistory(client: client);

    expect(result.success, isFalse);
    expect(result.message, 'โหลดรายการไม่สำเร็จ');
    expect(result.data, isEmpty);
  });

  test('create top-up history parses pending status', () async {
    final client = MockClient((request) async {
      return _jsonResponse({
        'data': {
          'top_ups': [
            {
              'id': 'top-up-1',
              'amount': '100.00',
              'payment_status': 'PENDING',
              'created_at': '2026-05-16T00:00:00.000Z',
            },
          ],
        },
      }, 200);
    });

    final result = await PaymentService.fetchTopUpHistory(client: client);

    expect(result.success, isTrue);
    expect(result.data, hasLength(1));
    expect(result.data!.first.status, PaymentStatus.PENDING);
  });
}

http.Response _jsonResponse(Map<String, dynamic> body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}
