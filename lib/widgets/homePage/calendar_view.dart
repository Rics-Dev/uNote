import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
    final tasksAPI = context.watch<TasksAPI>();
    final tasks = tasksAPI.tasks;
// Filter tasks with due date equals today
    final todayTasks = tasks
        .where((task) =>
            task.dueDate?.year == today.year &&
            task.dueDate?.month == today.month &&
            task.dueDate?.day == today.day)
        .toList();

    todayTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "No tasks due today",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView.builder(
                    itemCount: todayTasks.length,
                    itemBuilder: (context, index) {
                      final task = todayTasks[index];
                      return ListTile(
                        title: Text(task.content),
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
