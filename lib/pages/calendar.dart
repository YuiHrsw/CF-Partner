import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            headerBackgroundColor: colorScheme.secondaryContainer,
            backgroundColor: Colors.transparent,
          ),
          child: SfCalendar(
            headerStyle: CalendarHeaderStyle(
              backgroundColor: colorScheme.background,
            ),
            showNavigationArrow: true,
            showDatePickerButton: true,
            showTodayButton: true,
            view: CalendarView.month,
            minDate: DateTime.utc(2022, 4, 8),
            maxDate: DateTime.now(),
          )),
    );
  }
}
