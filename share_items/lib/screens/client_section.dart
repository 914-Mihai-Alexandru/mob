import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:share_items/api/api.dart';
import 'package:share_items/models/item.dart';
import 'package:share_items/screens/add_item.dart';
import 'package:share_items/screens/edit_item.dart';
import 'package:share_items/screens/items_list_page.dart';
import 'package:share_items/screens/reserved_section.dart';
import 'package:share_items/widgets/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/network.dart';
import '../services/database_helper.dart';

class PriceSection extends StatefulWidget {
  @override
  _PriceSectionState createState() => _PriceSectionState();
}

class _PriceSectionState extends State<PriceSection> {
  var logger = Logger();
  bool online = true;
  late List<Item> books = [];
  bool isLoading = false;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _connectivity = NetworkConnectivity.instance;
  String string = '';

  @override
  void initState() {
    super.initState();
    connection();
  }

  void connection() {
    _connectivity.initialize();
    _connectivity.myStream.listen((source) {
      _source = source;
      var newStatus = true;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string =
              _source.values.toList()[0] ? 'Mobile: online' : 'Mobile: offline';
          break;
        case ConnectivityResult.wifi:
          string =
              _source.values.toList()[0] ? 'Wifi: online' : 'Wifi: offline';
          newStatus = _source.values.toList()[0] ? true : false;
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
          newStatus = false;
      }
      if (online != newStatus) {
        online = newStatus;
      }
      getBooks();
    });
  }

  getBooks() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    if (online) {
      try {
        books = await ApiService.instance.getBooks();
        DatabaseHelper.updateBooks(books);
      } catch (e) {
        logger.e(e);
        message(context, "Error connecting to the server", "Error");
      }
    } else {
      books = await DatabaseHelper.getBooks();
    }

    setState(() {
      isLoading = false;
    });
  }

  saveItem(Item item) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    if (online) {
      try {
        final Item received = await ApiService.instance.addItem(item);
        DatabaseHelper.addItem(received);
      } catch (e) {
        logger.e(e);
        message(context, "Error connecting to the server", "Error");
      }
    } else {
      message(context, "Operation not available", "Error");
    }
    setState(() {
      isLoading = false;
    });
  }

  // reserved book function:
  void reservedBook(Item item) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    if (online) {
      try {
        ApiService.instance.updateReserveBook(item.id!);
        DatabaseHelper.updateReserve(item.id!);
      } catch (e) {
        logger.e(e);
        message(context, "Error connecting to the server", "Error");
      }
    } else {
      message(context, "Operation not available", "Error");
    }
    setState(() {
      isLoading = false;
    });
  }

  void borrowBook(Item item) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    if (online) {
      try {
        String response = await ApiService.instance.updateBorrowBook(item.id!);
        if (response == 'success') {
          DatabaseHelper.updateBorrow(item.id!);
          message(context, 'Successfuly borrowed the book', 'Success');
        } else {
          message(context, "Error borrowing book", "Error");
        }
      } catch (e) {
        logger.e(e);
        message(context, "Error borrowing book", "Error");
      }
    } else {
      message(context, "Operation not available", "Error");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client section'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ListView(
                children: [
                  ListView.builder(
                    itemBuilder: ((context, index) {
                      return ListTile(
                        title: Text(books[index].title),
                        subtitle: Text(
                            '${books[index].id}, ${books[index].author}, ${books[index].genre}, ${books[index].quantity}'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ItemsListPage(books[index].id!)));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit button press
                                reservedBook(books[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Handle delete button press
                                borrowBook(books[index]);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    itemCount: books.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!online) {
            message(context, "Operation not available", "Error");
            return;
          }
          Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => ReservedSection())))
              .then((value) {
            if (value != null) {
              setState(() {
                saveItem(value);
              });
            }
          });
        },
        tooltip: 'Reserved books',
        child: const Text('Reserved'),
      ),
    );
  }

  void showDeleteConfirmationDialog(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${item.title}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Handle delete operation here
                Navigator.of(context).pop(); // Close the dialog
                // deleteItem(item);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // void deleteItem(Item item) async {
  //   try {
  //     await ApiService.instance.deleteItem(item.id!);
  //     DatabaseHelper.deleteItem(item.id!);
  //     getBooks();
  //   } catch (e) {
  //     logger.e(e);
  //     message(context, "Error deleting item", "Error");
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }
}
