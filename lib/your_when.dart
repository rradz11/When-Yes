import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'add_when_page.dart';
import 'main.dart';

class YourWhenPage extends StatefulWidget {
  final List<Map<String, dynamic>> whenList;
  final List<Map<String, dynamic>>? pinnedWhenList;

  const YourWhenPage({
    super.key,
    required this.whenList,
    this.pinnedWhenList,
  });

  @override
  State<YourWhenPage> createState() => _YourWhenPageState();
}

class _YourWhenPageState extends State<YourWhenPage> {
  List<Map<String, dynamic>> pinnedWhenList = [];
  late List<Map<String, dynamic>> whenList;

  @override
  void initState() {
    super.initState();
    whenList = List<Map<String, dynamic>>.from(widget.whenList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF213339),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100), // jarak agar tombol tidak nabrak
                  // Judul "Your When"
                  Text(
                    'Your When',
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEAFFF9),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // List When
                  Expanded(
                    child: ListView.builder(
                      itemCount: whenList.length,
                      itemBuilder: (context, index) {
                        final whenData = whenList[index];
                        final category = whenData['category'];

                        final colorMap = {
                          'Tugas': const Color(0xFF710084),
                          'Life Goals': const Color(0xFFFFD700),
                          'Holidays': Colors.red,
                          'Personal': const Color(0xFF00E500),
                          'Birthdays': Colors.blue,
                        };

                        final Color ellipseColor = colorMap[category] ?? const Color(0xFFD9D9D9);

                        return GestureDetector(
                          onLongPressStart: (details) async {
                            final selected = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                              ),
                              items: [
                                const PopupMenuItem<String>(
                                  value: 'pin',
                                  child: ListTile(
                                    leading: Icon(Icons.push_pin_outlined),
                                    title: Text('Pin'),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            );

                            if (selected == 'pin') {
                              if (widget.pinnedWhenList != null) {
                                setState(() {
                                  widget.pinnedWhenList!.add(whenData);
                                });
                              }
                            } else if (selected == 'delete') {
                              setState(() {
                                widget.pinnedWhenList?.remove(whenData);
                                whenList.remove(whenData);
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F4B53),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: ellipseColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        whenData['title'] ?? '',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFEAFFF9),
                                        ),
                                      ),
                                      if (whenData['date'] != null)
                                        Text(
                                          DateFormat.yMMMd().format(whenData['date']),
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Wadah tombol "Add your own When..."
            Positioned(
              top: 16,
              left: 25,
              right: 80,
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddWhenPage()),
                  );

                  if (result != null) {
                    setState(() {
                      whenList.add(result); // Nambah ke list utama
                    });
                  }

                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFFF9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // Teks & Icon tombol Add
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF213339),
                        size: 35,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Add your own When...",
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF213339),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
                  final allWhenList = [
                    {
                      'title': 'Wirtz ultah',
                      'category': 'Birthdays',
                      'date': DateTime(2025, 5, 3),
                    },
                    {
                      'title': 'Messi ultah',
                      'category': 'Birthdays',
                      'date': DateTime(2025, 6, 24),
                    },
                  ];

                  Navigator.pushReplacementNamed(
                    context,
                    '/birthdays',
                    arguments: allWhenList,
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
