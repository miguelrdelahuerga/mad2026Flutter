import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'oasis_v3.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE coordinates(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            latitude REAL,
            longitude REAL,
            type TEXT,
            is_operational INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  // INSERTAR
  Future<void> insertCoordinate(Position position, {String type = 'water', int isOperational = 1}) async {
    final db = await database;
    await db.insert('coordinates', {
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'type': type,
      'is_operational': isOperational
    });
  }

  // LEER
  Future<List<Map<String, dynamic>>> getCoordinates() async {
    final db = await database;
    return await db.query('coordinates');
  }

  // BORRAR
  Future<void> deleteCoordinate(String timestamp) async {
    final db = await database;
    await db.delete('coordinates', where: 'timestamp = ?', whereArgs: [timestamp]);
  }

  // ACTUALIZAR
  // ACTUALIZAR (Añadimos el tipo y el estado operativo)
  Future<void> updateCoordinate(String timestamp, String newLat, String newLong, String newType, int isOperational) async {
    final db = await database;
    await db.update(
      'coordinates',
      {
        'latitude': newLat,
        'longitude': newLong,
        'type': newType,
        'is_operational': isOperational
      },
      where: 'timestamp = ?',
      whereArgs: [timestamp],
    );
  }
}