import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

// Import halaman Manage User yang sudah kita buat sebelumnya
import 'manage_user_screen.dart'; 

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // State Navigasi
  int _selectedIndex = 0;
  String _pageTitle = "Dashboard Admin";

  // === WIDGET 1: DASHBOARD STATISTIK ===
  Widget _buildDashboardView() {
    return StreamBuilder<QuerySnapshot>(
      // ⚠️ Pastikan nama collection sesuai: 'user' atau 'users'
      stream: FirebaseFirestore.instance.collection('user').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var docs = snapshot.data!.docs;
        
        // Hitung Jumlah secara Realtime
        int jumlahDosen = docs.where((doc) => doc['role'] == 'dosen').length;
        int jumlahMhs = docs.where((doc) => doc['role'] == 'mahasiswa').length;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Statistik Kampus", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              
              // Row untuk Kartu Statistik
              Row(
                children: [
                  _buildStatCard("Total Dosen", jumlahDosen.toString(), Colors.blue, Icons.school),
                  SizedBox(width: 16),
                  _buildStatCard("Total Mahasiswa", jumlahMhs.toString(), Colors.green, Icons.people),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget Helper untuk Kartu Statistik
  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(count, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // === MAIN BUILD ===
  @override
  Widget build(BuildContext context) {
    // List Halaman yang akan ditampilkan di body
    final List<Widget> _pages = [
      _buildDashboardView(), // Index 0: Tampilan Dashboard
      ManageUserScreen(),    // Index 1: Tampilan Kelola User (Dari file sebelah)
    ];

    return Scaffold(
      // Tampilkan AppBar HANYA jika di Dashboard (Index 0)
      // Kalau di Manage User (Index 1), kita sembunyikan AppBar ini 
      // karena ManageUserScreen sudah punya AppBar (TabController) sendiri.
      appBar: _selectedIndex == 0 
          ? AppBar(title: Text(_pageTitle)) 
          : null, 
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Sidebar
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

            // Menu Item 1: Dashboard
            _buildDrawerItem(0, "Dashboard", Icons.dashboard),
            Divider(),

            // Menu Item 2: Kelola User
            _buildDrawerItem(1, "Kelola User", Icons.people_alt),
            Divider(),

            // Menu Item 3: Logout
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
      // Body akan berubah sesuai menu yang dipilih
      body: _pages[_selectedIndex],
    );
  }

  // Fungsi Pembantu untuk membuat Item Sidebar
  Widget _buildDrawerItem(int index, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.blue : Colors.black,
          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _pageTitle = title;
        });
        Navigator.pop(context); // Tutup drawer setelah memilih
      },
    );
  }
}