import 'dart:async';
import 'package:gbooks/models/shelf.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static const _databaseName = "Shelf.db";
  static const _databaseVersion = 1;

  static const table = 'shelf';

  static const columnId = 'id';
  static const columnExternalId = 'externalId';
  static const columnReadStatus = 'readStatus';
  static const columnOwnership = 'ownership';

  // Make this a singleton class.
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and store the reference.
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnExternalId TEXT NOT NULL,
            $columnReadStatus INTEGER,
            $columnOwnership INTEGER
          )
          ''');
  }

  // Insert a book (shelf) into the database.
  static Future<void> insert(Shelf book) async {
    // Get a reference to the database.
    final Database db = await instance.database;

    // Insert the book into the correct table.
    await db.insert(
      table,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Get all books from the shelf.
  static Future<List<Shelf>> getAllBooksFromShelf() async {
    // Get a reference to the database.
    final Database db = await instance.database;

    // Query the table for all The books.
    final List<Map<String, dynamic>> maps = await db.query(table);

    // Convert the List<Map<String, dynamic> into a List<Shelf>.
    return List.generate(maps.length, (i) {
      return Shelf.fromMap(maps[i]);
    });
  }

// Get a single book from shelf.
  static Future<Shelf> getASingleBookFromShelf(int id) async {
    // Get a reference to the database.
    final Database db = await instance.database;

    // Get the book from the database.
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Convert the Map<String, dynamic> into a shelf.
    return Shelf.fromMap(maps.first);
  }

  // Get a single book from shelf.
  static Future<Shelf?> getASingleBookByExternalId(String externalId) async {
    // Get a reference to the database.
    final Database db = await instance.database;

    // Get the book from the database.
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'externalId = ?',
      whereArgs: [externalId],
    );

    if (maps.isEmpty) {
      return null;
    }
    // Convert the Map<String, dynamic> into a shelf.
    return Shelf.fromMap(maps.first);
  }

// Update a book.
  static Future<void> update(Shelf book) async {
    // Get a reference to the database.
    final db = await instance.database;

    // Update the given Book.
    await db.update(
      table,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

// Delete a from from the shelf.
  static Future<void> delete(int id) async {
    // Get a reference to the database.
    final db = await instance.database;

    // Remove the book from the shelf from the database.
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
