import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditBimbinganScreen extends StatefulWidget {
  @override
  _EditBimbinganScreenState createState() => _EditBimbinganScreenState();
}

class _EditBimbinganScreenState extends State<EditBimbinganScreen> {
  final _judulCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedFullDate;
  bool _isLoading = false;
  late String docId;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      docId = args['docId'];
      _judulCtrl.text = args['judul'];
      _descCtrl.text = args['deskripsi'];
      _selectedFullDate = (args['jadwal'] as Timestamp).toDate();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  // === LOGIKA PICKER & UPDATE ===
  Future<void> _pickDateTime() async {
    if (_selectedFullDate == null) return;
    
    // Pilih Tanggal
    DateTime? date = await showDatePicker(
      context: context, initialDate: _selectedFullDate!,
      firstDate: DateTime.now(), lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: _redTheme, child: child!),
    );
    if (date == null) return;

    // Pilih Jam (24 Jam & Input)
    TimeOfDay? time = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(_selectedFullDate!),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(data: _redTheme, child: child!),
      ),
    );

    if (time != null) {
      setState(() => _selectedFullDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }
  }

  void _update() async {
    if (_judulCtrl.text.isEmpty || _selectedFullDate == null) return;
    setState(() => _isLoading = true);
    
    try {
      await FirebaseFirestore.instance.collection('bimbingan').doc(docId).update({
        'judul': _judulCtrl.text,
        'deskripsi': _descCtrl.text,
        'jadwalBimbingan': Timestamp.fromDate(_selectedFullDate!),
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Terupdate!"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === UI UTAMA ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text("Edit Pengajuan", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildInput(_judulCtrl, "Judul Skripsi", Icons.title),
                  SizedBox(height: 16),
                  _buildInput(_descCtrl, "Deskripsi", Icons.notes, maxLines: 4),
                  SizedBox(height: 16),
                  _buildDatePicker(),
                ],
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE70B0B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: _isLoading ? null : _update,
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("SIMPAN PERUBAHAN", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET HELPER (Agar kodingan pendek) ===
  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      style: TextStyle(fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label, filled: true, fillColor: Colors.grey[50],
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDateTime,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200)
        ),
        child: Row(
          children: [
            Icon(Icons.edit_calendar, color: Colors.orange[800]),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Jadwal Baru", style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey[600])),
              Text(_selectedFullDate == null ? "-" : DateFormat('dd MMM yyyy • HH:mm').format(_selectedFullDate!),
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.orange[900])),
            ]),
          ],
        ),
      ),
    );
  }

  // Tema Date Picker Merah
  final ThemeData _redTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(primary: Color(0xFFE70B0B), onPrimary: Colors.white, onSurface: Colors.black),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Color(0xFFE70B0B))),
  );
}