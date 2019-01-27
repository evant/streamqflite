library sqlflight;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

/// Represents a query to be executed, invoking it will actually execute the
/// query and returns a [Future] of the result.
typedef Future<List<Map<String, dynamic>>> LazyQuery();

///
/// Common API for [StreamDatabase] and [StreamTransaction] to execute SQL commands
///
abstract class StreamDatabaseExecutor {
  final DatabaseExecutor _db;

  StreamDatabaseExecutor(DatabaseExecutor db) : _db = db;

  @protected
  void sendTableTrigger(Iterable<String> tables);

  /// Execute an SQL query with no return value.
  /// No notifications will be sent to queries if [sql] affects the data of the
  /// table.
  Future<void> execute(String sql, [List<dynamic> arguments]) =>
      _db.execute(sql, arguments);

  /// Execute an SQL query with no return value.
  /// A notification to queries for [tables] will be sent after the statement is
  /// executed.
  Future<void> executeAndTrigger(Iterable<String> tables, String sql,
      [List<dynamic> arguments]) async {
    await _db.execute(sql, arguments);
    sendTableTrigger(tables);
  }

  /// Execute a raw SQL INSERT query
  /// A notification to queries for [tables] will be sent after the statement is
  /// executed.
  ///
  /// @return The inserted record id.
  Future<int> rawInsert(Iterable<String> tables, String sql,
      [List<dynamic> arguments]) async {
    var rowId = await _db.rawInsert(sql, arguments);
    if (rowId != -1) {
      sendTableTrigger(tables);
    }
    return rowId;
  }

  /// Insert a row into a table, where the keys of [values] correspond to
  /// column names.
  /// A notification to queries for [table] will be sent after the statement is
  /// executed.
  Future<int> insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) async {
    var rowId =
        await _db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
    if (rowId != -1) {
      sendTableTrigger([table]);
    }
    return rowId;
  }

  /// Execute a raw SQL SELECT query.
  ///
  /// @return A list of rows that were found.
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
          [List<dynamic> arguments]) =>
      _db.rawQuery(sql, arguments);

  /// Helper to query a table.
  ///
  /// @param distinct true if you want each row to be unique, false otherwise.
  /// @param table The table names to compile the query against.
  /// @param columns A list of which columns to return. Passing null will
  ///
  ///
  ///            return all columns, which is discouraged to prevent reading
  ///            data from storage that isn't going to be used.
  /// @param where A filter declaring which rows to return, formatted as an SQL
  ///            WHERE clause (excluding the WHERE itself). Passing null will
  ///            return all rows for the given URL.
  /// @param groupBy A filter declaring how to group rows, formatted as an SQL
  ///            GROUP BY clause (excluding the GROUP BY itself). Passing null
  ///            will cause the rows to not be grouped.
  /// @param having A filter declare which row groups to include in the cursor,
  ///            if row grouping is being used, formatted as an SQL HAVING
  ///            clause (excluding the HAVING itself). Passing null will cause
  ///            all row groups to be included, and is required when row
  ///            grouping is not being used.
  /// @param orderBy How to order the rows, formatted as an SQL ORDER BY clause
  ///            (excluding the ORDER BY itself). Passing null will use the
  ///            default sort order, which may be unordered.
  /// @param limit Limits the number of rows returned by the query,
  /// @param offset starting index,
  ///
  /// @return The items found.
  ///
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

  /// Execute a raw SQL SELECT query.
  /// A notification to queries for [tables] will be sent after the statement is
  /// executed.
  ///
  /// @return a list of rows that were found.
  Future<int> rawUpdate(Iterable<String> tables, String sql,
      [List<Object> args]) async {
    var rows = await _db.rawUpdate(sql, args);
    if (rows > 0) {
      sendTableTrigger(tables);
    }
    return rows;
  }

  /// Convenience method for updating rows in the database.
  ///
  /// Update [table] with [values], a map from column names to new column
  /// values. null is a valid value that will be translated to NULL.
  ///
  /// [where] is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details.
  ///
  /// A notification to queries for [table] will be sent after the statement is
  /// executed.
  Future<int> update(String table, Map<String, Object> values,
      {String where,
      List<Object> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) async {
    var rows = await _db.update(table, values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm);
    if (rows > 0) {
      sendTableTrigger([table]);
    }
    return rows;
  }

  /// Executes a raw SQL DELETE query.
  ///
  /// A notification to queries for [tables] will be sent after the statement is
  /// executed.
  ///
  /// @return The number of changes made.
  Future<int> rawDelete(Iterable<String> tables, String sql,
      [List<Object> args]) async {
    var rows = await _db.rawDelete(sql, args);
    if (rows > 0) {
      sendTableTrigger(tables);
    }
    return rows;
  }

  /// Convenience method for deleting rows in the database.
  ///
  /// Delete from [table]
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing null
  /// will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details
  ///
  /// A notification to queries for [table] will be sent after the statement is
  /// executed.
  ///
  /// @return The number of rows affected if a whereClause is passed in, 0
  /// otherwise. To remove all rows and get a count pass "1" as the
  /// whereClause.
  Future<int> delete(String table,
      {String where, List<Object> whereArgs}) async {
    var rows = await _db.delete(table, where: where, whereArgs: whereArgs);
    if (rows > 0) {
      sendTableTrigger([table]);
    }
    return rows;
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
  sendTableTrigger(Iterable<String> tables) {
    _notify.addAll(tables);
  }
}

///
/// StreamDatabase to send sql commands, created by wrapping a [Database].
///
class StreamDatabase extends StreamDatabaseExecutor {
  final StreamController<Set<String>> triggers = StreamController.broadcast();
  final Database _db;

  StreamDatabase(Database db)
      : _db = db,
        super(db);

  /// Calls in action must only be done using the transaction object
  /// using the database will trigger a dead-lock.
  Future<T> transaction<T>(Future<T> action(StreamTransaction txn),
      {bool exclusive}) async {
    var notify = Set<String>();
    var result = await _db.transaction(
            (t) => action(StreamTransaction(t, notify)),
        exclusive: exclusive);
    sendTableTrigger(notify);
    return result;
  }

  /// Tell if the database is open, returns false once close has been called.
  bool get isOpen => _db.isOpen;

  @override
  void sendTableTrigger(Iterable<String> tables) {
    triggers.add(tables.toSet());
  }

  /// Close the database. Cannot be accessed anymore.
  Future close() => _db.close();

  /// Creates a [Stream] that will notify listeners with a [LazyQuery] for
  /// execution. Listeners will always receive an immediate notification with
  /// initial data as well as subsequent notifications when the supplied [tables]
  /// data changes through [insert], [update], and [delete] calls. Close the
  /// [Stream] when you no longer want updates to the query.
  ///
  /// @see [rawQuery]
  QueryStream createRawQuery(Iterable<String> tables, String sql,
      [List<Object> arguments = const <Object>[]]) =>
      _createQuery(tables, () => _db.rawQuery(sql, arguments));

  /// Creates a [Stream] that will notify listeners with a [LazyQuery] for
  /// execution. Listeners will always receive an immediate notification with
  /// initial data as well as subsequent notifications when the supplied [tables]
  /// data changes through [insert], [update], and [delete] calls. Close the
  /// [Stream] when you no longer want updates to the query.
  ///
  /// @see [query]
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
