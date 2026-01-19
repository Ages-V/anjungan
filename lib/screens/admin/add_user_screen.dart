import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Variable untuk menampung inputan
  String _nama = '';
  String _email = '';
  String _nomorInduk = ''; // NPM / NIDN / NIP
  String _role = 'mahasiswa'; // Default role
  String _prodi = 'Informatika'; // Default prodi
  String? _selectedDospemID; // Khusus Mahasiswa
  
  bool _isLoading = false;

  // Warna Tema
  final Color primaryColor = const Color(0xFFA50000);
  final Color backgroundColor = const Color(0xFFF2F4F7);

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_role == 'mahasiswa' && _selectedDospemID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harap pilih Dosen Pembimbing untuk mahasiswa!"),
          backgroundColor: primaryColor,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().createUserByAdmin(
        email: _email,
        password: _nomorInduk, 
        nama: _nama,
        role: _role,
        nomorInduk: _nomorInduk,
        prodi: _prodi,
        dospemID: _role == 'mahasiswa' ? _selectedDospemID : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User $_nama berhasil dibuat!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context); 

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${e.toString()}"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper untuk Style Input
  InputDecoration _inputDecor(String label, {String? helper}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 2,
      labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[700]),
      helperStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: primaryColor),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Tambah User Baru",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Container Putih (Card Style)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data Pengguna",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Divider(color: Colors.grey[200], thickness: 1.5, height: 24),

                    // 1. DROPDOWN ROLE
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: _inputDecor("Role Pengguna"),
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      items: ['mahasiswa', 'dosen', 'admin'].map((r) => 
                        DropdownMenuItem(value: r, child: Text(r.toUpperCase()))
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                          _role = val!;
                          if (_role != 'mahasiswa') _selectedDospemID = null;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // 2. NAMA LENGKAP
                    TextFormField(
                      decoration: _inputDecor("Nama Lengkap"),
                      style: TextStyle(fontFamily: 'Poppins'),
                      validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null,
                      onSaved: (val) => _nama = val!,
                    ),
                    SizedBox(height: 16),

                    // 3. EMAIL
                    TextFormField(
                      decoration: _inputDecor("Email"),
                      style: TextStyle(fontFamily: 'Poppins'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => (val != null && !val.contains('@')) ? "Format email salah" : null,
                      onSaved: (val) => _email = val!,
                    ),
                    SizedBox(height: 16),

                    // 4. NOMOR INDUK
                    TextFormField(
                      decoration: _inputDecor(
                        "Nomor Induk (NPM/NIDN/NIP)",
                        helper: "Digunakan sebagai Password Default akun.",
                      ),
                      style: TextStyle(fontFamily: 'Poppins'),
                      validator: (val) => (val == null || val.length < 5) ? "Minimal 5 karakter" : null,
                      onSaved: (val) => _nomorInduk = val!,
                    ),
                    SizedBox(height: 16),

                    // 5. PRODI
                    TextFormField(
                      initialValue: "Informatika",
                      decoration: _inputDecor("Program Studi"),
                      style: TextStyle(fontFamily: 'Poppins'),
                      onSaved: (val) => _prodi = val!,
                    ),
                    SizedBox(height: 20),

                    // 6. PILIH DOSEN (Kondisional)
                    if (_role == 'mahasiswa') ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F5), // Merah sangat muda
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school, color: primaryColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Dosen Pembimbing",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('user')
                                  .where('role', isEqualTo: 'dosen').snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator(color: primaryColor));
                                }
                                
                                if (snapshot.data!.docs.isEmpty) {
                                  return Text(
                                    "Belum ada data Dosen. Tambahkan user Dosen dulu.", 
                                    style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                                  );
                                }
                                
                                var dosens = snapshot.data!.docs;
                                return DropdownButtonFormField<String>(
                                  value: _selectedDospemID,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  hint: Text("Pilih Nama Dosen", style: TextStyle(fontFamily: 'Poppins')),
                                  items: dosens.map((doc) {
                                    var data = doc.data() as Map<String, dynamic>;
                                    return DropdownMenuItem(
                                      value: doc.id,
                                      child: Text(
                                        "${data['nama']} (${data['nomorInduk']})",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedDospemID = val),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],

                    // 7. TOMBOL SIMPAN (Gradient Button)
                    _isLoading 
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
                      : InkWell(
                          onTap: _submit,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFF0000), // Merah Terang
                                  Color(0xFF8B0000), // Merah Gelap
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "SIMPAN USER",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}