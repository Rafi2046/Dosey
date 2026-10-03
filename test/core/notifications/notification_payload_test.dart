import 'package:dosey/core/constants/app_constants.dart';
import 'package:dosey/core/notifications/awesome_notification_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime(2026, 10, 3, 23);

  test('a grouped notification carries every reminder id', () {
    final (ids, time) = NotificationPayload.decode(
      NotificationPayload.encode([7, 3], at),
    )!;
    expect(ids, [7, 3]);
    expect(time, at);
  });

  test('notifications posted before grouping still decode', () {
    final legacy = {
      AppConstants.payloadReminderId: '5',
      AppConstants.payloadScheduledFor: at.toIso8601String(),
    };
    final (ids, time) = NotificationPayload.decode(legacy)!;
    expect(ids, [5]);
    expect(time, at);
  });

  test('a payload without ids or time is ignored', () {
    expect(NotificationPayload.decode(null), isNull);
    expect(
      NotificationPayload.decode({AppConstants.payloadReminderIds: '1,2'}),
      isNull,
    );
  });
}
