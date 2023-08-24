@Timeout(const Duration(seconds: 2))
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:streamqflite/streamqflite.dart';
import "package:flutter_test/flutter_test.dart";

void main() {
  Database? db;
  StreamDatabase? streamDb;

  setUp(() {
    db = MockDatabase();
    streamDb = StreamDatabase(db!);
  });

  group("createQuery", () {
    test("delegates to db query", () async {
      final stream = streamDb!.createQuery(
        "Table",
        distinct: true,
        columns: ["column"],
        where: "where",
        whereArgs: ["whereArg"],
        groupBy: "groupBy",
        having: "having",
        orderBy: "orderBy",
        limit: 1,
        offset: 1,
      );
      (await stream.first)();
      verify(db!.query(
        "Table",
        distinct: true,
        columns: ["column"],
        where: "where",
        whereArgs: <dynamic>["whereArg"],
        groupBy: "groupBy",
        having: "having",
        orderBy: "orderBy",
        limit: 1,
        offset: 1,
      ));
    });

    test("triggers intial query", () async {
      final stream = streamDb!.createQuery("Table");
      expect(stream, emitsInOrder(<Matcher>[anything]));
    });

    test("triggers query again on insert", () async {
      when(db!.insert("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(0));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.insert("Table", <String, Object>{});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawInsert", () async {
      when(db!.insert("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(0));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.rawInsert(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on delete", () async {
      when(db!.delete("Table")).thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.delete("Table");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawDelete", () async {
      when(db!.rawDelete("")).thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.rawDelete(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on update", () async {
      when(db!.update("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.update("Table", {});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawUpdate", () async {
      when(db!.rawUpdate("")).thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.rawUpdate(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on executeAndTrigger", () async {
      when(db!.execute("")).thenAnswer((_) => Future<int>.value(0));
      final stream = streamDb!.createQuery("Table");
      await streamDb!.executeAndTrigger(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });

  group("createRawQuery", () {
    test("delegates to db rawQuery", () async {
      final stream = streamDb!.createRawQuery(
        ["Table"],
        "sql",
        ["whereArg"],
      );
      (await stream.first)();
      verify(db!.rawQuery(
        "sql",
        <dynamic>["whereArg"],
      ));
    });

    test("triggers intial query", () async {
      final stream = streamDb!.createRawQuery(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything]));
    });

    test("triggers query again on insert", () async {
      when(db!.insert("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(0));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.insert("Table", <String, Object>{});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawInsert", () async {
      when(db!.insert("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(0));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.rawInsert(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on delete", () async {
      when(db!.delete("Table")).thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.delete("Table");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawDelete", () async {
      when(db!.rawDelete("")).thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.rawDelete(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on update", () async {
      when(db!.update("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.update("Table", {});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawUpdate", () async {
      when(db!.rawUpdate("")).thenAnswer((_) => Future.value(1));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.rawUpdate(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on executeAndTrigger", () async {
      when(db!.execute("")).thenAnswer((_) => Future<int>.value(0));
      final stream = streamDb!.createRawQuery(["Table"], "");
      await streamDb!.executeAndTrigger(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });

  group("query", () {
    test("delegates to db query", () async {
      await streamDb!.query(
        "Table",
        distinct: true,
        columns: ["column"],
        where: "where",
        whereArgs: ["whereArg"],
        groupBy: "groupBy",
        having: "having",
        orderBy: "orderBy",
        limit: 1,
        offset: 1,
      );
      verify(db!.query(
        "Table",
        distinct: true,
        columns: ["column"],
        where: "where",
        whereArgs: <dynamic>["whereArg"],
        groupBy: "groupBy",
        having: "having",
        orderBy: "orderBy",
        limit: 1,
        offset: 1,
      ));
    });
  });

  group("rawQuery", () {
    test("delegates to db rawQuery", () async {
      await streamDb!.rawQuery(
        "sql",
        <String>["whereArg"],
      );
      verify(db!.rawQuery(
        "sql",
        <dynamic>["whereArg"],
      ));
    });
  });

  group("insert", () {
    test("delegates to db insert", () async {
      await streamDb!.insert("Table", <String, Object>{},
          conflictAlgorithm: ConflictAlgorithm.fail);
      verify(db!.insert("Table", <String, dynamic>{},
          conflictAlgorithm: ConflictAlgorithm.fail));
    });
  });

  group("rawInsert", () {
    test("delegates to db rawInsert", () async {
      await streamDb!.rawInsert(["Table"], "sql", <String>["arg"]);
      verify(db!.rawInsert("sql", <dynamic>["arg"]));
    });
  });

  group("delete", () {
    test("delegates to db delete", () async {
      when(db!.delete(
              // ignore: argument_type_not_assignable
              any,
              // ignore: argument_type_not_assignable
              where: anyNamed("where"),
              // ignore: argument_type_not_assignable
              whereArgs: anyNamed("whereArgs")))
          .thenAnswer((_) => Future.value(1));
      await streamDb!.delete("Table", where: "where", whereArgs: ["whereArg"]);
      verify(
          db!.delete("Table", where: "where", whereArgs: <dynamic>["whereArg"]));
    });
  });

  group("rawDelete", () {
    test("delegates to db rawDelete", () async {
      when(db!.rawDelete(
              // ignore: argument_type_not_assignable
              any,
              // ignore: argument_type_not_assignable
              any))
          .thenAnswer((_) => Future.value(1));
      await streamDb!.rawDelete(["Table"], "sql", ["arg"]);
      verify(db!.rawDelete("sql", <dynamic>["arg"]));
    });
  });

  group("update", () {
    test("delegates to db update", () async {
      when(db!.update(
              // ignore: argument_type_not_assignable
              any,
              // ignore: argument_type_not_assignable
              any,
              // ignore: argument_type_not_assignable
              where: anyNamed("where"),
              // ignore: argument_type_not_assignable
              whereArgs: anyNamed("whereArgs"),
              // ignore: argument_type_not_assignable
              conflictAlgorithm: anyNamed("conflictAlgorithm")))
          .thenAnswer((_) => Future.value(1));
      await streamDb!.update("Table", {},
          where: "where",
          whereArgs: ["whereArg"],
          conflictAlgorithm: ConflictAlgorithm.fail);
      verify(db!.update("Table", <String, dynamic>{},
          where: "where",
          whereArgs: <dynamic>["whereArg"],
          conflictAlgorithm: ConflictAlgorithm.fail));
    });
  });

  group("rawUpdate", () {
    test("delegates to db rawUpdate", () async {
      when(db!.rawUpdate(
              // ignore: argument_type_not_assignable
              any,
              // ignore: argument_type_not_assignable
              any))
          .thenAnswer((_) => Future.value(1));
      await streamDb!.rawUpdate(["Table"], "sql", ["arg"]);
      verify(db!.rawUpdate("sql", <dynamic>["arg"]));
    });
  });

  group("execute", () {
    test("delegates to db execute", () async {
      await streamDb!.execute("sql", <String>["arg"]);
      verify(db!.execute("sql", <dynamic>["arg"]));
    });
  });

  group("transaction", () {
    test("triggers query again after transaction completes", () async {
      final transaction = MockTransaction();
      when(transaction.insert("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(0));
      when(db!.transaction<dynamic>(
              // ignore: argument_type_not_assignable
              any,
              // ignore: argument_type_not_assignable
              exclusive: anyNamed("exclusive")))
          .thenAnswer((invocation) {
        Function f = invocation.positionalArguments[0] as Function;
        Future<int> result = f(transaction) as Future<int>;
        return result;
      });
      final stream = streamDb!.createQuery("Table");
      await streamDb!.transaction((transaction) {
        return transaction.insert("Table", <String, Object>{});
      });
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });

  group("batch", () {
    test("trigger query again after batch is commited", () async {
      final batch = MockBatch();
      when(batch.insert("Table", <String, Object>{}))
          .thenAnswer((_) => Future.value(0));
      when(db!.batch()).thenAnswer((_) => batch);
      final stream = streamDb!.createQuery("Table");
      final streamBatch = streamDb!.batch();
      streamBatch.insert("Table", <String, Object>{});
      await streamBatch.commit();

      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });
}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

class MockBatch extends Mock implements Batch {}
