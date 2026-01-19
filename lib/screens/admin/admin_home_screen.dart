import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

// Import halaman Manage User
import 'manage_user_screen.dart'; 

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Warna Tema
  final Color primaryColor = const Color(0xFFA50000);
  final Color secondaryColor = const Color(0xFF8B0000);
  final Color backgroundColor = const Color(0xFFF2F4F7);

  // State Navigasi
  int _selectedIndex = 0;
  String _pageTitle = "Dashboard Admin";

  // === WIDGET 1: DASHBOARD STATISTIK ===
  Widget _buildDashboardView() {
    return Container(
      color: backgroundColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: primaryColor));

          var docs = snapshot.data!.docs;
          
          // Hitung Jumlah secara Realtime
          int jumlahDosen = docs.where((doc) => doc['role'] == 'dosen').length;
          int jumlahMhs = docs.where((doc) => doc['role'] == 'mahasiswa').length;

          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Statistik Kampus", 
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black87
                  )
                ),
                SizedBox(height: 20),
                
                // Row untuk Kartu Statistik
                Row(
                  children: [
                    _buildStatCard(
                      "Total Dosen", 
                      jumlahDosen.toString(), 
                      Icons.school,
                      [Color(0xFFFF0000), Color(0xFFA50000)] // Gradient Merah
                    ),
                    SizedBox(width: 16),
                    _buildStatCard(
                      "Total Mahasiswa", 
                      jumlahMhs.toString(), 
                      Icons.groups,
                      [Color(0xFF434343), Color(0xFF000000)] // Gradient Hitam/Abu
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Helper untuk Kartu Statistik (Modern Gradient Style)
  Widget _buildStatCard(String title, String count, IconData icon, List<Color> gradientColors) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 5)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 16),
            Text(
              count, 
              style: TextStyle(
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'
              )
            ),
            Text(
              title, 
              style: TextStyle(
                color: Colors.white.withOpacity(0.9), 
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500
              )
            ),
          ],
        ),
      ),
    );
  }

  // === MAIN BUILD ===
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildDashboardView(), // Index 0
      ManageUserScreen(),    // Index 1
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      // Tampilkan AppBar HANYA jika di Dashboard (Index 0)
      appBar: _selectedIndex == 0 
          ? AppBar(
              title: Text(
                _pageTitle, 
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)
              ),
              backgroundColor: primaryColor,
              elevation: 0,
              centerTitle: true,
            ) 
          : null, 
      
      drawer: Drawer(
        child: Column(
          children: [
            // Header Sidebar
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('user').doc(uid).get(),
              builder: (context, snapshot) {
                String nama = "Admin";
                String email = "admin@teknokrat.ac.id";

                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  nama = data['nama'] ?? "Admin";
                  email = data['email'] ?? "-";
                }

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    image: DecorationImage(
                      image: NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"), // Pattern halus (opsional)
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(primaryColor, BlendMode.darken)
                    )
                  ),
                  accountName: Text(
                    nama, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16)
                  ),
                  accountEmail: Text(
                    email,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.admin_panel_settings, size: 40, color: primaryColor),
                  ),
                );
              },
            ),

            // Menu Item 1: Dashboard
            _buildDrawerItem(0, "Dashboard", Icons.dashboard_outlined),
            
            // Menu Item 2: Kelola User
            _buildDrawerItem(1, "Kelola User", Icons.people_alt_outlined),
            
            Spacer(),
            
            Divider(),
            // Menu Item 3: Logout
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFFA50000)),
              title: Text(
                "Keluar", 
                style: TextStyle(
                  color: Color(0xFFA50000), 
                  fontFamily: 'Poppins', 
                  fontWeight: FontWeight.bold
                )
              ),
              onTap: () async {
                 await AuthService().logout();
                 Navigator.pushReplacementNamed(context, '/');
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  // Fungsi Pembantu untuk membuat Item Sidebar
  Widget _buildDrawerItem(int index, String title, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? primaryColor : Colors.grey[600]
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isSelected ? primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      tileColor: isSelected ? primaryColor.withOpacity(0.08) : null, // Background tipis saat dipilih
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _pageTitle = title;
        });
        Navigator.pop(context); // Tutup drawer
      },
    );
  }
}