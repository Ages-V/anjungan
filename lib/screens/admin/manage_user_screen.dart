import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class ManageUserScreen extends StatefulWidget {
  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  
  // Controller untuk input pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi Hapus User
  void _deleteUser(BuildContext context, String docId, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus User?"),
        content: Text("Yakin ingin menghapus $nama?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("HAPUS"),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('user').doc(docId).delete();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data terhapus")));
            },
          )
        ],
      )
    );
  }

  // Widget untuk List User per Kategori
  Widget _buildList(BuildContext context, String roleFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user') 
          .where('role', isEqualTo: roleFilter) 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Belum ada data $roleFilter"));
        }

        var docs = snapshot.data!.docs;

        // === LOGIKA PENCARIAN (CLIENT SIDE FILTER) ===
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String nama = data['nama'].toString().toLowerCase();
            String nomorInduk = data['nomorInduk'].toString().toLowerCase();
            String query = _searchQuery.toLowerCase();
            return nama.contains(query) || nomorInduk.contains(query);
          }).toList();
        }

        if (docs.isEmpty) {
          return Center(child: Text("Tidak ditemukan user dengan ID/Nama tersebut"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;
            String nama = data['nama'] ?? 'Tanpa Nama';
            String nomorInduk = data['nomorInduk'] ?? '-';
            String prodi = data['prodi'] ?? '-';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: roleFilter == 'dosen' ? Colors.blue : Colors.green,
                  child: Text(nama.isNotEmpty ? nama[0].toUpperCase() : "?", style: TextStyle(color: Colors.white)),
                ),
                title: Text(nama, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("ID: $nomorInduk | $prodi"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.pushNamed(context, '/edit_user', arguments: docs[index]);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(context, docId, nama),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        // === SIDEBAR (DRAWER) ===
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header Admin Dinamis
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('user').doc(uid).get(),
                builder: (context, snapshot) {
                  String nama = "Admin";
                  String email = "admin@system";
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    nama = data['nama'] ?? "Admin";
                    email = data['email'] ?? "-";
                  }
                  return UserAccountsDrawerHeader(
                    accountName: Text(nama, style: TextStyle(fontWeight: FontWeight.bold)),
                    accountEmail: Text(email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue[800]),
                    ),
                    decoration: BoxDecoration(color: Colors.blue[800]),
                  );
                },
              ),

              // Menu: Dashboard
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.grey),
                title: Text("Dashboard"),
                onTap: () {
                  // Kembali ke halaman utama Admin (yang defaultnya dashboard)
                  Navigator.pushReplacementNamed(context, '/admin');
                },
              ),
              Divider(),

              // Menu: Kelola User (Sedang Aktif)
              ListTile(
                leading: Icon(Icons.people_alt, color: Colors.blue),
                title: Text("Kelola User", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                selected: true,
                onTap: () {
                  Navigator.pop(context); // Tutup drawer saja karena sudah disini
                },
              ),
              Divider(),

              // Menu: Logout
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Keluar", style: TextStyle(color: Colors.red)),
                onTap: () async {
                   await AuthService().logout();
                   Navigator.pushReplacementNamed(context, '/');
                },
              )
            ],
          ),
        ),

        // === APP BAR DENGAN SEARCH ===
        appBar: AppBar(
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5)
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Nama atau ID...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    )
                  : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.school), text: "DOSEN"),
              Tab(icon: Icon(Icons.group), text: "MAHASISWA"),
            ],
          ),
        ),
        
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Tambah User Baru",
          onPressed: () => Navigator.pushNamed(context, '/add_user'),
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