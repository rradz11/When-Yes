import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'main.dart';
import 'your_when.dart';

class IdeasPage extends StatefulWidget {
  const IdeasPage({super.key});

  @override
  State<IdeasPage> createState() => _IdeasPageState();
}

class _IdeasPageState extends State<IdeasPage> {
  final List<String> prompts = [
    "When yes terakhir kali bener-bener istirahat, bukan cuma rebahan sambil overthinking?",
    "When yes ngerasa hidup jalan sesuai rencana?",
    "When yes bisa bilang “nggak” ke temen deket?",
    "When yes punya Lamborghini?",
    "When yah terakhir kali nangis?",
    "When yes bangun pagi tanpa alarm?",
    "When yah bener-bener selesaiin to-do list dalam sehari?",
    "When yes fokus belajar/kuliah 3 jam nonstop?",
    "When yah gak buka TikTok seharian penuh?",
    "When yah nabung lebih dari yang dijanjikan ke diri sendiri?",
    "When yes jadi milliarder?",
    "When yah gak cuci muka 2 hari tapi jerawat gak muncul?",
    "When yah bisa produktif terus ketemu Jerome?",
    "When yah punya mantu dokter... (iya, mimpi dulu gapapa)",
    "When yes punya gebetan?",
    "When yes bisa banggain orang tua?",
    "When yah main ke Bromo ama temen?",
    "When yes ngajak gebetan ngobrol tanpa panik?",
    "When yah gebetan dateng-dateng sendiri?",
    "When yah gak nunda-nunda lagi?",
  ];

  late String currentPrompt;

  @override
  void initState() {
    super.initState();
    currentPrompt = _getRandomPrompt();
  }

  String _getRandomPrompt() {
    final random = Random();
    return prompts[random.nextInt(prompts.length)];
  }

  void _nextPrompt() {
    setState(() {
      currentPrompt = _getRandomPrompt();
    });
  }

  void _savePromptAsWhen() async {
    globalWhenList.add({
      'title': currentPrompt,
      'category': 'Life Goals',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ide berhasil disimpan sebagai When!', style: GoogleFonts.dmSans()),
        backgroundColor: Colors.green[600],
      ),
    );

    await saveWhenToHive(); // simpan ke Hive
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF213339),
      appBar: AppBar(
        title: Text("Explore When Ideas", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2F4B53),
        foregroundColor: const Color(0xFFEAFFF9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  currentPrompt,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    color: Color(0xFFEAFFF9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00E500),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _savePromptAsWhen,
                  child: Text(
                    "Jadikan When",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF213339),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF62838E),
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _nextPrompt,
                  child: Text(
                    "Skip / Next Idea",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // 👇 Navbar 5 menu bawah
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
                    MaterialPageRoute(builder: (context) =>
                        MyHomePage(title: 'Flutter Demo Home Page')),
                  );
                },
                icon: const Icon(Icons.home),
                color: const Color(0xFFEAFFF9),
              ),

              // Ultah
              IconButton(
                onPressed: () {
                  final birthdayList = globalWhenList
                      .where((item) =>
                  item['category'] == 'Birthdays' && item['date'] != null)
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
                    MaterialPageRoute(
                        builder: (context) => const YourWhenPage()),
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
