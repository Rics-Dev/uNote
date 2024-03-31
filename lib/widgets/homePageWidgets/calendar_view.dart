import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/entities.dart';
import '../../providers/task_provider.dart';


class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime today = DateTime.now();
  DateTime? startRange = DateTime.now();
  DateTime? endRange = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksProvider>().tasks;
// Filter tasks with due date equals today
    final todayTasks = tasks
        .where((task) =>
            task.dueDate?.year == today.year &&
            task.dueDate?.month == today.month &&
            task.dueDate?.day == today.day)
        .toList();

    todayTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    List<Task> getEvents(DateTime day) {
      return tasks
          .where((task) =>
              task.dueDate?.year == day.year &&
              task.dueDate?.month == day.month &&
              task.dueDate?.day == day.day)
          .toList();
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 16),
          Stack(
            children: [
              const Align(
                child: Text(
                  "Calendar",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close_rounded, size: 30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableCalendar(
            eventLoader: (day) {
              return getEvents(day);
            },
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2100, 3, 14),
            focusedDay: today,
            // rangeStartDay: startRange,
            // rangeEndDay: endRange,
            calendarFormat: calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 73, 133),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(150, 0, 73, 133),
                shape: BoxShape.circle,
              ),
            ),
            onFormatChanged: (format) {
              setState(() {
                calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(day, today);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                today = selectedDay;
              });
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              today.year == DateTime.now().year &&
                      today.month == DateTime.now().month &&
                      today.day == DateTime.now().day
                  ? "Today"
                  : "${today.day}/${today.month}/${today.year} ",
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          todayTasks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No tasks due today",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ListView.builder(
                    itemCount: todayTasks.length,
                    itemBuilder: (context, index) {
                      final task = todayTasks[index];
                      return ListTile(
                        title: Text(task.name),
                        subtitle: task.dueDate!.hour != 0 &&
                                task.dueDate!.minute != 0
                            ? Text(
                                "${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}")
                            : null,
                        // Add more details or actions if needed
                      );
                    },
                  ),
                ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 100,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  String getWeekDay(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }
}
