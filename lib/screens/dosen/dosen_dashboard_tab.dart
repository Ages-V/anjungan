import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mahasiswa_list_page.dart'; // Pastikan file ini ada (lihat paling bawah)

class DosenDashboardTab extends StatelessWidget {
  final String uid;
  const DosenDashboardTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFigmaHeader(),
          
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('user').doc(uid).get(),
                  builder: (context, snapshot) {
                    String nama = "Dosen";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      nama = data['nama'] ?? "Dosen";
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat Datang,', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey)),
                        Text(
                          nama,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 25),

                // Row Kartu Statistik
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('user')
                            .where('dospemID', isEqualTo: uid)
                            .where('role', isEqualTo: 'mahasiswa')
                            .snapshots(),
                        builder: (context, snapshot) {
                          String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
                          return _buildFigmaCard(
                            context,
                            icon: Icons.groups_rounded,
                            count: count,
                            label: "Mahasiswa",
                            hasButton: true,
                            onTapDetail: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MahasiswaListPage(uid: uid)));
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bimbingan')
                            .where('dosenID', isEqualTo: uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
                          return _buildFigmaCard(
                            context,
                            icon: Icons.calendar_month_rounded,
                            count: count,
                            label: "Total Jadwal",
                            hasButton: false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.school_rounded, color: Colors.red, size: 28),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANJUNGAN - UTI', style: TextStyle(color: const Color(0xFFFF0000), fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.w800)),
                Text('Aplikasi Pengajuan Jadwal Bimbingan', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaCard(BuildContext context, {required IconData icon, required String count, required String label, bool hasButton = false, VoidCallback? onTapDetail}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.red, size: 28),
                ),
                SizedBox(height: 15),
                Text(count, style: TextStyle(color: Colors.black87, fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins')),
              ],
            ),
          ),
          if (hasButton)
            GestureDetector(
              onTap: onTapDetail,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFE70B0B),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                ),
                child: Text('Lihat Detail', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}