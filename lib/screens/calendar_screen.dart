import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/nutrition_info.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Function(DateTime) onDateSelected;

  const CalendarScreen({
    super.key,
    required this.onDateSelected,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isYearMonthPickerVisible = false;

  void _showYearMonthPicker() {
    setState(() {
      _isYearMonthPickerVisible = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('연도와 월 선택'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: YearPicker(
              firstDate: DateTime(2024),
              lastDate: DateTime(2025),
              selectedDate: _focusedDay,
              onChanged: (DateTime dateTime) {
                setState(() {
                  _focusedDay = dateTime;
                  _isYearMonthPickerVisible = false;
                });
                Navigator.pop(context);

                // 월 선택 다이얼로그 표시
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('월 선택'),
                      content: SizedBox(
                        height: 200,
                        width: 300,
                        child: GridView.count(
                          crossAxisCount: 4,
                          children: List.generate(12, (index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _focusedDay =
                                      DateTime(_focusedDay.year, index + 1);
                                });
                                Navigator.pop(context);
                              },
                              child: Center(
                                child: Text(
                                  '${index + 1}월',
                                  style: TextStyle(
                                    fontWeight: _focusedDay.month == index + 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _showYearMonthPicker,
                      child: Text(
                        '${_focusedDay.year}년 ${_focusedDay.month}월',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up),
                          onPressed: () {
                            setState(() {
                              _focusedDay = DateTime(
                                _focusedDay.year,
                                _focusedDay.month + 1,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          onPressed: () {
                            setState(() {
                              _focusedDay = DateTime(
                                _focusedDay.year,
                                _focusedDay.month - 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  widget.onDateSelected(selectedDay);
                },
                headerVisible: false,
                daysOfWeekHeight: 30,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  holidayTextStyle: const TextStyle(color: Colors.red),
                  selectedDecoration: BoxDecoration(
                    color: Colors.pink[100],
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink),
                  ),
                  todayTextStyle: const TextStyle(color: Colors.black),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
