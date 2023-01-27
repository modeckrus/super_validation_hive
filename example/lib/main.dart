import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:super_validation/super_validation.dart';
import 'package:super_validation_hive/super_validation_hive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperValidation Hive Demo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: FutureBuilder<bool>(future: () async {
        Hive.init('test/hive');
        await SuperValidationHiveStore.instance.init();
        return true;
      }(), builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MyHomePage();
        }
        return const Scaffold();
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Repository repository = Repository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperValidation Hive Demo'),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Icon(Icons.add),
            onPressed: () {
              final newWrappers = [...repository.wrappers.value ?? <Wrapper>[]];
              newWrappers.add(Wrapper(newWrappers.length.toString()));
              repository.wrappers.value = newWrappers;
            },
          ),
          TextButton(
            child: Icon(Icons.deblur),
            onPressed: () {
              final box = Hive.box<String>('super_validation');
              final keys = box.keys;
              for (var key in keys) {
                final val = box.get(key);
                print('$key: $val');
              }
            },
          ),
        ],
      ),
      body: SuperValidationEnumBuilder(
        superValidation: repository.wrappers,
        builder: (context, state) {
          final wrappers = state ?? [];
          return ListView.builder(
            itemCount: wrappers.length,
            itemBuilder: (context, index) {
              final wrapper = wrappers[index];
              return Column(
                children: [
                  TextFieldSuperValidation(
                      superValidation: wrapper.superValidation),
                  TextFieldSuperValidation(
                      superValidation: wrapper.superValidation2),
                  ElevatedButton(
                    onPressed: () {
                      final newWrappers = [...wrappers];
                      final wrapper = newWrappers[index];
                      wrapper.superValidation.value = null;
                      wrapper.superValidation2.value = null;
                      newWrappers.removeAt(index);
                      repository.wrappers.value = newWrappers;
                    },
                    child: const Text('Remove'),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class Repository {
  SuperValidationEnum<List<Wrapper>> wrappers = SuperValidationEnum(
    store: RepositoryStore('repository.wrappers'),
  );
}

class Wrapper {
  final String key;
  Wrapper(this.key);
  late final SuperValidation superValidation = SuperValidation(
    store: SuperValidationHive<String>('wrapper.superValidation.$key'),
  );
  late final SuperValidation superValidation2 = SuperValidation(
    store: SuperValidationHive<String>('wrapper.superValidation2.$key'),
  );
  factory Wrapper.fromJson(Map<String, dynamic> map) {
    return Wrapper(map['key']);
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
    };
  }
}

class RepositoryStore extends SuperValidationHive<List<Wrapper>> {
  RepositoryStore(super.key);

  @override
  List<Wrapper>? decode(String json) {
    try {
      final list = jsonDecode(json) as List;
      List<Wrapper> wrappers = [];
      for (var element in list) {
        final map = element as Map<String, dynamic>;
        wrappers.add(Wrapper.fromJson(map));
      }
      return wrappers;
    } catch (e) {
      return null;
    }
  }

  @override
  String? encode(List<Wrapper>? value) {
    try {
      if (value == null) {
        return null;
      }
      List<Map<String, dynamic>> list = [];
      for (var element in value) {
        list.add(element.toJson());
      }
      return jsonEncode(list);
    } catch (e) {
      return null;
    }
  }
}
