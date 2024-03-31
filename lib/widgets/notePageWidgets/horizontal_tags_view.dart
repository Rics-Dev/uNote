import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/entities.dart';
import '../../providers/taskProvider.dart';
import 'package:badges/badges.dart' as badges;

class HorizontalTagsView extends StatelessWidget {
  const HorizontalTagsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();

    final tags = tasksProvider.tags;
    final selectedTags = tasksProvider.selectedTags;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          selectedTags.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    tasksProvider.clearSelectedTags();
                    // tasksProvider.filterTasksByTags(tasksProvider.selectedTags);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(12),
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
                    tag.tasks.length.toString(),
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
                        tasksProvider.toggleTagSelection(tag);
                      },
                      child: ElevatedButton.icon(
                        onPressed: () {
                          tasksProvider.toggleTagSelection(tag);
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
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4), // Adjust the padding as needed
                          ),
                          backgroundColor: isSelected
                              ? MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 0, 73, 133))
                              : MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()),
            ),
          )
          // IconButton.outlined(
          //   color: const Color.fromARGB(255, 0, 73, 133),
          //   icon: Icon(
          //     filterCriteria == FilterCriteria.tags
          //         ? Icons.flag_outlined
          //         : Icons.label_outline_rounded,
          //     color: const Color.fromARGB(255, 0, 73, 133),
          //   ),
          //   onPressed: () {
          //     filterCriteria == FilterCriteria.tags
          //         ? tasksProvider.toggleFilterByPriority()
          //         : tasksProvider.toggleFilterByTags();
          //   },
          // ),
        ],
      ),
    );
  }

  Future<dynamic> deleteTag(BuildContext context, Tag tag) {
    final tasksProvider = context.read<TasksProvider>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tag? "${tag.name}"'),
          content: const Text('Are you sure you want to delete this tag?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3.0,
                  ),
                  onPressed: () {
                    // Save changes
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      // Save changes
                      tasksProvider.deleteTag(tag);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/trash-2.svg',
                          // ignore: deprecated_member_use
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