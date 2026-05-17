import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_app_flutter/core/services/admin_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: '''
HTTP_SCHEME=http
API_HOST=localhost
API_PORT=3000
''',
    );
  });

  group('AdminService API methods', () {
    test('fetchReports sends authenticated admin reports request', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/admin/reports');
        expect(request.headers['authorization'], 'Bearer token-123');
        return http.Response('{"data":{"reports":[]}}', 200);
      });

      final response = await AdminService.fetchReports(
        token: 'token-123',
        client: client,
      );

      expect(response.statusCode, 200);
    });

    test('report moderation sends status and action payloads', () async {
      final seen = <String>[];
      final client = MockClient((request) async {
        seen.add('${request.method} ${request.url.path} ${request.body}');
        expect(request.headers['authorization'], 'Bearer admin-token');
        return http.Response('{}', 200);
      });

      await AdminService.updateReportStatus(
        reportId: 'report-1',
        referenceTable: 'posts',
        statusFlag: 'REVIEWING',
        token: 'admin-token',
        client: client,
      );
      await AdminService.submitReportAction(
        reportId: 'report-1',
        referenceTable: 'posts',
        action: 'HIDE',
        token: 'admin-token',
        client: client,
      );

      expect(seen, hasLength(2));
      expect(seen.first, startsWith('PATCH /admin/reports/report-1/status'));
      expect(jsonDecode(seen.first.split(' ').skip(2).join(' ')), {
        'reference_table': 'posts',
        'status_flag': 'REVIEWING',
      });
      expect(seen.last, startsWith('POST /admin/reports/report-1/action'));
      expect(jsonDecode(seen.last.split(' ').skip(2).join(' ')), {
        'reference_table': 'posts',
        'action': 'HIDE',
      });
    });

    test('payment status maps every admin payment type route', () async {
      final seen = <String>[];
      final client = MockClient((request) async {
        seen.add('${request.method} ${request.url.path} ${request.body}');
        return http.Response('{}', 200);
      });

      await AdminService.updatePaymentStatus(
        paymentId: 'wallet-1',
        paymentType: 'WALLET_TOPUP',
        paymentStatus: 'SUCCESSFUL',
        token: 'admin-token',
        client: client,
      );
      await AdminService.updatePaymentStatus(
        paymentId: 'plan-1',
        paymentType: 'SUBSCRIPTION',
        paymentStatus: 'FAILED',
        token: 'admin-token',
        client: client,
      );
      await AdminService.updatePaymentStatus(
        paymentId: 'sheet-1',
        paymentType: 'SHEET_PURCHASE',
        paymentStatus: 'REFUNDED',
        token: 'admin-token',
        client: client,
      );

      expect(
        seen[0],
        startsWith('PATCH /admin/wallet-top-ups/wallet-1/status'),
      );
      expect(seen[1], startsWith('PATCH /admin/subscriptions/plan-1/status'));
      expect(
        seen[2],
        startsWith('PATCH /admin/sheet-purchases/sheet-1/status'),
      );
    });

    test(
      'content moderation sends post sheet and comment status payloads',
      () async {
        final seen = <String>[];
        final client = MockClient((request) async {
          seen.add('${request.method} ${request.url.path} ${request.body}');
          return http.Response('{}', 200);
        });

        await AdminService.updatePostStatus(
          postId: 'post-1',
          statusFlag: 'INACTIVE',
          token: 'admin-token',
          client: client,
        );
        await AdminService.updateSheetStatus(
          sheetId: 'sheet-1',
          statusFlag: 'INACTIVE',
          token: 'admin-token',
          client: client,
        );
        await AdminService.updateCommentStatus(
          commentId: 'comment-1',
          statusFlag: 'ACTIVE',
          token: 'admin-token',
          client: client,
        );

        expect(seen.first, startsWith('PATCH /admin/posts/post-1/status'));
        expect(jsonDecode(seen.first.split(' ').skip(2).join(' ')), {
          'status_flag': 'INACTIVE',
        });
        expect(seen[1], startsWith('PATCH /admin/sheets/sheet-1/status'));
        expect(jsonDecode(seen[1].split(' ').skip(2).join(' ')), {
          'status_flag': 'INACTIVE',
        });
        expect(seen.last, startsWith('PATCH /admin/comments/comment-1/status'));
        expect(jsonDecode(seen.last.split(' ').skip(2).join(' ')), {
          'status_flag': 'ACTIVE',
        });
      },
    );

    test('fetchSheets uses the admin sheets endpoint', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/admin/sheets');
        expect(request.headers['authorization'], 'Bearer admin-token');
        return http.Response('{"data":{"sheets":[]}}', 200);
      });

      final response = await AdminService.fetchSheets(
        token: 'admin-token',
        client: client,
      );

      expect(response.statusCode, 200);
    });

    test('fetchPostComments uses the admin comments endpoint', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/admin/posts/post-1/comments');
        expect(request.headers['authorization'], 'Bearer admin-token');
        return http.Response('{"data":{"data":[]}}', 200);
      });

      final response = await AdminService.fetchPostComments(
        postId: 'post-1',
        token: 'admin-token',
        client: client,
      );

      expect(response.statusCode, 200);
    });
  });
}
