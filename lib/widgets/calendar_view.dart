import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
            // onRangeSelected: (start, end, focusedDay) {
            //   setState(() {
            //     startRange = start;
            //     endRange = end;
            //   });
            // },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
