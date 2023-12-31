part of flutter_data;

abstract class DataModel<T extends DataModel<T>> with DataModelMixin<T> {
  DataModel() {
    init();
  }

  /// Returns a model [RemoteAdapter]
  static RemoteAdapter adapterFor(DataModelMixin model) => model._remoteAdapter;

  /// Apply [source]'s key to [destination].
  static T withKeyOf<T extends DataModelMixin<T>>(
      {required T source, required T destination}) {
    if (source._key == null) {
      throw Exception("Model must be initialized:\n\n$source");
    }

    final graph = source._remoteAdapter.graph;
    final type = source._internalType;

    // ONLY data we keep from source is its key
    // ONLY data we remove from destination is its key
    if (source._key != destination._key) {
      final destKey = destination._key;

      // assign correct key to destination
      destination._key = source._key;

      // migrate relationships to new key
      destination._remoteAdapter.localAdapter._initializeRelationships(
        destination,
        from: source,
      );

      if (destKey != null) {
        // remove node
        graph._removeNode(destKey);
      }

      if (destination.id != null) {
        // if present, remove existent ID association
        graph.removeId(type, destination.id!, notify: false);
        // and associate ID with source key
        graph.getKeyForId(type, destination.id, keyIfAbsent: source._key);
      }
    }
    return destination;
  }

  // data model helpers

  /// Returns a model's `_key` private attribute.
  ///
  /// Useful for testing, debugging or usage in [RemoteAdapter] subclasses.
  static String keyFor(DataModel model) {
    return model._key!;
  }

  /// Returns a model's non-null relationships.
  static Map<String, Relationship>
      relationshipsFor<T extends DataModelMixin<T>>(T model) {
    return {
      for (final meta
          in model._remoteAdapter.localAdapter.relationshipMetas.values)
        if (meta.instance(model) != null) meta.name: meta.instance(model)!,
    };
  }
}

/// Data classes extending this class are marked to be managed
/// through Flutter Data.
///
/// It enforces the implementation of an [id] getter.
/// It contains private state and methods to track the model's identity.
mixin DataModelMixin<T extends DataModelMixin<T>> {
  Object? get id;

  String? _key;
  String get _internalType => DataHelpers.getInternalType<T>();
  T get _this => this as T;

  /// Exposes this type's [RemoteAdapter]
  RemoteAdapter<T> get _remoteAdapter =>
      internalRepositories[_internalType]!.remoteAdapter as RemoteAdapter<T>;

  T init() {
    final repository = internalRepositories[_internalType];
    if (repository != null) {
      repository.remoteAdapter.localAdapter.initModel(
        this,
        onModelInitialized: repository.remoteAdapter.onModelInitialized,
      );
    }
    return this as T;
  }

  static String? keyFor(DataModelMixin model) {
    return model._key;
  }
}

/// Extension that adds syntax-sugar to data classes,
/// linking them to common [Repository] methods such as
/// [save] and [delete].
extension DataModelExtension<T extends DataModelMixin<T>> on DataModelMixin<T> {
  /// Copy identity (internal key) from an old model to a new one
  /// to signal they are the same.
  ///
  /// **Only makes sense to use if model is immutable and has no ID!**
  ///
  /// ```
  /// final walter = Person(name: 'Walter');
  /// person.copyWith(age: 56).withKeyOf(walter);
  /// ```
  T withKeyOf(T model) {
    return DataModel.withKeyOf<T>(source: model, destination: this as T);
  }

  /// Saves this model through a call equivalent to [Repository.save].
  ///
  /// Usage: `await post.save()`, `author.save(remote: false, params: {'a': 'x'})`.
  Future<T> save({
    bool? remote,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    OnSuccessOne<T>? onSuccess,
    OnErrorOne<T>? onError,
  }) async {
    return await _remoteAdapter.save(
      _this,
      remote: remote,
      params: params,
      headers: headers,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Deletes this model through a call equivalent to [Repository.delete].
  Future<T?> delete({
    bool? remote,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    OnSuccessOne<T>? onSuccess,
    OnErrorOne<T>? onError,
  }) async {
    return await _remoteAdapter.delete(
      this,
      remote: remote,
      params: params,
      headers: headers,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Reload this model through a call equivalent to [Repository.findOne].
  /// with the current object/[id]
  Future<T?> reload({
    bool? remote,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool? background,
    DataRequestLabel? label,
  }) async {
    return await _remoteAdapter.findOne(
      this,
      remote: remote,
      params: params,
      headers: headers,
      background: background,
      label: label,
    );
  }

  // locals

  /// Saves this model to local storage.
  T saveLocal() => _remoteAdapter.saveLocal(_this);

  /// Deletes this model from local storage.
  void deleteLocal() => _remoteAdapter.deleteLocal(_this);

  /// Reload model from local storage.
  T? reloadLocal() => _remoteAdapter.localAdapter.findOne(_key);
}
