 import 'package:flutter/material.dart';

Widget addTaskView(context, addTaskDialogOpened, taskController) {
    return AnimatedOpacity(
          opacity: addTaskDialogOpened ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 5000),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 5000),
            height: addTaskDialogOpened
                ? MediaQuery.of(context).size.height * 0.62
                : 0.0,
            child: Wrap(
              // Use Wrap widget to center the content vertically
              children: [
                Center(
                  // Center the content vertically
                  child: Padding(
                    padding: MediaQuery.of(context)
                        .viewInsets, // Adjust for keyboard
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      height: MediaQuery.of(context).size.height *
                          0.21, // 30% of screen height
                      child: Column(
                        children: [
                          TextField(
                            controller: taskController,
                            autofocus:
                                true, // Automatically focus the input field
                            decoration: const InputDecoration(
                              labelText: 'Enter Task',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType
                                .text, // Set appropriate keyboard type
                            textInputAction: TextInputAction
                                .done, // Dismiss keyboard on Done
                            onSubmitted: (_) => Navigator.pop(context, true),
                          ),
                          const SizedBox(height: 10.0),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     TextButton(
                          //       onPressed: () {
                          //         Navigator.pop(context); // Close bottom sheet
                          //       },
                          //       child: const Text('Cancel'),
                          //     ),
                          //     const SizedBox(width: 10.0),
                          //     ElevatedButton(
                          //       onPressed: () {
                          //         // Handle task submission, e.g.,
                          //         _addTask(taskController.text);
                          //         Navigator.pop(context); // Close bottom sheet
                          //       },
                          //       child: const Text('Submit'),
                          //     ),
                          //   ],
                          // ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                                }, // Close bottom sheet
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 73, 133),
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
