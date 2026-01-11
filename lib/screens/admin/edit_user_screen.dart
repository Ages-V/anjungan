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
  late String _docId; // ID Dokumen yang mau diedit
  bool _isLoading = false;
  bool _isInit = true;

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pilih Dospem!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // UPDATE DATA KE FIRESTORE
      await FirebaseFirestore.instance.collection('user').doc(_docId).update({
        'nama': _namaCtrl.text,
        'nomorInduk': _nomorIndukCtrl.text,
        'prodi': _prodiCtrl.text,
        'role': _role,
        // Jika bukan mahasiswa, set dospemID jadi null
        'dospemID': _role == 'mahasiswa' ? _selectedDospemID : null,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data berhasil diperbarui")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Data User")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Kita disable ganti Role agar tidak merusak data Auth/Logic yg rumit
              // Kalau mau ganti role, sebaiknya hapus user dan buat baru
              TextFormField(
                initialValue: _role.toUpperCase(),
                enabled: false, // Read only
                decoration: InputDecoration(labelText: "Role (Tidak bisa diubah)", border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _namaCtrl,
                decoration: InputDecoration(labelText: "Nama Lengkap"),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nomorIndukCtrl,
                decoration: InputDecoration(labelText: "Nomor Induk"),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _prodiCtrl,
                decoration: InputDecoration(labelText: "Prodi"),
              ),
              
              if (_role == 'mahasiswa') ...[
                SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('user').where('role', isEqualTo: 'dosen').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    var dosens = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedDospemID, // Pastikan value ini ada di list dosen, kalau dospem lama terhapus bisa error
                      decoration: InputDecoration(labelText: "Ganti Dosen Pembimbing"),
                      items: dosens.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text("${doc['nama']}"),
                        );
                      }).toList(),
                      onChanged: (val) => _selectedDospemID = val,
                    );
                  },
                )
              ],

              SizedBox(height: 24),
              _isLoading 
                ? CircularProgressIndicator() 
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _submit, child: Text("SIMPAN PERUBAHAN")),
                  )
            ],
          ),
        ),
      ),
    );
  }
}