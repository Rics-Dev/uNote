import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/list_provider.dart';
import 'package:toastification/toastification.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController listController = TextEditingController();


  @override
  void dispose() {
    listController.dispose();
    super.dispose();
  }

  void addList(String listName) async {
    final existingListDocument = await
        context.read<ListsAPI>().verifyExistingList(listName);
    if (existingListDocument == 0) {
      context.read<ListsAPI>().createList(listName);
      listController.clear();
    } else {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.minimal,
        context: context,
        title: const Text("List already exists"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
    // Add list to the database
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('Your list content goes here'),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            child: TextField(
              controller: listController,
              maxLines: 1,
              onSubmitted: (value) {
                addList(value);
              },
              decoration: InputDecoration(
                suffix: const Text('Add'),
                suffixIcon: GestureDetector(
                  onTap: () {
                    addList(listController.text);
                  },
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color.fromARGB(255, 0, 73, 133),
                  ),
                ),
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 0, 73, 133),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 235, 235, 235),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                hintText: 'Add a List',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
