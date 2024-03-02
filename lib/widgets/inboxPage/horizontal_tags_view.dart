import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import 'package:badges/badges.dart' as badges;

class HorizontalTagsView extends StatelessWidget {
  const HorizontalTagsView({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final tasksAPI = context.watch<TasksAPI>();
    final tags = tasksAPI.tags;
    final selectedTags = tasksAPI.selectedTags;

    final allTasks = tasksAPI.tasks;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          selectedTags.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    tasksAPI.clearSelectedTags();
                    tasksAPI.filterTasksByTags(tasksAPI.selectedTags);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey)),
                      child: Text(
                        selectedTags.length.toString(),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 73, 133)),
                      )),
                )
              : const SizedBox(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return badges.Badge(
                    badgeStyle: const badges.BadgeStyle(
                        badgeColor: Color.fromARGB(255, 0, 73, 133)),
                    position: badges.BadgePosition.topEnd(top: -5, end: 0),
                    badgeContent: Text(
                      allTasks
                          .where((task) => task.tags.contains(tag))
                          .length
                          .toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onLongPress: () {
                          // Show a confirmation dialog
                          deleteTag(context, tag);
                        },
                        onTap: () {
                          tasksAPI.toggleTagSelection(tag);
                          tasksAPI.filterTasksByTags(tasksAPI.selectedTags);
                        },
                        child: OutlinedButton.icon(
                          onPressed: () {
                            tasksAPI.toggleTagSelection(tag);
                            tasksAPI.filterTasksByTags(tasksAPI.selectedTags);
                          },
                          icon: Icon(
                            Icons.label_outline_rounded,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : const Color.fromARGB(255, 0, 73, 133),
                          ),
                          label: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color.fromARGB(255, 0, 73, 133),
                            ),
                          ),
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4), // Adjust the padding as needed
                            ),
                            backgroundColor: isSelected
                                ? MaterialStateProperty.all<Color>(
                                    const Color.fromARGB(255, 0, 73, 133))
                                : MaterialStateProperty.all<Color>(
                                    Colors.transparent),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> deleteTag(BuildContext context, String tag) {
    final tasksAPI = context.read<TasksAPI>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tag? "$tag"'),
          content: const Text('Are you sure you want to delete this tag?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Save changes
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () {
                      // Save changes
                      tasksAPI.deleteTag(tag);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/trash-2.svg',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        );
      },
    );
  }
}
