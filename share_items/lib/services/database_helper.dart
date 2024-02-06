import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _databaseName = 'shareitems.db';
  static Logger logger = Logger();

  static Future<Database> _getDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _databaseName);
    return await openDatabase(path, version: _version,
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, title TEXT, author TEXT, genre TEXT, quantity INTEGER, reserved REAL)');
    });
  }

  // get all items
  static Future<List<Item>> getBooks() async {
    final db = await _getDB();
    final result = await db.query('items');
    logger.log(Level.info, "getItems: $result");
    return result.map((e) => Item.fromJson(e)).toList();
  }

  // get books sorted by quantity and genre:
  static Future<List<Item>> getBooksSorted() async {
    final db = await _getDB();
    final result = await db.query('items', orderBy: 'quantity, genre');
    logger.log(Level.info, "getBooksSorted: $result");
    return result.map((e) => Item.fromJson(e)).toList();
  }

  // get all categories
  static Future<List<Item>> getReservedBooks() async {
    final db = await _getDB();
    final result = await db.query('items', where: 'reserved > 0');
    logger.log(Level.info, "getCategories: $result");
    return result.map((e) => Item.fromJson(e)).toList();
  }

  // add item
  static Future<Item> addItem(Item item) async {
    final db = await _getDB();
    final id = await db.insert('items', item.toJsonWithoutId(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.log(Level.info, "addItem: $id");
    return item.copy(id: id);
  }

  // update price if an item
  static Future<int> updateBorrow(int id) async {
    final db = await _getDB();
    final result = await db.rawUpdate(
        'UPDATE items SET reserved = reserved - 1 WHERE id = ?', [id]);
    logger.log(Level.info, "updateBorrow: $result");
    return result;
  }

  // update price if an item
  static Future<int> updateReserve(int id) async {
    final db = await _getDB();
    final result = await db.rawUpdate(
        'UPDATE items SET reserved = reserved + 1 WHERE id = ?', [id]);
    logger.log(Level.info, "updateReserve: $result");
    return result;
  }

  // update categories
  static Future<void> updateBooks(List<Item> items) async {
    final db = await _getDB();
    await db.delete('items');
    for (var i = 0; i < items.length; i++) {
      await db.insert('items', items[i].toJsonWithoutId());
    }
    logger.log(Level.info, "updateBooks: $items");
  }

  // close database
  static Future<void> close() async {
    final db = await _getDB();
    await db.close();
  }
}
