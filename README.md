# streamqflite

[![Pub](https://img.shields.io/pub/v/streamqflite.svg)]()

A reactive stream wrapper around [sqflite](https://github.com/tekartik/sqflite) inspired by
[sqlbrite](https://github.com/square/sqlbrite).

## Getting Started

In your flutter project, add the dependency to your `pubspec.yaml`

```yaml
dependencies:
  ...
  streamqflite: ^1.0.0
```

## Usage

Import `streamqflite.dart`

```dart
import 'package:streamqflite/streamqflite.dart';
```

Wrap your database in a `StreamDatabase`.

```dart
var streamDb = StreamDatabase(db);
```

You can then listen to a query

```dart
// Emits a single row, doesn't emit if the row dosen't exist.
Stream<MyEntry> singleQuery = streamDb.createQuery("MyTable", where: 'id = ?', whereArgs: [id])
    .mapToOne((row) => MyEntry(row));

// Emits a single row, or the given default value if the row doesn't exist.
Stream<MyEntry> singleOrDefaultQuery = streamDb.createQuery("MyTable", where: 'id = ?', whereArgs: [id])
    .mapToOneOrDefault((row) => MyEntry(row), MyEntry.empty());

// Emits a list of rows.
Stream<List<MyEntry>> listQuery = streamDb.createQuery("MyTable", where: 'name LIKE ?', whereArgs: [query])
    .mapToList((row) => MyEntry(row));

var flexibleQuery = streamDb.createQuery("MyTable", where: 'name LIKE ?', whereArgs: [query])
    .asyncMap((query) => {
        // query is lazy, this lets you not even execute it if you don't need to.
        if (condition) {
            return query();
        } else {
            return Stream.empty();
        }
    }).map((rows) {
        // Do something with all the rows.
        return ...;
    });
```

These queries will run once to get the current data, then again whenever the given table is modified
though the `StreamDatabase`.
