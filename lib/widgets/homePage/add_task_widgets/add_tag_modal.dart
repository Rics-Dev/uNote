import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/entities.dart';
import '../../../providers/taskProvider.dart';
import '../../../providers/task_provider.dart';

class AddTagView extends StatefulWidget {
  const AddTagView({super.key});

  @override
  State<AddTagView> createState() {
    return _AddTagViewState();
  }
}

class _AddTagViewState extends State<AddTagView> {
  final TextEditingController tagController = TextEditingController();

  @override
  void dispose() {
    // Dispose the TextEditingController when the widget is disposed
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Tag> tags = context.watch<TasksProvider>().tags;
    final searchedTags = context.watch<TasksProvider>().searchedTags;
    final selectedTags = context.watch<TasksProvider>().selectedTags;
    final temporarilyAddedTags =
        context.watch<TasksProvider>().temporarilyAddedTags;

    tags = searchedTags.isNotEmpty ? searchedTags : tags;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: '# Add Tag or select already existing ones',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (String value) {
                      if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_\-\.]*$')
                          .hasMatch(value)) {
                        // Only add value if it matches the allowed pattern
                        setState(() {
                          tagController.text = value;
                          tagController.selection = TextSelection.fromPosition(
                              TextPosition(offset: tagController.text.length));
                        });
                      } else {
                        // Remove invalid characters
                        setState(() {
                          tagController.text = tagController.text
                              .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                          tagController.selection = TextSelection.fromPosition(
                              TextPosition(offset: tagController.text.length));
                        });
                      }
                      searchTags(tagController
                          .text); // Call searchTags with the updated value
                    },
                    onSubmitted: (_) {
                      if (_.isNotEmpty) {
                        context
                            .read<TasksProvider>()
                            .addTemporarilyAddedTags(_);
                        tagController.clear();
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: GridView.extent(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  childAspectRatio: 2.5,
                  maxCrossAxisExtent: 150.0,
                  mainAxisSpacing: 12.0, // spacing between rows
                  crossAxisSpacing: 8.0, // spacing between columns
                  children: tags.isEmpty
                      ? [const Text('Add a new tag')]
                      : tags.map((tag) {
                          final isSelected = temporarilyAddedTags
                              .any((element) => element.name == tag.name);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 4.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!isSelected) {
                                  context
                                      .read<TasksProvider>()
                                      .addTemporarilyAddedTags(tag.name);
                                } else {
                                  context
                                      .read<TasksProvider>()
                                      .removeTemporarilyAddedTags(tag);
                                }
                              },
                              icon: Icon(
                                Icons.label_outline_rounded,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 73, 133),
                              ),
                              label: Text(
                                tag.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color.fromARGB(255, 0, 73, 133),
                                ),
                              ),
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(3),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical:
                                          4), // Adjust the padding as needed
                                ),
                                backgroundColor: isSelected
                                    ? MaterialStateProperty.all<Color>(
                                        const Color.fromARGB(255, 0, 73, 133))
                                    : MaterialStateProperty.all<Color>(
                                        Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                              // child: Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //   children: [
                              //     Icon(
                              //       Icons.label_outline_rounded,
                              //       size: 18,
                              //       color: isSelected
                              //           ? Colors.white
                              //           : const Color.fromARGB(255, 0, 73, 133),
                              //     ),
                              //     Text(
                              //       tag.name,
                              //       style: TextStyle(
                              //         color: isSelected
                              //             ? Colors.white
                              //             : const Color.fromARGB(255, 0, 73, 133),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ),
                          );
                        }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchTags(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all tags
      context.read<TasksProvider>().setSearchedTags(context.read<TasksProvider>().tags);
    } else {
      // search tags based on the query
      final suggestions = context.read<TasksProvider>().tags.where((tag) {
        return tag.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<TasksProvider>().setSearchedTags(suggestions);
    }
  }
}
