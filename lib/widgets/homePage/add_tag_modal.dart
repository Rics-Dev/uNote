import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task.dart';

class AddTagView extends StatefulWidget {
  final List<String> initialSelectedTags;

  const AddTagView(this.initialSelectedTags, {super.key});

  @override
  _AddTagViewState createState() => _AddTagViewState();
}

class _AddTagViewState extends State<AddTagView> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = List.from(widget.initialSelectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<TasksAPI>().filteredTags;
    return Wrap(
      children: [
        Center(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 20.0),
              height: MediaQuery.of(context).size.height * 0.30,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '# Add Tag or select already existing ones',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (_.isNotEmpty) {
                          selectedTags.add(_);
                        }
                        Navigator.pop(context, selectedTags);
                      },
                      onChanged: searchTags,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: tags.isEmpty
                            ? [const Text('Add a new tag')]
                            : tags.map((tag) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: CheckboxListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text("#$tag"),
                                    checkboxShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    value: selectedTags.contains(tag),
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        if (newValue != null) {
                                          if (newValue) {
                                            selectedTags.add(tag);
                                          } else {
                                            selectedTags.remove(tag);
                                          }
                                        }
                                      });
                                    },
                                    activeColor:
                                        const Color.fromARGB(255, 0, 73, 133),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void searchTags(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all tags
      context.read<TasksAPI>().setFilteredTags(context.read<TasksAPI>().tags);
    } else {
      // Filter tags based on the query
      final suggestions = context.read<TasksAPI>().tags.where((tag) {
        return tag.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<TasksAPI>().setFilteredTags(suggestions);
    }
  }
}