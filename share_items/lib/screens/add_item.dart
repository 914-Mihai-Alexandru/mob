import 'package:flutter/material.dart';
import 'package:share_items/models/item.dart';
import 'package:share_items/widgets/message.dart';
import 'package:share_items/widgets/text_box.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<StatefulWidget> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController genreController;
  late TextEditingController reservedController;
  late TextEditingController quantityController;

  @override
  void initState() {
    titleController = TextEditingController();
    authorController = TextEditingController();
    genreController = TextEditingController();
    reservedController = TextEditingController();
    quantityController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: ListView(
        children: [
          TextBox(titleController, 'Title'),
          TextBox(authorController, 'Author'),
          TextBox(genreController, 'Genre'),
          TextBox(reservedController, 'Reserved'),
          TextBox(quantityController, 'Quantity'),
          ElevatedButton(
              onPressed: () {
                String title = titleController.text;
                String author = authorController.text;
                String genre = genreController.text;
                double? reserved = double.tryParse(reservedController.text);
                int? quantity = int.tryParse(quantityController.text);
                if (title.isNotEmpty &&
                    author.isNotEmpty &&
                    genre.isNotEmpty &&
                    quantity != null &&
                    reserved != null) {
                  Navigator.pop(
                      context,
                      Item(
                          title: title,
                          author: author,
                          genre: genre,
                          quantity: quantity,
                          reserved: reserved));
                } else {
                  if (title.isEmpty) {
                    message(context, 'Title is required', "Error");
                  } else if (author.isEmpty) {
                    message(context, 'Author is required', "Error");
                  } else if (genre.isEmpty) {
                    message(context, 'Genre is required', "Error");
                  } else if (quantity == null) {
                    message(context, 'Quantity must be an integer', "Error");
                  } else if (reserved == null) {
                    message(context, 'Reserved must be a double', "Error");
                  }
                }
              },
              child: const Text('Save'))
        ],
      ),
    );
  }
}
