import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MahasiswaDashboardTab extends StatelessWidget {
  final String uid;
  const MahasiswaDashboardTab({required this.uid});

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
                    String nama = "Mahasiswa";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      nama = data['nama'] ?? "Mahasiswa";
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat Datang,', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey)),
                        SizedBox(height: 4),
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
                
                SizedBox(height: 30),

                // KARTU STATISTIK
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bimbingan')
                            .where('mahasiswaID', isEqualTo: uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
                          return _buildStatCard(
                            icon: Icons.description_rounded,
                            iconColor: Colors.blueAccent,
                            bgIconColor: Colors.blue.shade50,
                            count: count,
                            label: "Total Pengajuan",
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bimbingan')
                            .where('mahasiswaID', isEqualTo: uid)
                            .where('status', isEqualTo: 'approved')
                            .snapshots(),
                        builder: (context, snapshot) {
                          String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "-";
                          return _buildStatCard(
                            icon: Icons.check_circle_rounded,
                            iconColor: Colors.green,
                            bgIconColor: Colors.green.shade50,
                            count: count,
                            label: "Disetujui",
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // BANNER GRADIENT
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/add_bimbingan'),
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFDD2476).withOpacity(0.4),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ajukan Bimbingan?",
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Ayo bimbingan sekarang!",
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.add, color: Color(0xFFE70B0B), size: 24),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.school_rounded, color: Color(0xFFE70B0B), size: 28),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ANJUNGAN - UTI', style: TextStyle(color: const Color(0xFFE70B0B), fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.w800)),
              Text('Portal Mahasiswa', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required Color bgIconColor, required String count, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgIconColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          SizedBox(height: 15),
          Text(count, style: TextStyle(color: Colors.black87, fontSize: 28, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}