import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mydiary/diarylistdata.dart';

class DatabaseHelper {
  static const _databaseName = "mydiary.db";
  static const _databaseVersion = 1;
  static const tablename = 'tb_diarydata';

  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  // -------------------------------------------------
  // DATABASE INITIALIZATION
  // -------------------------------------------------
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tablename (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            status TEXT,
            date TEXT,
            imagename TEXT
          )
        ''');
      },
    );
  }

  // -------------------------------------------------
  // INSERT
  // -------------------------------------------------
  Future<int> insertMyList(DiaryListData mylist) async {
    final db = await database;
    final data = mylist.toMap();
    data.remove('id');
    return await db.insert(tablename, data);
  }

  // -------------------------------------------------
  // READ (PAGINATION)
  // -------------------------------------------------
  Future<List<DiaryListData>> getMyListsPaginated(
      int limit, int offset) async {
    final db = await database;
    final result = await db.query(
      tablename,
      orderBy: 'status DESC, id DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((e) => DiaryListData.fromMap(e)).toList();
  }

  // -------------------------------------------------
  // COUNT
  // -------------------------------------------------
  Future<int> getTotalCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as total FROM $tablename');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // -------------------------------------------------
  // GET BY ID
  // -------------------------------------------------
  Future<DiaryListData?> getMyListById(int id) async {
    final db = await database;
    final result =
        await db.query(tablename, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return DiaryListData.fromMap(result.first);
    }
    return null;
  }

  // -------------------------------------------------
  // UPDATE
  // -------------------------------------------------
  Future<int> updateMyList(DiaryListData mylist) async {
    final db = await database;
    return await db.update(
      tablename,
      mylist.toMap(),
      where: 'id = ?',
      whereArgs: [mylist.id],
    );
  }

  // -------------------------------------------------
  // DELETE
  // -------------------------------------------------
  Future<int> deleteMyList(int id) async {
    final db = await database;
    return await db.delete(
      tablename,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------
  // SEARCH
  // -------------------------------------------------
  Future<List<DiaryListData>> searchMyList(String keyword) async {
    final db = await database;
    final result = await db.query(
      tablename,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((e) => DiaryListData.fromMap(e)).toList();
  }

  // -------------------------------------------------
  // CLOSE DATABASE
  // -------------------------------------------------
  Future<void> closeDb() async {
    final db = await database;
    await db.close();
  }
}
