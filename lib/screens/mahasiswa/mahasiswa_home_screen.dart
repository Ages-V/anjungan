import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';

// Import Tab-tab yang dipisah
import 'mahasiswa_dashboard_tab.dart';
import 'mahasiswa_riwayat_tab.dart';
import 'mahasiswa_profile_tab.dart';

class MahasiswaHomeScreen extends StatefulWidget {
  @override
  _MahasiswaHomeScreenState createState() => _MahasiswaHomeScreenState();
}

class _MahasiswaHomeScreenState extends State<MahasiswaHomeScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncNotifications();
  }

  // Logic Notifikasi (Tetap disini karena dijalankan saat app mulai)
  void _syncNotifications() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('bimbingan')
        .where('mahasiswaID', isEqualTo: uid)
        .where('status', isEqualTo: 'approved')
        .get();

    for (var doc in snapshot.docs) {
      DateTime jadwal = (doc['jadwalBimbingan'] as Timestamp).toDate();
      if (jadwal.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          id: doc.id.hashCode,
          title: "Pengingat Bimbingan",
          body: "Persiapkan diri! Bimbingan skripsi 1 jam lagi.",
          scheduledTime: jadwal,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // List Halaman
    final List<Widget> _pages = [
      MahasiswaDashboardTab(uid: uid), // Index 0
      MahasiswaRiwayatTab(uid: uid),   // Index 1
      MahasiswaProfileTab(uid: uid),   // Index 2
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
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}