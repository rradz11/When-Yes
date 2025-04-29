import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'your_when.dart';

class BirthdaysPage extends StatefulWidget {
  final List<Map<String, dynamic>> whenList;

  const BirthdaysPage({super.key, required this.whenList});

  @override
  State<BirthdaysPage> createState() => _BirthdaysPageState();
}

class _BirthdaysPageState extends State<BirthdaysPage> {
  List<Map<String, dynamic>> pinnedWhenList = [];
  late List<Map<String, dynamic>> whenList;
  late Map<DateTime, List<String>> _birthdayEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _birthdayEvents = {};

    for (var when in widget.whenList) {
      if (when['category'] == 'Birthdays' && when['date'] != null) {
        final DateTime date = DateTime(
          when['date'].year,
          when['date'].month,
          when['date'].day,
        );
        final title = when['title'] ?? 'Ulang Tahun';
        if (_birthdayEvents[date] != null) {
          _birthdayEvents[date]!.add(title);
        } else {
          _birthdayEvents[date] = [title];
        }
      }
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _birthdayEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF213339),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4B53),
        title: Text(
          "Birthdays Calendar",
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: const Color(0xFFEAFFF9),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(color: Color(0xFFEAFFF9)),
              weekendTextStyle: const TextStyle(color: Color(0xFFEAFFF9)),
              outsideTextStyle: const TextStyle(color: Color(0xFF90A4AE)),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Color(0xFFEAFFF9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFEAFFF9)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFEAFFF9)),
            ),
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2F4B53),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedDay == null
                  ? const Center(
                child: Text(
                  "Pilih tanggal untuk lihat detail ulang tahun",
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView(
                children: _getEventsForDay(_selectedDay!).map((event) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "🎂 $event",
                      style: const TextStyle(
                        color: Color(0xFFEAFFF9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20), // Spasi bawah
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF213339),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFEAFFF9).withOpacity(0.05), // shadow tipis
                spreadRadius: 1,
                blurRadius: 1, // blur nya tipis aja
                offset: Offset(0, 1), // bayangan ke bawah dikit
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter Demo Home Page')),
                  );
                },
                icon: Icon(Icons.home),
                color: Color(0xFFEAFFF9),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BirthdaysPage(whenList: pinnedWhenList),
                    ),
                  );
                },
                icon: Icon(Icons.cake),
                color: Color(0xFFEAFFF9),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => YourWhenPage(whenList: pinnedWhenList)),
                  );
                },
                icon: Icon(Icons.app_registration_sharp),
                color: Color(0xFFEAFFF9),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/holidays');
                },
                icon: Icon(Icons.calendar_month),
                color: Color(0xFFEAFFF9),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/profile');
                },
                icon: Icon(Icons.person),
                color: Color(0xFFEAFFF9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
