import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class MahasiswaProfileTab extends StatelessWidget {
  final String uid;
  const MahasiswaProfileTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F7),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('user').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue.shade100, width: 2)),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade100,
                        child: Icon(Icons.person_rounded, size: 60, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(data['nama'] ?? "Mahasiswa", style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(data['email'] ?? "-", style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                      child: Text("Mahasiswa Aktif", style: TextStyle(color: Colors.green, fontSize: 11, fontFamily: 'Poppins')),
                    )
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: Colors.red.shade100)
                      ),
                      onPressed: () async {
                        await AuthService().logout();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded),
                          SizedBox(width: 10),
                          Text("Keluar Aplikasi", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                    SizedBox(height: 20),
                    Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12, fontFamily: 'Poppins'))
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}