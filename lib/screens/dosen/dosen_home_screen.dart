import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dosen_dashboard_tab.dart';
import 'dosen_riwayat_tab.dart';
import 'dosen_profile_tab.dart';

class DosenHomeScreen extends StatefulWidget {
  @override
  _DosenHomeScreenState createState() => _DosenHomeScreenState();
}

class _DosenHomeScreenState extends State<DosenHomeScreen> {
  int _selectedIndex = 0;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    // List Halaman
    final List<Widget> _pages = [
      DosenDashboardTab(uid: uid),
      // Tab 2: Permintaan Masuk (Status: pending)
      DosenRiwayatTab(uid: uid, statusMode: 'pending', title: "Permintaan Masuk"),
      // Tab 3: Riwayat (Status: history / approved & rejected)
      DosenRiwayatTab(uid: uid, statusMode: 'history', title: "Riwayat Bimbingan"),
      DosenProfileTab(uid: uid),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xFFE70B0B),
            unselectedItemColor: Colors.grey[400],
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Permintaan'),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}