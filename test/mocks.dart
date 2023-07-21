import 'dart:async';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hive/src/box/default_compaction_strategy.dart';
import 'package:hive/src/box/default_key_comparator.dart';
import 'package:mockito/mockito.dart';

class FakeBox<T> extends Fake implements Box<T> {
  final _map = <dynamic, T>{};

  @override
  bool isOpen = true;

  @override
  T? get(key, {T? defaultValue}) {
    return _map[key] ?? defaultValue;
  }

  @override
  Future<void> put(key, T value) async {
    _map[key] = value;
  }

  @override
  Future<void> delete(key) async {
    _map.remove(key);
  }

  @override
  Future<void> deleteAll(keys) async {
    for (final key in keys) {
      _map.remove(key);
    }
  }

  @override
  Map<dynamic, T> toMap() => _map;

  @override
  Iterable get keys => _map.keys;

  @override
  Iterable<T> get values {
    return _map.values;
  }

  @override
  bool containsKey(key) => _map.containsKey(key);

  @override
  int get length => _map.length;

  @override
  Future<void> deleteFromDisk() async {
    await clear();
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  Future<int> clear() {
    _map.clear();
    return Future.value(0);
  }

  @override
  Future<void> close() async {
    isOpen = false;
  }
}

class HiveFake extends Fake implements HiveInterface {
  final _boxes = <String, Box>{};

  @override
  bool isBoxOpen(String name) => _boxes[name]?.isOpen ?? false;

  @override
  void init(String? path,
      {HiveStorageBackendPreference backendPreference =
          HiveStorageBackendPreference.native}) {}

  @override
  Future<bool> boxExists(String name, {String? path}) async =>
      _boxes.containsKey(name);

  @override
  Future<Box<E>> openBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    KeyComparator keyComparator = defaultKeyComparator,
    CompactionStrategy compactionStrategy = defaultCompactionStrategy,
    bool crashRecovery = true,
    String? path,
    Uint8List? bytes,
    String? collection,
    @Deprecated('Use encryptionCipher instead') List<int>? encryptionKey,
  }) async {
    if (name == '_error') {
      throw HiveError('fake error');
    }
    final box = FakeBox<E>();
    _boxes[name] = box;
    return box;
  }

  @override
  Future<void> deleteBoxFromDisk(String name, {String? path}) async {
    _boxes.remove(name);
  }

  @override
  bool isAdapterRegistered(int typeId) {
    return true;
  }
}

class Listener<T> extends Mock {
  void call(T value);
}
