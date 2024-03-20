import 'package:flutter/material.dart';

class AddTaskToListView extends StatelessWidget {
  const AddTaskToListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets, // for keyboard
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.40,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Add Task to List',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (String value) {
                      // Only add value if it matches the allowed pattern
                      // setState(() {
                      //   tagController.text = value;
                      //   tagController.selection = TextSelection.fromPosition(
                      //     TextPosition(offset: tagController.text.length),
                      //   );
                      // });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add the tag to the list of tags
                  // context.read<TasksAPI>().addTag(tagController.text);
                  // Clear the text field
                  // tagController.clear();
                  // Close the modal
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
