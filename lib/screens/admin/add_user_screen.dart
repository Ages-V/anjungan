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

  void _submit() async {
    // 1. Validasi Form Standar
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // 2. Validasi Khusus: Jika Mahasiswa, Wajib pilih Dosen
    if (_role == 'mahasiswa' && _selectedDospemID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harap pilih Dosen Pembimbing untuk mahasiswa!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Panggil Service untuk buat User (Tanpa Logout Admin)
      // Password default diset sama dengan Nomor Induk (NPM/NIDN)
      await AuthService().createUserByAdmin(
        email: _email,
        password: _nomorInduk, 
        nama: _nama,
        role: _role,
        nomorInduk: _nomorInduk,
        prodi: _prodi,
        dospemID: _role == 'mahasiswa' ? _selectedDospemID : null,
      );

      // 4. Sukses
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User $_nama berhasil dibuat!"))
      );
      Navigator.pop(context); // Kembali ke dashboard

    } catch (e) {
      // 5. Error Handler
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${e.toString()}"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah User Baru")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. DROPDOWN ROLE
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: "Role Pengguna",
                  border: OutlineInputBorder(),
                ),
                items: ['mahasiswa', 'dosen', 'admin'].map((r) => 
                  DropdownMenuItem(value: r, child: Text(r.toUpperCase()))
                ).toList(),
                onChanged: (val) {
                  setState(() {
                    _role = val!;
                    // Reset dospem jika pindah role bukan mahasiswa
                    if (_role != 'mahasiswa') _selectedDospemID = null;
                  });
                },
              ),
              SizedBox(height: 16),

              // 2. NAMA LENGKAP
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null,
                onSaved: (val) => _nama = val!,
              ),
              SizedBox(height: 16),

              // 3. EMAIL
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val != null && !val.contains('@')) ? "Format email salah" : null,
                onSaved: (val) => _email = val!,
              ),
              SizedBox(height: 16),

              // 4. NOMOR INDUK (NPM/NIDN) - SUDAH DIPERBAIKI
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Nomor Induk (NPM/NIDN/NIP)",
                  // Helper text sekarang ada di dalam InputDecoration (BENAR)
                  helperText: "Akan digunakan sebagai Password Default akun ini.",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.length < 5) ? "Minimal 5 karakter" : null,
                onSaved: (val) => _nomorInduk = val!,
              ),
              SizedBox(height: 16),

              // 5. PRODI
              TextFormField(
                initialValue: "Informatika",
                decoration: InputDecoration(
                  labelText: "Program Studi",
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _prodi = val!,
              ),
              SizedBox(height: 16),

              // 6. PILIH DOSEN PEMBIMBING (Hanya Muncul Jika Role = Mahasiswa)
              if (_role == 'mahasiswa') ...[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pilih Dosen Pembimbing:", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('user')
                            .where('role', isEqualTo: 'dosen').snapshots(),
                        builder: (context, snapshot) {
                          // Loading State
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          
                          // Jika belum ada dosen sama sekali
                          if (snapshot.data!.docs.isEmpty) {
                            return Text("Belum ada data Dosen. Tambahkan user Dosen dulu.", 
                              style: TextStyle(color: Colors.red));
                          }
                          
                          // Dropdown Dosen
                          var dosens = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            value: _selectedDospemID,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            hint: Text("Pilih Nama Dosen"),
                            items: dosens.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: doc.id, // Value-nya adalah UID Dosen
                                child: Text("${data['nama']} (${data['nomorInduk']})"),
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

              // 7. TOMBOL SUBMIT
              _isLoading 
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("SIMPAN USER BARU", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}