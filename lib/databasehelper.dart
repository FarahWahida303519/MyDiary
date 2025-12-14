import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mydiary/diarylistdata.dart';

class DatabaseHelper {
  static const _databaseName = "mydiary.db"; //db name
  static const _databaseVersion = 1; //db version
  static const tablename = 'tb_diarydata'; //table name

  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db; //sqflite db obj

  // DATABASE INITIALIZATION
  Future<Database> get database async {
    //if db already exist,return it back
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  //initialize db and create table
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath(); //get device db path
    final path = join(dbPath, _databaseName); //combine path with db name

    //open db / create if not exists
    return await openDatabase(
      path,
      version: _databaseVersion,

      //create table
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

  // INSERT new record diary into db
  Future<int> insertMyList(DiaryListData mylist) async {
    final db = await database; //get db
    final data = mylist.toMap(); //convert diary obj to map
    data.remove('id'); //remove since autoincrement
    return await db.insert(tablename, data); //insert record
  }

  //read records with pagination
  Future<List<DiaryListData>> getMyListsPaginated(int limit, int offset) async {
    final db = await database; //get db

    final result = await db.query(
      tablename,
      orderBy: 'status DESC, id DESC', //sort by status &latest diary
      limit: limit, //num of records
      offset: offset, //start the index
    );
    //convert query result into list DiaryListData
    return result.map((e) => DiaryListData.fromMap(e)).toList();
  }

  //read record by id
  Future<DiaryListData?> getMyListById(int id) async {
    final db = await database; //get db
    //query table using id
    final result = await db.query(tablename, where: 'id = ?', whereArgs: [id]);
    //if record exist,convert to obj
    if (result.isNotEmpty) {
      return DiaryListData.fromMap(result.first);
    }
    return null; //return null if no record found
  }

  //Update record
  Future<int> updateMyList(DiaryListData mylist) async {
    final db = await database; //get db
    //update based on record
    return await db.update(
      tablename,
      mylist.toMap(),
      where: 'id = ?',
      whereArgs: [mylist.id],
    );
  }

  //delete by id
  Future<int> deleteMyList(int id) async {
    final db = await database; //get db
    //delete record
    return await db.delete(tablename, where: 'id = ?', whereArgs: [id]);
  }

  //Search by title/content
  Future<List<DiaryListData>> searchMyList(String keyword) async {
    final db = await database; //get db
    //query table
    final result = await db.query(
      tablename,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );
    //convert result into list DiaryListData
    return result.map((e) => DiaryListData.fromMap(e)).toList();
  }

  //Close db connection
  Future<void> closeDb() async {
    final db = await database;
    await db.close(); //close db
  }
}
