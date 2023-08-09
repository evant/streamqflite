/*
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
*/
