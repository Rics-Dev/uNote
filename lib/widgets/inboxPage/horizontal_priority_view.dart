import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/entities.dart';
import '../../providers/taskProvider.dart';
import 'package:badges/badges.dart' as badges;

class HorizontalPriorityView extends StatelessWidget {
  const HorizontalPriorityView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();

    final tags = tasksProvider.tags;
    final selectedTags = tasksProvider.selectedTags;
    final selectedPriority = tasksProvider.selectedPriority;

    final allTasks = tasksProvider.tasks;
    FilterCriteria filterCriteria = tasksProvider.filterCriteria;
    final priority = tasksProvider.priority;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: priority.map((priority) {
        final isSelected = selectedPriority.contains(priority);
        return badges.Badge(
          badgeStyle: const badges.BadgeStyle(
              badgeColor: Color.fromARGB(255, 0, 73, 133)),
          position: badges.BadgePosition.topEnd(top: -5, end: 0),
          badgeContent: Text(
            allTasks
                .where((task) =>
                    (task.priority?.contains(priority) ?? false) &&
                    (task.list.target == null))
                .length
                .toString(),
            style: const TextStyle(color: Colors.white),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () {
                tasksProvider.togglePrioritySelection(priority);
              },
              child: ElevatedButton.icon(
                onPressed: () {
                  tasksProvider.togglePrioritySelection(priority);
                },
                icon: Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : const Color.fromARGB(255, 0, 73, 133),
                ),
                label: Text(
                  priority,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color.fromARGB(255, 0, 73, 133),
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4), // Adjust the padding as needed
                  ),
                  backgroundColor: isSelected
                      ? MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73, 133))
                      : MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
    );
  }
}
