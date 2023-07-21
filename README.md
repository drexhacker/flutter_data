<!-- markdownlint-disable MD033 MD041 -->
<p align="center" style="margin-bottom: 0px;">
  <img src="https://avatars2.githubusercontent.com/u/61839689?s=200&v=4" width="85px">
</p>

<h1 align="center" style="margin-top: 0px; font-size: 4em;">Flutter Data</h1>

[![tests](https://img.shields.io/github/actions/workflow/status/flutterdata/flutter_data/test.yml?branch=master)](https://github.com/flutterdata/flutter_data/actions) [![codecov](https://codecov.io/gh/flutterdata/flutter_data/branch/master/graph/badge.svg)](https://codecov.io/gh/flutterdata/flutter_data) [![pub.dev](https://img.shields.io/pub/v/flutter_data?label=pub.dev&labelColor=333940&logo=dart)](https://pub.dev/packages/flutter_data) [![license](https://img.shields.io/github/license/flutterdata/flutter_data?color=%23007A88&labelColor=333940&logo=mit)](https://github.com/flutterdata/flutter_data/blob/master/LICENSE)

## Persistent reactive models in Flutter with zero boilerplate

Flutter Data is an offline-first data framework with a customizable REST client and powerful model relationships.

<small>Inspired by [Ember Data](https://github.com/emberjs/data) and [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html).</small>

## Features

- **Repositories for all models** 🚀
  - CRUD and custom remote endpoints
  - [StateNotifier](https://pub.dev/packages/state_notifier) watcher APIs
- **Built for offline-first** 🔌
  - [Hive](https://docs.hivedb.dev/)-based local storage at its core
  - Failure handling & retry API
- **Intuitive APIs, effortless setup** 💙
  - Truly configurable and composable via Dart mixins and codegen
  - Built-in [Riverpod](https://riverpod.dev/) providers for all models
- **Exceptional relationship support** ⚡️
  - Automatically synchronized, fully traversable relationship graph
  - Reactive relationships

**Check out the [Tutorial](https://flutterdata.dev/tutorial) 📚 where we build a TO-DO app from the ground up in record time.**

## 👩🏾‍💻 Usage

(See the [quickstart guide](https://flutterdata.dev/docs/quickstart/) for setup and boot configuration.)

For a given `User` model annotated with `@DataRepository`:

```dart
@JsonSerializable()
@DataRepository([MyJSONServerAdapter])
class User extends DataModel<User> {
  @override
  final int? id; // ID can be of any type
  final String name;
  User({this.id, required this.name});
  // `User.fromJson` and `toJson` optional
}

mixin MyJSONServerAdapter on RemoteAdapter<User> {
  @override
  String get baseUrl => "https://my-json-server.typicode.com/flutterdata/demo/";
}
```

After a code-gen build, Flutter Data will generate a `Repository<User>` (and shortcuts like `ref.users` for Riverpod):

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.users.watchOne(1);
  if (state.isLoading) {
    return Center(child: const CircularProgressIndicator());
  }
  final user = state.model;
  return Text(user.name);
}
```

Update the user:

```dart
TextButton(
  onPressed: () => ref.users.save(User(id: 1, name: 'Updated')),
  child: Text('Update'),
),
```

`ref.users.watchOne(1)` will make a background HTTP request (to `https://my-json-server.typicode.com/flutterdata/demo/users/1` in this case), deserialize data and listen for any further changes to the `User` – whether those are local or remote!

`state` is of type `DataState` which has loading, error and data substates.

In addition to the reactivity, `DataModel`s get extensions and automatic relationships, ActiveRecord-style, so the above becomes:

```dart
GestureDetector(
  onTap: () => User(id: 1, name: 'Updated').save(),
  child: Text('Update')
),
```

More examples:

```dart
final task = await Task(title: 'Finish docs').save();
// or its equivalent:
final task = await ref.tasks.save(Task(title: 'Finish docs'));
// POST https://my-json-server.typicode.com/flutterdata/demo/tasks/
print(task.id); // 201

final user = await repository.findOne(1, params: {'_embed': 'tasks'});
// (remember repository can be accessed via ref.users)
// GET https://my-json-server.typicode.com/flutterdata/demo/users/1?_embed=tasks
print(user.tasks.length); // 20

await user.tasks.last.delete();
```

**Explore the [Documentation](https://flutterdata.dev/docs/).**

## Compatibility

Fully compatible with the tools we know and love:

<table class="table-fixed">
  <thead>
    <tr>
      <th class="w-4/12"></th>
      <th class="w-1/12"></th>
      <th class="w-7/12"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="font-bold px-4 py-2"><strong>Flutter</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">And pure Dart, too.</td>
    </tr>
    <tr class="bg-yellow-50">
      <td class="font-bold px-4 py-2"><strong>Flutter Web</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Supported (untested)</td>
    </tr>
    <tr>
      <td class="font-bold px-4 py-2"><strong>json_serializable</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Fully supported (but not required)
      </td>
    </tr>
    <tr class="bg-yellow-50">
      <td class="font-bold px-4 py-2"><strong>Riverpod</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Supported &amp; automatically wired up</td>
    </tr>
    <tr>
      <td class="font-bold px-4 py-2"><strong>Classic JSON REST API</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Built-in support!</td>
    </tr>
    <tr class="bg-yellow-50">
      <td class="font-bold px-4 py-2"><strong>JSON:API</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Supported via <a href="https://pub.dev/packages/flutter_data_json_api_adapter">external adapter</a></td>
    </tr>
    <tr class="bg-yellow-50">
      <td class="font-bold px-4 py-2"><strong>Firebase, Supabase, GraphQL</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Can be fully supported by writing <a href="https://flutterdata.dev/docs/adapters/">custom adapters</a></td>
    </tr>
    <tr>
      <td class="font-bold px-4 py-2"><strong>Freezed</strong></td>
      <td class="px-4 py-2">✅</td>
      <td class="px-4 py-2 text-sm">Supported!</td>
    </tr>
  </tbody>
</table>

## 📲 Apps using Flutter Data in production

![logos](https://user-images.githubusercontent.com/66403/115444364-79053f80-a1e2-11eb-9498-ee86718a4be5.png)

## ➕ Questions and collaborating

Please use Github to ask questions, open issues and send PRs. Thanks!

Tests can be run with: `dart test`

## 📝 License

See [LICENSE](https://github.com/flutterdata/flutter_data/blob/master/LICENSE).
