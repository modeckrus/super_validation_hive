library super_validation_hive;

import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:super_validation/super_validation_a.dart';

class SuperValidationHive<T> extends SuperValidationStore<T> {
  final String key;

  SuperValidationHive(this.key);

  @override
  T? get valueStored {
    final json = SuperValidationHiveStore.instance.get(key);
    if (json == null) {
      return null;
    }
    return decode(json);
  }

  @override
  set valueStored(T? value) {
    log('valueStored: $value');
    if (value == null) {
      SuperValidationHiveStore.instance.set(key, '');
      return;
    }
    final json = encode(value);
    if (json == null) {
      return;
    }
    SuperValidationHiveStore.instance.set(key, json);
  }

  String? encode(T? value) {
    try {
      return jsonEncode(value);
    } catch (e) {
      return null;
    }
  }

  T? decode(String json) {
    try {
      return jsonDecode(json);
    } catch (e) {
      return null;
    }
  }
}

class SuperValidationHiveStore {
  static SuperValidationHiveStore? _instance;
  static SuperValidationHiveStore get instance {
    _instance ??= SuperValidationHiveStore._();
    return _instance!;
  }

  SuperValidationHiveStore._();

  late Box<String> box;
  Future<void> init() async {
    box = await Hive.openBox<String>('super_validation');
  }

  void set(String key, String value) {
    box.put(key, value);
  }

  String? get(String key) {
    return box.get(key);
  }
}
