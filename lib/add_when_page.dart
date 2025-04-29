import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddWhenPage extends StatefulWidget {
  @override
  _AddWhenPageState createState() => _AddWhenPageState();
}

class _AddWhenPageState extends State<AddWhenPage> {
  final TextEditingController _titleController = TextEditingController();
  String? selectedCategory;
  DateTime? selectedDate;

  final Map<String, Color> categoryColors = {
    'Personal': Color(0xFF00E500),
    'Life Goals': Color(0xFFFFD700),
    'Holidays': Colors.red,
    'Birthdays': Colors.blue,
    'Tugas': Color(0xFF710084),
  };

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
    String userInput = _titleController.text.trim();
    String formattedTitle = userInput.isNotEmpty ? "When yes $userInput?" : "";

    print("Write your When: $formattedTitle");
    print("Kategori: $selectedCategory");
    print("Tanggal: ${selectedDate != null ? DateFormat.yMMMd().format(selectedDate!) : 'Tidak ditentukan'}");
    Navigator.pop(context, {
      'title': formattedTitle,
      'category': selectedCategory,
      'date': selectedDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF213339),
      appBar: AppBar(
        title: Text(
          "Add New When",
          style: GoogleFonts.dmSans(
            color: Color(0xFF213339),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFEAFFF9),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF213339)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Write your When:", style: GoogleFonts.dmSans(fontSize: 18, color: Color(0xFFEAFFF9), fontWeight: FontWeight.bold,)),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "misalnya: I magang",
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 20),
            Text("Kategori:", style: GoogleFonts.dmSans(fontSize: 18, color: Color(0xFFEAFFF9), fontWeight: FontWeight.bold,)),
            Wrap(
              spacing: 10,
              children: categoryColors.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.key),
                  labelStyle: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selected: selectedCategory == entry.key,
                  selectedColor: entry.value,
                  backgroundColor: entry.value.withOpacity(0.4),
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = entry.key;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEAFFF9),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}
