import 'package:cloud_firestore/cloud_firestore.dart';

class BimbinganModel {
  final String id;
  final String mahasiswaID;
  final String dosenID;
  final String judul;
  final String deskripsi;
  final String status; // 'pending', 'approved', 'rejected'
  final String catatanDosen;
  final DateTime jadwalBimbingan;
  final DateTime tanggalPengajuan;

  BimbinganModel({
    required this.id,
    required this.mahasiswaID,
    required this.dosenID,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.catatanDosen,
    required this.jadwalBimbingan,
    required this.tanggalPengajuan,
  });

  factory BimbinganModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BimbinganModel(
      id: doc.id,
      mahasiswaID: data['mahasiswaID'] ?? '',
      dosenID: data['dosenID'] ?? '',
      judul: data['judul'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      status: data['status'] ?? 'pending',
      catatanDosen: data['catatanDosen'] ?? '',
      jadwalBimbingan: (data['jadwalBimbingan'] as Timestamp).toDate(),
      tanggalPengajuan: (data['tanggalPengajuan'] as Timestamp).toDate(),
    );
  }
}