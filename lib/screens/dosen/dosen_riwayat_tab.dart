import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';

class DosenRiwayatTab extends StatefulWidget {
  final String uid;
  final String statusMode; // 'pending' atau 'history'
  final String title;

  const DosenRiwayatTab({required this.uid, required this.statusMode, required this.title});

  @override
  _DosenRiwayatTabState createState() => _DosenRiwayatTabState();
}

class _DosenRiwayatTabState extends State<DosenRiwayatTab> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _processBimbingan(BuildContext context, String docId, String action) {
    TextEditingController _noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(action == 'approved' ? "Setujui?" : "Tolak?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            hintText: "Catatan untuk mahasiswa...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.grey[100]
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approved' ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: Text("KIRIM", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('bimbingan').doc(docId).update({
                'status': action,
                'catatanDosen': _noteCtrl.text,
                'tanggalRespon': FieldValue.serverTimestamp(),
              });

              if (action == 'approved') {
                var doc = await FirebaseFirestore.instance.collection('bimbingan').doc(docId).get();
                DateTime jadwal = (doc['jadwalBimbingan'] as Timestamp).toDate();
                NotificationService().scheduleNotification(
                  id: docId.hashCode, 
                  title: "Jadwal Bimbingan!",
                  body: "Ingat, 1 jam lagi ada bimbingan mahasiswa.",
                  scheduledTime: jadwal,
                );
              }
              Navigator.pop(ctx);
            },
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('bimbingan').where('dosenID', isEqualTo: widget.uid);

    if (widget.statusMode == 'pending') {
      query = query.where('status', isEqualTo: 'pending');
    } else {
      query = query.where('status', whereIn: ['approved', 'rejected']);
    }

    return Scaffold(
      backgroundColor: Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari judul skripsi...",
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.orderBy('tanggalPengajuan', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                
                var docs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data['judul'].toString().toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 50, color: Colors.grey[300]),
                      SizedBox(height: 10),
                      Text("Belum ada data", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                    ],
                  ),
                );

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var bimbingan = docs[index];
                    var data = bimbingan.data() as Map<String, dynamic>;
                    DateTime jadwal = (data['jadwalBimbingan'] as Timestamp).toDate();
                    String mhsID = data['mahasiswaID'];
                    String status = data['status'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('user').doc(mhsID).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return SizedBox();
                        var mhsData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        String namaMhs = mhsData?['nama'] ?? 'Mhs Terhapus';
                        String npmMhs = mhsData?['nomorInduk'] ?? '-';

                        return Container(
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.blue.shade50,
                                        child: Text(namaMhs.isNotEmpty ? namaMhs[0] : "?", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(namaMhs, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 14)),
                                          Text(npmMhs, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: status == 'pending' ? Colors.orange.shade50 : (status == 'approved' ? Colors.green.shade50 : Colors.red.shade50),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      status == 'pending' ? 'Menunggu' : (status == 'approved' ? 'Disetujui' : 'Ditolak'),
                                      style: TextStyle(
                                        fontSize: 10, 
                                        fontFamily: 'Poppins', 
                                        fontWeight: FontWeight.w600,
                                        color: status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(data['judul'], style: TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.3)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(DateFormat('EEEE, dd MMM • HH:mm').format(jadwal), style: TextStyle(fontSize: 12, color: Colors.grey[700], fontFamily: 'Poppins')),
                                ],
                              ),
                              
                              if (status == 'pending') ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            side: BorderSide(color: Colors.red.shade200)
                                          ),
                                          onPressed: () => _processBimbingan(context, bimbingan.id, 'rejected'),
                                          child: Text("Tolak", style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: 0
                                          ),
                                          onPressed: () => _processBimbingan(context, bimbingan.id, 'approved'),
                                          child: Text("Terima", style: TextStyle(fontFamily: 'Poppins')),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}