import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserScreen extends StatefulWidget {
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _namaCtrl;
  late TextEditingController _nomorIndukCtrl;
  late TextEditingController _prodiCtrl;
  
  String _role = 'mahasiswa';
  String? _selectedDospemID;
  late String _docId; 
  bool _isLoading = false;
  bool _isInit = true;

  // Warna Tema
  final Color primaryColor = const Color(0xFFA50000);
  final Color backgroundColor = const Color(0xFFF2F4F7);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // 1. Tangkap Data yang dikirim dari halaman Admin Home
      final doc = ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;
      final data = doc.data() as Map<String, dynamic>;

      _docId = doc.id;
      _namaCtrl = TextEditingController(text: data['nama']);
      _nomorIndukCtrl = TextEditingController(text: data['nomorInduk']);
      _prodiCtrl = TextEditingController(text: data['prodi'] ?? 'Informatika');
      _role = data['role'];
      _selectedDospemID = data['dospemID'];
      
      _isInit = false;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi Dospem
    if (_role == 'mahasiswa' && _selectedDospemID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap pilih Dosen Pembimbing!"), backgroundColor: primaryColor)
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // UPDATE DATA KE FIRESTORE
      await FirebaseFirestore.instance.collection('user').doc(_docId).update({
        'nama': _namaCtrl.text,
        'nomorInduk': _nomorIndukCtrl.text,
        'prodi': _prodiCtrl.text,
        'role': _role, // Role tetap disimpan untuk integritas data
        'dospemID': _role == 'mahasiswa' ? _selectedDospemID : null,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data berhasil diperbarui"), backgroundColor: Colors.green)
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper Style Input
  InputDecoration _inputDecor(String label, {bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[700]),
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
      fillColor: enabled ? Colors.white : Colors.grey.shade200, // Abu-abu jika disable
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Edit Data User",
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
            // Container Card Putih
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
                      "Form Edit", 
                      style: TextStyle(
                        fontFamily: 'Poppins', 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Divider(height: 24, thickness: 1),

                    // 1. ROLE (READ ONLY)
                    TextFormField(
                      initialValue: _role.toUpperCase(),
                      enabled: false, // Read only
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[700]),
                      decoration: _inputDecor("Role (Tidak bisa diubah)", enabled: false),
                    ),
                    SizedBox(height: 16),

                    // 2. NAMA LENGKAP
                    TextFormField(
                      controller: _namaCtrl,
                      style: TextStyle(fontFamily: 'Poppins'),
                      decoration: _inputDecor("Nama Lengkap"),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    SizedBox(height: 16),

                    // 3. NOMOR INDUK
                    TextFormField(
                      controller: _nomorIndukCtrl,
                      style: TextStyle(fontFamily: 'Poppins'),
                      decoration: _inputDecor("Nomor Induk (NPM/NIDN/NIP)"),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    SizedBox(height: 16),

                    // 4. PRODI
                    TextFormField(
                      controller: _prodiCtrl,
                      style: TextStyle(fontFamily: 'Poppins'),
                      decoration: _inputDecor("Program Studi"),
                    ),
                    
                    // 5. DOSEN PEMBIMBING (Khusus Mahasiswa)
                    if (_role == 'mahasiswa') ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5F5), // Merah Muda Background
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              "Dosen Pembimbing",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('user')
                                  .where('role', isEqualTo: 'dosen').snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return LinearProgressIndicator(color: primaryColor);
                                
                                var dosens = snapshot.data!.docs;

                                // Cek validasi data: Jika dosen yang dulu dipilih sudah dihapus
                                bool isValueValid = _selectedDospemID == null || 
                                    dosens.any((doc) => doc.id == _selectedDospemID);
                                
                                if (!isValueValid) _selectedDospemID = null;

                                return DropdownButtonFormField<String>(
                                  value: _selectedDospemID, 
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                  ),
                                  hint: Text("Pilih Dosen Pembimbing"),
                                  items: dosens.map((doc) {
                                    var dData = doc.data() as Map<String, dynamic>;
                                    return DropdownMenuItem(
                                      value: doc.id,
                                      child: Text(
                                        "${dData['nama']}", 
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedDospemID = val),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],

                    SizedBox(height: 30),

                    // 6. TOMBOL SIMPAN (Gradient)
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
                              "SIMPAN PERUBAHAN",
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