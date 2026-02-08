import 'package:flutter_test/flutter_test.dart';
import 'package:wise_apartment/src/models/keys/add_lock_key_action_model.dart';

void main() {
  test('hasLocalMenuAccess returns true for key ids 1..10', () {
    final m = AddLockKeyActionModel();
    for (var id = 1; id <= 10; id++) {
      m.addedKeyID = id;
      expect(
        m.hasLocalMenuAccess(),
        isTrue,
        reason: 'id $id should grant local menu',
      );
    }
  });

  test('hasLocalMenuAccess false for outside range', () {
    final m = AddLockKeyActionModel();
    m.addedKeyID = 0;
    expect(m.hasLocalMenuAccess(), isFalse);
    m.addedKeyID = 11;
    expect(m.hasLocalMenuAccess(), isFalse);
    m.addedKeyID = -1;
    expect(m.hasLocalMenuAccess(), isFalse);
  });

  test('setKeyIdForLocalMenu enforces range', () {
    final m = AddLockKeyActionModel();
    m.setKeyIdForLocalMenu(5);
    expect(m.addedKeyID, 5);
    expect(m.hasLocalMenuAccess(), isTrue);
    expect(() => m.setKeyIdForLocalMenu(0), throwsArgumentError);
    expect(() => m.setKeyIdForLocalMenu(11), throwsArgumentError);
  });
}
