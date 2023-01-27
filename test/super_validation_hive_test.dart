import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:super_validation/super_validation_string.dart';

import 'package:super_validation_hive/super_validation_hive.dart';

void main() {
  test('check value stored', () async {
    Hive.init('test/hive');
    await SuperValidationHiveStore.instance.init();
    final SuperValidationHive<String> hive =
        SuperValidationHive<String>('test');
    final SuperValidation superValidation = SuperValidation(store: hive);
    superValidation.value = 'test';
    expect(hive.valueStored, 'test');
  });
  test('check value regenerate in superValidation', () async {
    Hive.init('test/hive');
    await SuperValidationHiveStore.instance.init();
    final SuperValidationHive<String> hive =
        SuperValidationHive<String>('test');
    final SuperValidation superValidation = SuperValidation(store: hive);
    expect(superValidation.value, 'test');
  });
}
