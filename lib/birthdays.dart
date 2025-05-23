import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'your_when.dart';

class BirthdaysPage extends StatefulWidget {
  const BirthdaysPage({super.key});

  @override
  State<BirthdaysPage> createState() => _BirthdaysPageState();
}

class AddBirthdayPage extends StatefulWidget {
  const AddBirthdayPage({super.key});

  @override
  State<AddBirthdayPage> createState() => _AddBirthdayPageState();
}

class _AddBirthdayPageState extends State<AddBirthdayPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addWhen() {
    final String title = _titleController.text.trim();
    if (title.isEmpty || selectedDate == null) return;

    final newBirthday = {
      'title': title,
      'category': 'Birthdays',
      'date': selectedDate,
    };
    globalWhenList.add(newBirthday);
    Navigator.pop(context, newBirthday); // kirim balik ke halaman sebelumnya
    saveWhenToHive(); // simpan ke Hive
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF213339),
      appBar: AppBar(
        title: Text(
          "Add New Birthday",
          style: GoogleFonts.dmSans(
            color: Color(0xFFEAFFF9),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2F4B53),
        foregroundColor: const Color(0xFFEAFFF9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Write someone's Birthday:",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEAFFF9),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "misalnya: Downey Jr.'s ultah",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF2F4B53),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Kapan?",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEAFFF9),
              )),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF62838E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Biar gak melebar penuh
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      selectedDate != null
                          ? "Tanggal: ${DateFormat.yMMMd().format(selectedDate!)}"
                          : "Pilih tanggal",
                      style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAFFF9),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _addWhen,
                child: Text(
                  "Add",
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF213339),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

    for (var when in globalWhenList) {
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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBirthdayPage()),
              );

              if (result != null) {
                await saveWhenToHive();
                loadWhenFromHive();
                setState(() {}); // refresh kalender
              }
            },
          ),
        ],
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

              // Home
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

              // Ultah
              IconButton(
                onPressed: () {
                  final birthdayList = globalWhenList
                      .where((item) => item['category'] == 'Birthdays' && item['date'] != null)
                      .toList();

                  Navigator.pushReplacementNamed(
                    context,
                    '/birthdays',
                    arguments: birthdayList,
                  );
                },
                icon: Icon(Icons.cake),
                color: Color(0xFFEAFFF9),
              ),

              // Your When
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => YourWhenPage()),
                  );
                },
                icon: Icon(Icons.app_registration_sharp),
                color: Color(0xFFEAFFF9),
              ),

              // Holidays
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/holidays');
                },
                icon: Icon(Icons.calendar_month),
                color: Color(0xFFEAFFF9),
              ),

              // Explore When Ideas
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/ideas');
                },
                icon: Icon(Icons.lightbulb),
                color: Color(0xFFEAFFF9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
