import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = await getDatabasesPath();
    final String databaseName = 'my_database.db';
    final String databasePath = '$path/$databaseName';

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE my_table(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, complete BOOLEAN)');
      },
    );
  }

  Future<int> insertData(data) async {
    final Database db = await database;
    return await db.insert('my_table', data);
  }

  Future<int> updateData(int id, Map<String, dynamic> data) async {
    final Database db = await database;
    return await db.update('my_table', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteData(int id) async {
    final Database db = await database;
    return await db.delete('my_table', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final Database db = await database;
    final abc = await db.query('my_table');
    print(abc);
    return abc;
  }
}
