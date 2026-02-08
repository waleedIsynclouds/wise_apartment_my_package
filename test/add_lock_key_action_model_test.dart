import 'package:flutter_test/flutter_test.dart';
import 'package:wise_apartment/src/models/keys/add_lock_key_action_model.dart';

void main() {
  test('applyCycle sets vaildMode and daily times correctly when provided', () {
    final m = AddLockKeyActionModel();
    m.applyCycle(
      days: {1, 3, 5},
      dailyStartMinutes: 480,
      dailyEndMinutes: 1020,
      start: DateTime.utc(2025, 1, 1),
      end: DateTime.utc(2025, 12, 31),
    );

    expect(m.vaildMode, 1);
    expect(m.dayStartTimes, 480);
    expect(m.dayEndTimes, 1020);
    expect(m.week, isNonZero);
    final map = m.toMap();
    expect(map['vaildMode'], 1);
    expect(map['dayStartTimes'], 480);
    expect(map['dayEndTimes'], 1020);
  });

  test('applyCycle defaults both-zero daily times to full day (0..1439)', () {
    final m = AddLockKeyActionModel();
    m.applyCycle(days: {2, 4}, dailyStartMinutes: 0, dailyEndMinutes: 0);

    expect(m.vaildMode, 1);
    expect(m.dayStartTimes, 0);
    expect(m.dayEndTimes, 1439);
    final map = m.toMap();
    expect(map['vaildMode'], 1);
    expect(map['dayStartTimes'], 0);
    expect(map['dayEndTimes'], 1439);
  });
}
