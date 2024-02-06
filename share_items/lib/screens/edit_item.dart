import 'package:flutter/material.dart';
import 'package:share_items/widgets/message.dart';

import '../models/item.dart';

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditItemState();
}

class _EditItemState extends State<EditItemPage> {
  late TextEditingController priceController;

  @override
  void initState() {
    priceController =
        TextEditingController(text: widget.item.reserved.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Price'),
      ),
      body: ListView(
        children: [
          Text('Name: ${widget.item.title}'),
          Text('Description: ${widget.item.author}'),
          Text('Image: ${widget.item.genre}'),
          Text('Units: ${widget.item.quantity.toString()}'),
          TextField(
            controller: priceController,
            decoration: const InputDecoration(
              labelText: 'Price',
            ),
          ),
          ElevatedButton(
              onPressed: () {
                double? price = double.tryParse(priceController.text);
                if (price != null) {
                  Navigator.pop(
                      context,
                      Item(
                        id: widget.item.id,
                        title: widget.item.title,
                        author: widget.item.author,
                        genre: widget.item.genre,
                        quantity: widget.item.quantity,
                        reserved: price.toDouble(),
                      ));
                } else {
                  message(context, "Price must be a double", "Error");
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }
}
