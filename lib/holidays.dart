import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'main.dart';
import 'your_when.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final destinationController = TextEditingController();

  // Display mode untuk menentukan tampilan kalender
  bool yearOverviewMode = true; // Start with year overview
  int selectedMonthInYearView = DateTime.now().month - 1; // Untuk menyimpan bulan yang dipilih di tampilan tahun

  final List<Map<String, dynamic>> nationalHolidays = [
    {'date': DateTime(2025, 1, 1), 'title': "Tahun Baru Masehi"},
    {'date': DateTime(2025, 1, 29), 'title': "Isra Mi'raj"},
    {'date': DateTime(2025, 3, 28), 'title': "Cuti Bersama Nyepi"},
    {'date': DateTime(2025, 3, 29), 'title': "Hari Nyepi"},
    {'date': DateTime(2025, 3, 31), 'title': "Idul Fitri"},
    {'date': DateTime(2025, 4, 1), 'title': "Libur Idul Fitri"},
    {'date': DateTime(2025, 4, 2), 'title': "Cuti Bersama Idul Fitri"},
    {'date': DateTime(2025, 4, 3), 'title': "Cuti Bersama Idul Fitri"},
    {'date': DateTime(2025, 4, 4), 'title': "Cuti Bersama Idul Fitri"},
    {'date': DateTime(2025, 4, 18), 'title': "Jumat Agung"},
    {'date': DateTime(2025, 4, 20), 'title': "Paskah"},
    {'date': DateTime(2025, 5, 1), 'title': "Hari Buruh Internasional"},
    {'date': DateTime(2025, 5, 12), 'title': "Hari Waisak"},
    {'date': DateTime(2025, 5, 13), 'title': "Cuti Bersama Waisak"},
    {'date': DateTime(2025, 5, 29), 'title': "Kenaikan Isa Almasih"},
    {'date': DateTime(2025, 5, 30), 'title': "Cuti Bersama Kenaikan Isa Almasih"},
    {'date': DateTime(2025, 6, 1), 'title': "Hari Pancasila"},
    {'date': DateTime(2025, 6, 6), 'title': "Idul Adha"},
    {'date': DateTime(2025, 6, 9), 'title': "Cuti Bersama Idul Adha"},
    {'date': DateTime(2025, 6, 27), 'title': "Tahun Baru Hijriah"},
    {'date': DateTime(2025, 8, 17), 'title': "Hari Kemerdekaan"},
    {'date': DateTime(2025, 8, 31), 'title': "Maulid Nabi"},
    {'date': DateTime(2025, 10, 21), 'title': "Diwali"},
    {'date': DateTime(2025, 12, 25), 'title': "Hari Raya Natal"},
  ];


  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return globalWhenList.where((w) {
      if (w['category'] != 'Holidays') return false;
      final dynamic date = w['date'];
      if (date is String) {
        final parsedDate = DateTime.tryParse(date);
        return parsedDate != null &&
            parsedDate.year == day.year &&
            parsedDate.month == day.month &&
            parsedDate.day == day.day;
      } else if (date is DateTime) {
        return date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      }
      return false;
    }).toList();
  }

  List<Map<String, dynamic>> getNationalHolidaysForMonth(DateTime month) {
    return nationalHolidays.where((item) =>
    item['date'].month == month.month
    ).toList();
  }

  void _showAddWhenDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2F4B53),
        title: const Text('Add When Holiday anda', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Judul',
                    labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(
                    labelText: 'Ke mana?',
                    labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                globalWhenList.add({
                  'title': titleController.text,
                  'description': descController.text,
                  'destination': destinationController.text,
                  'date': date,
                  'category': 'Holidays',
                });
                titleController.clear();
                descController.clear();
                destinationController.clear();
                setState(() {});
                Navigator.pop(context);
                await saveWhenToHive(); // simpan ke Hive
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan kalender tahunan
  Widget buildYearCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final monthDate = DateTime(2025, month, 1);
        final monthName = DateFormat('MMMM').format(monthDate);

        return GestureDetector(
          onTap: () {
            setState(() {
              yearOverviewMode = false;
              selectedMonthInYearView = index;
              focusedDay = DateTime(2025, month, 1);
              calendarFormat = CalendarFormat.month;
            });
          },
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    monthName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: _buildMiniMonthCalendar(month),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget untuk membuat mini kalender per bulan
  Widget _buildMiniMonthCalendar(int month) {
    final daysInMonth = DateTime(2025, month + 1, 0).day;
    final firstDayOfMonth = DateTime(2025, month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    // Days of week header (Su, Mo, Tu, etc.)
    final List<String> daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: daysOfWeek.map((day) =>
              Text(
                day,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 8,
                ),
              )
          ).toList(),
        ),
        const SizedBox(height: 2),
        // Calendar grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemCount: 42, // 6 weeks × 7 days
            itemBuilder: (context, index) {
              // Add offset for first day of month
              final day = index - firstWeekday + 1;
              if (day < 1 || day > daysInMonth) {
                return const SizedBox();
              }

              final date = DateTime(2025, month, day);
              final hasEvent = getEventsForDay(date).isNotEmpty;
              final isHoliday = nationalHolidays.any((holiday) {
                final hd = holiday['date'] as DateTime;
                return hd.year == date.year && hd.month == date.month && hd.day == date.day;
              });

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHoliday ? Colors.redAccent.withOpacity(0.3) : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 7,
                        fontWeight: isHoliday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (hasEvent)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF213339),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4B53),
        automaticallyImplyLeading: false,
        title: Text(
          yearOverviewMode ? "Red Days 2025" :
          "${DateFormat('MMMM').format(DateTime(2025, selectedMonthInYearView + 1))} 2025",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        foregroundColor: const Color(0xFFEAFFF9),
        actions: [
          // Tombol untuk beralih antara tampilan tahun dan bulan
          IconButton(
            icon: Icon(yearOverviewMode ? Icons.calendar_month : Icons.calendar_today),
            onPressed: () {
              setState(() {
                yearOverviewMode = !yearOverviewMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (yearOverviewMode)
            // Tampilan kalender tahunan
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildYearCalendar(),
              )
            else
            // Tampilan kalender bulanan
              Column(
                children: [
                  Container(
                  color: Colors.white,
                  child:
                  TableCalendar(
                    focusedDay: focusedDay,
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                      markerDecoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(color: Colors.redAccent),
                      weekendTextStyle: TextStyle(color: Colors.redAccent),
                      outsideTextStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w300),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(color: Colors.redAccent),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.redAccent),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.redAccent),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.black),
                      weekendStyle: TextStyle(color: Colors.redAccent),
                    ),
                    calendarFormat: calendarFormat,
                    eventLoader: getEventsForDay,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                      });
                      _showAddWhenDialog(selected);
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        calendarFormat = format;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() {
                        focusedDay = focused;
                        selectedMonthInYearView = focused.month - 1;
                        });
                      },
                    )
                  ),

                  const Divider(color: Colors.white54),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hari libur nasional bulan ini
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F4B53),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hari libur nasional bulan ini:",
                                    style: GoogleFonts.dmSans(
                                      color: Colors.amberAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Tampilkan hari libur nasional bulan ini
                                  ...getNationalHolidaysForMonth(focusedDay).map((holiday) {
                                    final date = holiday['date'] as DateTime;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        "📌 ${DateFormat('d MMMM', 'id_ID').format(date)} - ${holiday['title']}",
                                        style: GoogleFonts.dmSans(
                                          color: Colors.amberAccent,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "When yes Holiday di bulan ${DateFormat('MMMM').format(focusedDay)} 2025:",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: globalWhenList
                                  .where((item) {
                                final rawDate = item['date'];
                                final DateTime? date = rawDate is String ? DateTime.tryParse(rawDate) : rawDate;
                                return item['category'] == 'Holidays' &&
                                    date != null &&
                                    date.year == focusedDay.year &&
                                    date.month == focusedDay.month;
                              })
                                  .map((item) {
                                final rawDate = item['date'];
                                final DateTime? date = rawDate is String ? DateTime.tryParse(rawDate) : rawDate;

                                return ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      date?.day.toString() ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text("🏖️ ${item['title']}",
                                      style: const TextStyle(color: Colors.white)),
                                  subtitle: item['destination'] != null && item['destination'] != ""
                                      ? Text(item['destination'],
                                      style: const TextStyle(color: Colors.white70))
                                      : null,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      // Navbar 5 menu bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF2F4B53),
            borderRadius: BorderRadius.circular(15),
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
                icon: const Icon(Icons.home),
                color: const Color(0xFFEAFFF9),
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
                icon: const Icon(Icons.cake),
                color: const Color(0xFFEAFFF9),
              ),

              // Your When
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const YourWhenPage()),
                  );
                },
                icon: const Icon(Icons.app_registration_sharp),
                color: const Color(0xFFEAFFF9),
              ),

              // Holidays
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/holidays');
                },
                icon: const Icon(Icons.calendar_month),
                color: const Color(0xFFEAFFF9),
              ),

              // Explore When Ideas
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/ideas');
                },
                icon: const Icon(Icons.lightbulb),
                color: const Color(0xFFEAFFF9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}