import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MahasiswaRiwayatTab extends StatefulWidget {
  final String uid;
  const MahasiswaRiwayatTab({required this.uid});

  @override
  _MahasiswaRiwayatTabState createState() => _MahasiswaRiwayatTabState();
}

class _MahasiswaRiwayatTabState extends State<MahasiswaRiwayatTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = "";
  String _filterStatus = "Semua";

  // Warna Konstanta Biar Konsisten
  final Color _bg = Color(0xFFF2F4F7);
  final Color _primary = Color(0xFFE70B0B);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // === LOGIKA FILTER DATA ===
  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final judul = data['judul'].toString().toLowerCase();
      final status = data['status'];

      final matchSearch = judul.contains(_searchQuery);
      final matchFilter = _filterStatus == "Semua" || 
          (_filterStatus == "Pending" && status == 'pending') ||
          (_filterStatus == "Disetujui" && status == 'approved') ||
          (_filterStatus == "Ditolak" && status == 'rejected');

      return matchSearch && matchFilter;
    }).toList();
  }

  // === MAIN BUILD ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Riwayat Bimbingan", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true, automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildListStream()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primary,
        child: Icon(Icons.add_rounded, size: 30),
        onPressed: () => Navigator.pushNamed(context, '/add_bimbingan'),
      ),
    );
  }

  // === WIDGET 1: HEADER (SEARCH & CHIPS) ===
  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Cari judul skripsi...",
                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ["Semua", "Pending", "Disetujui", "Ditolak"].map((e) => _buildChip(e)).toList()),
          ),
        ],
      ),
    );
  }

  // === WIDGET 2: STREAM & LIST ===
  Widget _buildListStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bimbingan')
          .where('mahasiswaID', isEqualTo: widget.uid)
          .orderBy('tanggalPengajuan', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        
        final filteredDocs = _filterDocs(snapshot.data!.docs);

        if (filteredDocs.isEmpty) {
          return Center(child: Text("Data tidak ditemukan", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)));
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredDocs.length,
          itemBuilder: (ctx, i) => _buildHistoryCard(filteredDocs[i]),
        );
      },
    );
  }

  // === WIDGET 3: KARTU RIWAYAT (ITEM) ===
  Widget _buildHistoryCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final jadwal = (data['jadwalBimbingan'] as Timestamp).toDate();
    final status = data['status'];
    
    // Logic Edit 30 Menit
    final isPending = status == 'pending';
    final sisaMenit = 30 - DateTime.now().difference((data['tanggalPengajuan'] as Timestamp).toDate()).inMinutes;
    final bisaEdit = isPending && sisaMenit > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildStatusChip(status),
            Text(DateFormat('dd MMM • HH:mm').format(jadwal), style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins')),
          ]),
          SizedBox(height: 12),
          Text(data['judul'], style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
          
          if (data.containsKey('idBimbingan'))
            Text("ID: ${data['idBimbingan']}", style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontFamily: 'Poppins')),
          
          if (data['catatanDosen'] != "")
            Container(
              margin: EdgeInsets.only(top: 10), padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: Colors.red), SizedBox(width: 8),
                Expanded(child: Text("${data['catatanDosen']}", style: TextStyle(color: Colors.red[800], fontSize: 11, fontFamily: 'Poppins')))
              ]),
            ),

          if (bisaEdit) ...[
            Divider(height: 25),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Sisa waktu edit: $sisaMenit menit", style: TextStyle(fontSize: 11, color: Colors.orange, fontFamily: 'Poppins')),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.pushNamed(context, '/edit_bimbingan', arguments: {
                    'docId': doc.id, 'judul': data['judul'], 'deskripsi': data['deskripsi'], 'jadwal': data['jadwalBimbingan']
                  }),
                  child: Text("Edit", style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
                ),
              )
            ])
          ]
        ],
      ),
    );
  }

  // === HELPER WIDGETS KECIL ===
  Widget _buildChip(String label) {
    bool isActive = _filterStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: isActive ? _primary.withOpacity(0.3) : Colors.grey.withOpacity(0.1), blurRadius: 5)],
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isActive ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red);
    String label = status == 'pending' ? 'Menunggu' : (status == 'approved' ? 'Disetujui' : 'Ditolak');
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: color)),
    );
  }
}