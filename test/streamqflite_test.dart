@Timeout(const Duration(seconds: 2))
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:streamqflite/streamqflite.dart';
import "package:flutter_test/flutter_test.dart";

void main() {
  Database db;
  StreamDatabase streamDb;

  setUp(() {
    db = MockDatabase();
    streamDb = StreamDatabase(db);
  });

  group("createQuery", () {
    test("delegates to db query", () async {
      var stream = streamDb.createQuery(
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
      verify(db.query(
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
      var stream = streamDb.createQuery("Table");
      expect(stream, emitsInOrder(<Matcher>[anything]));
    });

    test("triggers query again on insert", () async {
      when(db.insert("Table", <String, Object>{})).thenReturn(Future.value(0));
      var stream = streamDb.createQuery("Table");
      await streamDb.insert("Table", {});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawInsert", () async {
      when(db.insert("Table", <String, Object>{})).thenReturn(Future.value(0));
      var stream = streamDb.createQuery("Table");
      await streamDb.rawInsert(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on delete", () async {
      when(db.delete("Table")).thenReturn(Future.value(1));
      var stream = streamDb.createQuery("Table");
      await streamDb.delete("Table");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawDelete", () async {
      when(db.rawDelete("")).thenReturn(Future.value(1));
      var stream = streamDb.createQuery("Table");
      await streamDb.rawDelete(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on update", () async {
      when(db.update("Table", <String, Object>{})).thenReturn(Future.value(1));
      var stream = streamDb.createQuery("Table");
      await streamDb.update("Table", {});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawUpdate", () async {
      when(db.rawUpdate("")).thenReturn(Future.value(1));
      var stream = streamDb.createQuery("Table");
      await streamDb.rawUpdate(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on executeAndTrigger", () async {
      when(db.execute("")).thenReturn(Future.value(0));
      var stream = streamDb.createQuery("Table");
      await streamDb.executeAndTrigger(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });

  group("createRawQuery", () {
    test("delegates to db rawQuery", () async {
      var stream = streamDb.createRawQuery(
        ["Table"],
        "sql",
        ["whereArg"],
      );
      (await stream.first)();
      verify(db.rawQuery(
        "sql",
        <dynamic>["whereArg"],
      ));
    });

    test("triggers intial query", () async {
      var stream = streamDb.createRawQuery(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything]));
    });

    test("triggers query again on insert", () async {
      when(db.insert("Table", <String, Object>{})).thenReturn(Future.value(0));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.insert("Table", {});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawInsert", () async {
      when(db.insert("Table", <String, Object>{})).thenReturn(Future.value(0));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.rawInsert(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on delete", () async {
      when(db.delete("Table")).thenReturn(Future.value(1));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.delete("Table");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawDelete", () async {
      when(db.rawDelete("")).thenReturn(Future.value(1));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.rawDelete(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on update", () async {
      when(db.update("Table", <String, Object>{})).thenReturn(Future.value(1));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.update("Table", {});
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on rawUpdate", () async {
      when(db.rawUpdate("")).thenReturn(Future.value(1));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.rawUpdate(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });

    test("triggers query again on executeAndTrigger", () async {
      when(db.execute("")).thenReturn(Future.value(0));
      var stream = streamDb.createRawQuery(["Table"], "");
      await streamDb.executeAndTrigger(["Table"], "");
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });

  group("query", () {
    test("delegates to db query", () async {
      await streamDb.query(
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
      verify(db.query(
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
      await streamDb.rawQuery(
        "sql",
        ["whereArg"],
      );
      verify(db.rawQuery(
        "sql",
        <dynamic>["whereArg"],
      ));
    });
  });

  group("insert", () {
    test("delegates to db insert", () async {
      await streamDb.insert("Table", {},
          conflictAlgorithm: ConflictAlgorithm.fail);
      verify(db.insert("Table", <String, dynamic>{},
          conflictAlgorithm: ConflictAlgorithm.fail));
    });
  });

  group("rawInsert", () {
    test("delegates to db rawInsert", () async {
      await streamDb.rawInsert(["Table"], "sql", ["arg"]);
      verify(db.rawInsert("sql", <dynamic>["arg"]));
    });
  });

  group("delete", () {
    test("delegates to db delete", () async {
      when(db.delete(
              // ignore: argument_type_not_assignable
              typed(any),
              // ignore: argument_type_not_assignable
              where: typed(any, named: "where"),
              // ignore: argument_type_not_assignable
              whereArgs: typed(any, named: "whereArgs")))
          .thenReturn(Future.value(1));
      await streamDb.delete("Table", where: "where", whereArgs: ["whereArg"]);
      verify(
          db.delete("Table", where: "where", whereArgs: <dynamic>["whereArg"]));
    });
  });

  group("rawDelete", () {
    test("delegates to db rawDelete", () async {
      when(db.rawDelete(
              // ignore: argument_type_not_assignable
              typed(any),
              // ignore: argument_type_not_assignable
              typed(any)))
          .thenReturn(Future.value(1));
      await streamDb.rawDelete(["Table"], "sql", ["arg"]);
      verify(db.rawDelete("sql", <dynamic>["arg"]));
    });
  });

  group("update", () {
    test("delegates to db update", () async {
      when(db.update(
              // ignore: argument_type_not_assignable
              typed(any),
              // ignore: argument_type_not_assignable
              typed(any),
              // ignore: argument_type_not_assignable
              where: typed(any, named: "where"),
              // ignore: argument_type_not_assignable
              whereArgs: typed(any, named: "whereArgs"),
              // ignore: argument_type_not_assignable
              conflictAlgorithm: typed(any, named: "conflictAlgorithm")))
          .thenReturn(Future.value(1));
      await streamDb.update("Table", {},
          where: "where",
          whereArgs: ["whereArg"],
          conflictAlgorithm: ConflictAlgorithm.fail);
      verify(db.update("Table", <String, dynamic>{},
          where: "where",
          whereArgs: <dynamic>["whereArg"],
          conflictAlgorithm: ConflictAlgorithm.fail));
    });
  });

  group("rawUpdate", () {
    test("delegates to db rawUpdate", () async {
      when(db.rawUpdate(
              // ignore: argument_type_not_assignable
              typed(any),
              // ignore: argument_type_not_assignable
              typed(any)))
          .thenReturn(Future.value(1));
      await streamDb.rawUpdate(["Table"], "sql", ["arg"]);
      verify(db.rawUpdate("sql", <dynamic>["arg"]));
    });
  });

  group("execute", () {
    test("delegates to db execute", () async {
      await streamDb.execute("sql", ["arg"]);
      verify(db.execute("sql", <dynamic>["arg"]));
    });
  });

  group("transaction", () {
    test("triggers query again after transaction completes", () async {
      var transaction = MockTransaction();
      when(transaction.insert("Table", <String, Object>{}))
          .thenReturn(Future.value(0));
      when(db.transaction<dynamic>(
          // ignore: argument_type_not_assignable
          typed(any),
          // ignore: argument_type_not_assignable
          exclusive: typed(any, named: "exclusive"))).thenAnswer((invocation) {
        Function f = invocation.positionalArguments[0];
        return f(transaction);
      });
      var stream = streamDb.createQuery("Table");
      await streamDb.transaction((transaction) {
        return transaction.insert("Table", {});
      });
      expect(stream, emitsInOrder(<Matcher>[anything, anything]));
    });
  });
}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}
