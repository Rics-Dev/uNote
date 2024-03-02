import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../providers/task_provider.dart';
import 'package:intl/intl.dart';

class AddDueDateView extends StatefulWidget {
  const AddDueDateView({super.key});

  @override
  State<AddDueDateView> createState() => _AddDueDateViewState();
}

class _AddDueDateViewState extends State<AddDueDateView> {
  CalendarFormat calendarFormat = CalendarFormat.month;

  DateTime? startRange = DateTime.now();
  DateTime? endRange = DateTime.now();

  DateTime today = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // DateTime selectedDayAndTime = DateTime(
  //   today.year,
  //   today.month,
  //   today.day,
  //   selectedTime.hour,
  //   selectedTime.minute,
  // );

  bool isTimeSelected = false;
  

  @override
  Widget build(BuildContext context) {
    final dueDate = context.watch<TasksAPI>().dueDate;
    final isTimeSet = context.watch<TasksAPI>().isTimeSet;
    DateTime today = dueDate ?? DateTime.now();
    String? formattedTime = dueDate != null ? DateFormat('HH:mm').format(dueDate) : null;
    

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    child: Text(
                      "Calendar",
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<TasksAPI>().setDueDate(null);
                          context.read<TasksAPI>().setTimeSet(false);
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
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
                  context.read<TasksAPI>().setDueDate(selectedDay);
                },
                // onRangeSelected: (start, end, focusedDay) {
                //   setState(() {
                //     startRange = start;
                //     endRange = end;
                //   });
                // },
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  selectTime();
                },
                child: isTimeSet == false
                    ? const Icon(
                        Icons.access_time_rounded,
                        color: Color.fromARGB(255, 0, 73, 133),
                        size: 40,
                      )
                    : OutlinedButton.icon(
                        onPressed: () {
                          selectTime();
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Color.fromARGB(255, 0, 73, 133),
                          size: 30,
                        ),
                        label: Text(formattedTime!),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void selectTime() async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      setState(() {
        selectedTime = timeOfDay;
      });
      context.read<TasksAPI>().setTimeSet(true);
      context.read<TasksAPI>().setDueDate(
            DateTime(
              today.year,
              today.month,
              today.day,
              selectedTime.hour,
              selectedTime.minute,
            ),
          );
    }
  }
}
