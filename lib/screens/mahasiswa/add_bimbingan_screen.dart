import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AddBimbinganScreen extends StatefulWidget {
  @override
  _AddBimbinganScreenState createState() => _AddBimbinganScreenState();
}

class _AddBimbinganScreenState extends State<AddBimbinganScreen> {
  final _judulCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _dospemID;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getDospemID();
  }

  void _getDospemID() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var doc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
    if (mounted) setState(() => _dospemID = doc['dospemID']);
  }

  // === 1. LOGIKA PICKER & SUBMIT ===
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    
    // Pilih Tanggal
    final date = await showDatePicker(
      context: context, initialDate: now.add(Duration(days: 1)),
      firstDate: now, lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: _redTheme, child: child!),
    );
    if (date == null) return;

    // Pilih Jam (24 Jam & Input Mode)
    final time = await showTimePicker(
      context: context, initialTime: TimeOfDay(hour: 9, minute: 0),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(data: _redTheme, child: child!),
      ),
    );

    if (time != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = time;
      });
    }
  }

  void _submit() async {
    if (_dospemID == null || _selectedDate == null || _selectedTime == null || _judulCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lengkapi data!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Gabungkan Date & Time
      final jadwalFix = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      final customID = "BIM-${List.generate(4, (_) => "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[Random().nextInt(36)]).join()}";

      await FirebaseFirestore.instance.collection('bimbingan').doc(customID).set({
        'idBimbingan': customID,
        'mahasiswaID': FirebaseAuth.instance.currentUser!.uid,
        'dosenID': _dospemID,
        'judul': _judulCtrl.text,
        'deskripsi': _descCtrl.text,
        'jadwalBimbingan': Timestamp.fromDate(jadwalFix),
        'tanggalPengajuan': FieldValue.serverTimestamp(),
        'status': 'pending',
        'catatanDosen': '',
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil! ID: $customID"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === 2. UI UTAMA ===
  @override
  Widget build(BuildContext context) {
    if (_dospemID == null) return Scaffold(backgroundColor: Color(0xFFF2F4F7), body: Center(child: CircularProgressIndicator(color: Colors.red)));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text("Ajukan Bimbingan", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Form Pengajuan", style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Isi data berikut untuk dosen pembimbing.", style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE70B0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("AJUKAN SEKARANG", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === 3. WIDGET HELPER (Biar Kodingan Pendek) ===
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
    String tglText = _selectedDate == null ? "Pilih Tanggal & Jam" : DateFormat('EEEE, dd MMM • HH:mm').format(
      DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute));

    return InkWell(
      onTap: _pickDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedDate == null ? Colors.grey[50] : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selectedDate == null ? Colors.transparent : Colors.red.shade200)
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: _selectedDate == null ? Colors.grey : Colors.red),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Rencana Jadwal", style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey[600])),
              Text(tglText, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: _selectedDate == null ? Colors.grey[400] : Colors.red[800])),
            ]),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400])
          ],
        ),
      ),
    );
  }

  final ThemeData _redTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(primary: Color(0xFFE70B0B), onPrimary: Colors.white, onSurface: Colors.black),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Color(0xFFE70B0B))),
  );
}