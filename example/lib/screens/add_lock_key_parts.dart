import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Key type dropdown
Widget buildKeyTypeDropdown({
  required List<MapEntry<int, String>> options,
  required int selectedIndex,
  required ValueChanged<int> onSelectedIndexChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Key Type '),
      DropdownButton<int>(
        items: options
            .map(
              (e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value)),
            )
            .toList(),
        value: options[selectedIndex].key,
        isExpanded: true,
        onChanged: (v) {
          final idx = options.indexWhere((e) => e.key == v);
          if (idx != -1) onSelectedIndexChanged(idx);
        },
      ),
      const SizedBox(height: 8),
    ],
  );
}

// User row (user id + user type)
Widget buildUserRow({
  required TextEditingController userController,
  required int currentUserType,
  required ValueChanged<int?> onUserTypeChanged,
}) {
  return SizedBox(
    height: 72,
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: userController,
            decoration: InputDecoration(
              labelText:
                  'User * ${currentUserType == 0 ? 'Regular (2001-4095)' : '(Admin) (901-2000)'}',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'User Type',
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: currentUserType,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Regular')),
                  DropdownMenuItem(value: 1, child: Text('Admin')),
                ],
                onChanged: onUserTypeChanged,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Password field
Widget buildPasswordField({required TextEditingController passwordController}) {
  return Column(
    children: [
      TextFormField(
        controller: passwordController,
        decoration: const InputDecoration(labelText: 'Password (6-12 digits)'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
    ],
  );
}

// Validity segmented control
Widget buildValiditySegment({
  required int validitySegment,
  required ValueChanged<int> onSegmentChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Validity period',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      CupertinoSegmentedControl<int>(
        groupValue: validitySegment,
        children: const {
          0: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text('Limit'),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text('one Time'),
          ),
          2: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text('Permanent'),
          ),
          3: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text('Cycle'),
          ),
        },
        onValueChanged: onSegmentChanged,
      ),
      const SizedBox(height: 12),
    ],
  );
}
