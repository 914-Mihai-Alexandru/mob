import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/item.dart';

// const String baseUrl = 'http://localhost:2305';
const String baseUrl = 'http://192.168.100.4:2325';

class ApiService {
  static final ApiService instance = ApiService._init();
  static final Dio dio = Dio();
  var logger = Logger();

  ApiService._init();

  Future<List<Item>> getBooks() async {
    logger.log(Level.info, 'getBooks');
    final response = await dio.get('$baseUrl/books');
    logger.log(Level.info, response.data);
    if (response.statusCode == 200) {
      final result = response.data as List;
      return result.map((e) => Item.fromJson(e)).toList();
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<List<Item>> getReservedBooks() async {
    logger.log(Level.info, 'getReservedBooks');
    final response = await dio.get('$baseUrl/reserved');
    logger.log(Level.info, response.data);
    if (response.statusCode == 200) {
      final result = response.data as List;
      return result.map((e) => Item.fromJson(e)).toList();
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<List<Item>> getDiscountedItems() async {
    logger.log(Level.info, 'getDiscountedItems');
    final response = await dio.get('$baseUrl/discounted');
    logger.log(Level.info, response.data);
    if (response.statusCode == 200) {
      final result = response.data as List;
      var items = result.map((e) => Item.fromJson(e)).toList();
      // return top 10 items sorted ascending by price and number of units
      items.sort((a, b) {
        int first = a.reserved.compareTo(b.reserved);
        if (first == 0) {
          return a.quantity.compareTo(b.quantity);
        } else {
          return first;
        }
      });
      return items.sublist(0, 10);
    } else {
      throw Exception(response.statusMessage);
    }
  }

  Future<Item> addItem(Item item) async {
    logger.log(Level.info, 'addItem: $item');
    final response =
        await dio.post('$baseUrl/book', data: item.toJsonWithoutId());
    logger.log(Level.info, response.data);
    if (response.statusCode == 200) {
      return Item.fromJson(response.data);
    } else {
      throw Exception(response.statusMessage);
    }
  }

  void deleteItem(int id) async {
    logger.log(Level.info, 'deleteItem: $id');
    final response = await dio.delete('$baseUrl/item/$id');
    logger.log(Level.info, response.data);
    if (response.statusCode != 200) {
      throw Exception(response.statusMessage);
    }
  }

  void updateReserveBook(int id) async {
    logger.log(Level.info, 'updateReserveBook: $id');
    final response = await dio.put('$baseUrl/reserve/$id');
    logger.log(Level.info, response.data);
    if (response.statusCode != 200) {
      throw Exception(response.statusMessage);
    }
  }

  Future<String> updateBorrowBook(int id) async {
    logger.log(Level.info, 'updateBorrowBook: $id');
    final response = await dio.put('$baseUrl/borrow/$id');
    logger.log(Level.info, response.data);
    if (response.statusCode != 200) {
      // throw Exception(response.statusMessage);
      return 'error';
    }
    return 'success';
  }
}
