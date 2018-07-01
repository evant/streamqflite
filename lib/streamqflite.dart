library sqlflight;

import 'dart:async';

import 'package:sqflite/sqflite.dart';

typedef Future<List<Map<String, dynamic>>> LazyQuery();

abstract class StreamDatabaseExecutor {
  final DatabaseExecutor _db;

  StreamDatabaseExecutor(DatabaseExecutor db) : _db = db;

  void _sendTableTrigger(Iterable<String> tables);

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
          [List<Object> args]) =>
      _db.rawQuery(sql, args);

  Future<List<Map<String, dynamic>>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List<Object> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    return _db.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  Future<int> insert(String table, Map<String, Object> values,
      {ConflictAlgorithm conflictAlgorithm}) async {
    var rowId =
        await _db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
    if (rowId != -1) {
      _sendTableTrigger([table]);
    }
    return rowId;
  }

  Future<int> rawInsert(Iterable<String> tables, String sql,
      [List<Object> args]) async {
    var rowId = await _db.rawInsert(sql, args);
    if (rowId != -1) {
      _sendTableTrigger(tables);
    }
    return rowId;
  }

  Future<int> delete(String table,
      {String where, List<Object> whereArgs}) async {
    var rows = await _db.delete(table, where: where, whereArgs: whereArgs);
    if (rows > 0) {
      _sendTableTrigger([table]);
    }
    return rows;
  }

  Future<int> rawDelete(Iterable<String> tables, String sql,
      [List<Object> args]) async {
    var rows = await _db.rawDelete(sql, args);
    if (rows > 0) {
      _sendTableTrigger(tables);
    }
    return rows;
  }

  Future<int> update(String table, Map<String, Object> values,
      {String where,
      List<Object> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) async {
    var rows = await _db.update(table, values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm);
    if (rows > 0) {
      _sendTableTrigger([table]);
    }
    return rows;
  }

  Future<int> rawUpdate(Iterable<String> tables, String sql,
      [List<Object> args]) async {
    var rows = await _db.rawUpdate(sql, args);
    if (rows > 0) {
      _sendTableTrigger(tables);
    }
    return rows;
  }

  Future<dynamic> execute(String sql, [List<Object> args]) =>
      _db.execute(sql, args);

  Future<dynamic> executeAndTrigger(Iterable<String> tables, String sql,
      [List<Object> args]) async {
    final dynamic result = await _db.execute(sql, args);
    _sendTableTrigger(tables);
    return result;
  }
}

class StreamDatabase extends StreamDatabaseExecutor {
  final StreamController<Set<String>> triggers = StreamController.broadcast();

  Database get _db => super._db as Database;

  StreamDatabase(Database db) : super(db);

  Future<T> transaction<T>(Future<T> action(StreamTransaction txn),
      {bool exclusive}) async {
    var notify = Set<String>();
    var result = await _db.transaction(
        (t) => action(StreamTransaction(t, notify)),
        exclusive: exclusive);
    _sendTableTrigger(notify);
    return result;
  }

  @override
  _sendTableTrigger(Iterable<String> tables) {
    triggers.add(tables.toSet());
  }

  Future close() => _db.close();

  QueryStream createRawQuery(Iterable<String> tables, String sql,
          [List<Object> args = const <Object>[]]) =>
      _createQuery(tables, () => _db.rawQuery(sql, args));

  QueryStream createQuery(String table,
          {bool distinct,
          List<String> columns,
          String where,
          List<Object> whereArgs,
          String groupBy,
          String having,
          String orderBy,
          int limit,
          int offset}) =>
      _createQuery(
          [table],
          () => _db.query(table,
              distinct: distinct,
              columns: columns,
              where: where,
              whereArgs: whereArgs,
              groupBy: groupBy,
              having: having,
              orderBy: orderBy,
              limit: limit,
              offset: offset));

  QueryStream _createQuery(Iterable<String> tables, LazyQuery query) {
    return QueryStream(triggers.stream
        .where((strings) {
          for (var table in tables) {
            if (strings.contains(table)) {
              return true;
            }
          }
          return false;
        })
        .map((strings) => query)
        .transform(_StartWith(query)));
  }
}

class _StartWith<T> extends StreamTransformerBase<T, T> {
  final T value;

  _StartWith(this.value);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller = StreamController();
    controller.add(value);
    controller.addStream(stream).whenComplete(() => controller.close());
    return controller.stream;
  }
}

class QueryStream extends Stream<LazyQuery> {
  final Stream<LazyQuery> _source;

  QueryStream(Stream<LazyQuery> source) : _source = source;

  @override
  StreamSubscription<LazyQuery> listen(void Function(LazyQuery event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _source.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Stream<T> mapToOne<T>(T mapper(Map<String, dynamic> row)) {
    return _source
        .asyncMap((query) => query())
        .where((rows) => rows.isNotEmpty)
        .map((rows) => mapper(rows.first));
  }

  Stream<T> mapToOneOrDefault<T>(
      T mapper(Map<String, dynamic> row), T defaultValue) {
    return _source
        .asyncMap((query) => query())
        .map((rows) => rows.isNotEmpty ? mapper(rows.first) : defaultValue);
  }

  Stream<List<T>> mapToList<T>(T mapper(Map<String, dynamic> row)) {
    return _source.asyncMap((query) => query()).map((rows) {
      var result = List<T>(rows.length);
      for (int i = 0; i < rows.length; i++) {
        result[i] = mapper(rows[i]);
      }
      return result;
    });
  }
}

class StreamTransaction extends StreamDatabaseExecutor {
  final Set<String> _notify;

  StreamTransaction(Transaction transaction, Set<String> notify)
      : _notify = notify,
        super(transaction);

  @override
  _sendTableTrigger(Iterable<String> tables) {
    _notify.addAll(tables);
  }
}
