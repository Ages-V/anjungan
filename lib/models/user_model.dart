class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role; // 'admin', 'dosen', 'mahasiswa'
  final String? nomorInduk; // NPM / NIDN
  final String? prodi;
  final String? dospemID;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.nomorInduk,
    this.prodi,
    this.dospemID,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      nama: data['nama'] ?? 'Tanpa Nama',
      role: data['role'] ?? 'mahasiswa',
      nomorInduk: data['nomorInduk'],
      prodi: data['prodi'],
      dospemID: data['dospemID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama': nama,
      'role': role,
      'nomorInduk': nomorInduk,
      'prodi': prodi,
      'dospemID': dospemID,
    };
  }
}