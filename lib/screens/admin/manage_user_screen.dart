import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUserScreen extends StatefulWidget {
  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  
  // Controller Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Warna Tema
  final Color primaryColor = const Color(0xFFA50000);
  final Color backgroundColor = const Color(0xFFF2F4F7);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI HAPUS USER ---
  void _deleteUser(BuildContext context, String docId, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Hapus User?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text("Anda yakin ingin menghapus user '$nama'?\nData yang dihapus tidak dapat dikembalikan.", 
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("HAPUS", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('user').doc(docId).delete();
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Colors.green)
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red)
                );
              }
            },
          )
        ],
      )
    );
  }

  // --- WIDGET LIST BUILDER ---
  Widget _buildList(BuildContext context, String roleFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user') 
          .where('role', isEqualTo: roleFilter) 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 60, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text("Belum ada data $roleFilter", 
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
              ],
            ),
          );
        }

        var docs = snapshot.data!.docs;

        // FILTER PENCARIAN (Client Side)
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String nama = (data['nama'] ?? '').toString().toLowerCase();
            String nomorInduk = (data['nomorInduk'] ?? '').toString().toLowerCase();
            String query = _searchQuery.toLowerCase();
            return nama.contains(query) || nomorInduk.contains(query);
          }).toList();
        }

        if (docs.isEmpty) {
          return Center(
            child: Text("User tidak ditemukan.", 
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          );
        }

        // LIST VIEW
        return ListView.builder(
          padding: EdgeInsets.only(top: 10, bottom: 80), // Bottom padding untuk FAB
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;
            String nama = data['nama'] ?? 'Tanpa Nama';
            String nomorInduk = data['nomorInduk'] ?? '-';
            String prodi = data['prodi'] ?? '-';

            // Ambil inisial nama untuk Avatar
            String inisial = nama.isNotEmpty ? nama[0].toUpperCase() : "?";

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: roleFilter == 'dosen' 
                      ? primaryColor.withOpacity(0.1) 
                      : Colors.blue.withOpacity(0.1),
                  child: Text(
                    inisial, 
                    style: TextStyle(
                      color: roleFilter == 'dosen' ? primaryColor : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 18
                    )
                  ),
                ),
                title: Text(
                  nama, 
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  )
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text("$nomorInduk  |  $prodi", 
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Edit
                    _actionButton(
                      icon: Icons.edit_rounded, 
                      color: Colors.orange, 
                      onTap: () => Navigator.pushNamed(context, '/edit_user', arguments: docs[index])
                    ),
                    SizedBox(width: 8),
                    // Tombol Hapus
                    _actionButton(
                      icon: Icons.delete_outline_rounded, 
                      color: Colors.red, 
                      onTap: () => _deleteUser(context, docId, nama)
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget Helper Tombol Kecil
  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: backgroundColor,
        
        // --- APP BAR KHUSUS ---
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: "Cari Nama atau ID...",
                hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
            tabs: [
              Tab(text: "DOSEN", icon: Icon(Icons.school_outlined)),
              Tab(text: "MAHASISWA", icon: Icon(Icons.groups_outlined)),
            ],
          ),
        ),
        
        // --- FAB ADD USER ---
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add_user'),
          backgroundColor: primaryColor,
          icon: Icon(Icons.add),
          label: Text("Tambah User", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        ),
        
        body: TabBarView(
          children: [
            _buildList(context, 'dosen'),     
            _buildList(context, 'mahasiswa'), 
          ],
        ),
      ),
    );
  }
}