import 'package:flutter_test/flutter_test.dart';
import 'package:hero_app_flutter/core/models/enums.dart';
import 'package:hero_app_flutter/core/models/post_model.dart';

void main() {
  group('PostCommentModel', () {
    test('parses moderation flags from nested flag payload', () {
      final comment = PostCommentModel.fromJson({
        'id': 'comment-1',
        'post_id': 'post-1',
        'user_id': 'user-1',
        'content': 'hidden comment',
        'created_at': '2026-05-17T06:00:00.000Z',
        'flag': {'visible_flag': false, 'status_flag': 'INACTIVE'},
      });

      expect(comment.visibleFlag, isFalse);
      expect(comment.statusFlag, StatusFlag.INACTIVE);
    });

    test('parses lowercase moderation status from admin payload', () {
      final comment = PostCommentModel.fromJson({
        'id': 'comment-1',
        'post_id': 'post-1',
        'user_id': 'user-1',
        'content': 'hidden comment',
        'created_at': '2026-05-17T06:00:00.000Z',
        'visible_flag': true,
        'status_flag': 'inactive',
      });

      expect(comment.visibleFlag, isTrue);
      expect(comment.statusFlag, StatusFlag.INACTIVE);
    });
  });
}
