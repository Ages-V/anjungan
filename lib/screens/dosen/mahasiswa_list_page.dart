import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MahasiswaListPage extends StatefulWidget {
  final String uid;
  MahasiswaListPage({required this.uid});

  @override
  __MahasiswaListPageState createState() => __MahasiswaListPageState();
}

class __MahasiswaListPageState extends State<MahasiswaListPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Background abu muda
      appBar: AppBar(
        title: Text(
          "Mahasiswa Bimbingan", 
          style: TextStyle(
            fontFamily: 'Poppins', 
            color: Colors.black87, 
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        // Membuat AppBar melengkung di bawah
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))
        ),
      ),
      body: Column(
        children: [
          // Search Bar Area
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari nama atau NPM...",
                  hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[400], fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.redAccent),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
          ),

          // List Data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'mahasiswa')
                  .where('dospemID', isEqualTo: widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                
                var docs = snapshot.data!.docs;
                
                // Filter Client Side
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String nama = data['nama'].toString().toLowerCase();
                    String npm = (data['nomorInduk'] ?? "").toString().toLowerCase();
                    return nama.contains(_searchQuery) || npm.contains(_searchQuery);
                  }).toList();
                }

                // Info Jumlah Data & List
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            "Total Mahasiswa: ${docs.length}", 
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: docs.isEmpty 
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off_rounded, size: 60, color: Colors.grey[300]),
                              SizedBox(height: 10),
                              Text("Tidak ditemukan", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var data = docs[index].data() as Map<String, dynamic>;
                            String nama = data['nama'] ?? "Tanpa Nama";
                            String npm = data['nomorInduk'] ?? "-";
                            String prodi = data['prodi'] ?? "Informatika";

                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar Custom
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        nama.isNotEmpty ? nama[0].toUpperCase() : "?",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  
                                  // Info Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Text(
                                                npm,
                                                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.black54),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "•  $prodi",
                                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}