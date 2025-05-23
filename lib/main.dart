import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:when_yes/ideas.dart';
import 'splash_screen.dart';
import 'add_when_page.dart';
import 'your_when.dart';
import 'package:intl/intl.dart';
import 'birthdays.dart';
import 'holidays.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/when_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

List<Map<String, dynamic>> globalWhenList = []; // JADINYA DI SINI LIST GLOBAL
List<Map<String, dynamic>> globalPinnedWhenList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(WhenModelAdapter());
  await Hive.openBox('whenDataBox');
  await initializeDateFormatting('id_ID', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          if (settings.name == '/birthdays') {
            return MaterialPageRoute(
              builder: (context) => BirthdaysPage(),
            );
          } else if (settings.name == '/holidays') {
            return MaterialPageRoute(
              builder: (context) => HolidaysPage(),
            );
          } else if (settings.name == '/ideas') {
            return MaterialPageRoute(
              builder: (context) => IdeasPage(),
            );
          }
          return null;
        },
      home: SplashScreen(),
    ),
  );
}

// Save When baru ke Hive
Future<void> saveWhenToHive() async {
  final box = Hive.box('whenDataBox');
  await box.put(
    'whenList',
    globalWhenList.map((item) {
      return {
        ...item,
        'date': item['date']?.toIso8601String(),
      };
    }).toList(),
  );
  await box.put(
    'pinnedList',
    globalPinnedWhenList.map((item) {
      return {
        ...item,
        'date': item['date']?.toIso8601String(),
      };
    }).toList(),
  );
}


// Load dari Hive
Future<void> loadWhenFromHive() async {
  final box = Hive.box('whenDataBox');
  final savedWhen = box.get('whenList');
  final savedPinned = box.get('pinnedList');

  if (savedWhen != null) {
    globalWhenList = List<Map<String, dynamic>>.from(savedWhen.map((item) {
      return {
        ...item,
        'date': item['date'] != null ? DateTime.tryParse(item['date']) : null,
      };
    }));
  }

  if (savedPinned != null) {
    globalPinnedWhenList = List<Map<String, dynamic>>.from(savedPinned.map((item) {
      return {
        ...item,
        'date': item['date'] != null ? DateTime.tryParse(item['date']) : null,
      };
    }));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    loadWhenFromHive().then((_) {
      setState(() {}); // untuk reload data ke UI setelah load
    });
  }
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight / 4;
    final bottomRadius = 60.0; // Radius corner

    return Scaffold(
      backgroundColor: Color(0xFF213339), // Biar corner radius keliatan, bikin warna Scaffoldnya sama kek body
      appBar: PreferredSize( // Memperluas size appBar
        preferredSize: Size.fromHeight(appBarHeight + bottomRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: appBarHeight + bottomRadius,
              decoration: BoxDecoration(
                color: Color(0xFFEAFFF9), // Warna app bar
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(bottomRadius), // Ngatur radius
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox.expand(), // Biar tetep penuh trus padding aman
              ),
            ),
            Positioned(
              top: appBarHeight * 0.28,
              left: 22.0,
              child: Text(
                "When yes?",
                style: GoogleFonts.dmSans(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF213339), // Warna teks
                ),
              ),
            ),
            Positioned(
              top: appBarHeight * 0.55,
              left: 25.0,
              child: Text(
                "When-when 😁",
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF62838E), // Warna teks
                ),
              ),
            ),

            // Wadah tombol "Add your own When..."
            Positioned(
              top: appBarHeight - 20, // geser ke bawah, biar setengah di app Bar, setengah di luar
              left: 25,
              right: 25,
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddWhenPage()),
                  );

                  if (result != null) {
                    globalPinnedWhenList.add(result);
                    await saveWhenToHive(); // save ke Hive

                    await loadWhenFromHive();
                    setState(() {}); // update UI

                    // Kalo "Birthdays", langsung navigasi ke kalender
                    if (result['category'] == 'Birthdays' && result['date'] != null) {
                      Navigator.pushNamed(
                        context,
                        '/birthdays',
                        arguments: [result], // Kirim data buat di kalender
                      );
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF213339),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFEAFFF9).withOpacity(0.08), // shadow tipis
                        spreadRadius: 1,
                        blurRadius: 1, // blur nya tipis aja
                        offset: Offset(0, 1), // bayangan ke bawah dikit
                      ),
                    ],
                  ),

                  // Teks sama Icon di tombol "Add"
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // teks dan icon ke tengah
                    children: [
                      Icon(
                        Icons.add_circle_outline, // Ikon dari iconify BELUM BELUM BELUM
                        color: Color(0xFFEAFFF9),
                        size: 65,
                      ),
                      SizedBox(width: 26),
                      Text(
                        "Add your own When...",
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAFFF9),
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color(0xFF213339), // Warna background
            ),
          ),

          // Teks Pinned When
          Positioned(
            top: appBarHeight - 140, // jarak dari atas
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pinned When",
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEAFFF9),
                  ),
                ),
                SizedBox(height: 18), // jarak sama container Pinned Whens

                // Wadah konten Pinned When
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...globalPinnedWhenList.take(2).map((whenData) {
                      final category = whenData['category'];
                      final colorMap = {
                        'Tugas': Color(0xFF710084),
                        'Life Goals': Color(0xFFFFD700),
                        'Holidays': Colors.red,
                        'Personal': Color(0xFF00E500),
                        'Birthdays': Colors.blue,
                      };

                      final Color ellipseColor = colorMap[category] ?? Color(0xFFD9D9D9);

                      return GestureDetector(
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.push_pin_outlined),
                                    title: Text('Unpin'),
                                    onTap: () {
                                      setState(() {
                                        globalPinnedWhenList.remove(whenData);
                                      });
                                      Navigator.pop(context);
                                      saveWhenToHive();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete'),
                                    onTap: () {
                                      setState(() {
                                        globalPinnedWhenList.remove(whenData);
                                      });
                                      Navigator.pop(context);
                                      saveWhenToHive();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Color(0xFF2F4B53),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ellipse Kategori
                              Container(
                                width: 16,
                                height: 16,
                                margin: EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  color: ellipseColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              // Teks When-nya
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      whenData['title'] ?? '',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEAFFF9),
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
                    }).toList(),

                    // Memunculkan "See all" jika pinned udah lebih dari 2
                    if (globalPinnedWhenList.length > 2)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YourWhenPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "See all",
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEAFFF9),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20), // Spasi bawah
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF2F4B53),
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
                    MaterialPageRoute(builder: (context) => YourWhenPage(),
                      )
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
