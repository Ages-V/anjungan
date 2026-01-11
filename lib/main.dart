import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

// --- CONFIG ---
import 'firebase_options.dart';

// --- SERVICES ---
import 'services/notification_service.dart';

// --- SCREENS (AUTH) ---
import 'screens/login_screen.dart';

// --- SCREENS (ADMIN) ---
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/add_user_screen.dart';
import 'screens/admin/manage_user_screen.dart';
import 'screens/admin/edit_user_screen.dart';

// --- SCREENS (DOSEN) ---
import 'screens/dosen/dosen_home_screen.dart';

// --- SCREENS (MAHASISWA) ---
import 'screens/mahasiswa/mahasiswa_home_screen.dart';
import 'screens/mahasiswa/add_bimbingan_screen.dart';
import 'screens/mahasiswa/edit_bimbingan_screen.dart';
import 'screens/mahasiswa/mahasiswa_riwayat_tab.dart'; // Pastikan diimport jika dipakai

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Inisialisasi Notifikasi & Permission
  await _initServices();

  runApp(MyApp());
}

// Fungsi terpisah untuk init service agar main() lebih bersih
Future<void> _initServices() async {
  final notifService = NotificationService();
  await notifService.init();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Bimbingan',
      debugShowCheckedModeBanner: false,
      
      // Tema Aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // Sesuaikan dengan preferensi UI kamu
      ),
      
      // Halaman Utama: Cek Auth Dulu
      home: AuthGate(),

      // Routing Table
      routes: {
        '/login': (context) => LoginScreen(),
        
        // Admin Routes
        '/admin': (context) => AdminHomeScreen(),
        '/manage_users': (context) => ManageUserScreen(),
        '/add_user': (context) => AddUserScreen(),
        '/edit_user': (context) => EditUserScreen(),
        
        // Dosen Routes
        '/dosen': (context) => DosenHomeScreen(),
        
        // Mahasiswa Routes
        '/mahasiswa': (context) => MahasiswaHomeScreen(),
        '/add_bimbingan': (context) => AddBimbinganScreen(),
        '/edit_bimbingan': (context) => EditBimbinganScreen(),
      },
    );
  }
}

/// Widget ini bertugas sebagai "Satpam" (Gatekeeper).
/// Mengecek apakah user login? Jika ya, siapa dia (role)?
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Sedang mengecek status login
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // 2. Belum Login -> Arahkan ke Login
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        // 3. Sudah Login -> Cek Data & Role di Firestore
        final User loggedInUser = snapshot.data!;
        return _RoleCheck(uid: loggedInUser.uid);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Widget khusus untuk mengecek Role di Firestore
class _RoleCheck extends StatelessWidget {
  final String uid;
  const _RoleCheck({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(uid).get(),
      builder: (context, snapshot) {
        
        // A. Loading data user
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // B. Error koneksi
        if (snapshot.hasError) {
          return _buildErrorScreen("Terjadi kesalahan koneksi:\n${snapshot.error}");
        }

        // C. Data Ditemukan -> Cek Role
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String role = data['role'] ?? 'unknown';

          switch (role) {
            case 'admin':
              return AdminHomeScreen();
            case 'dosen':
              return DosenHomeScreen();
            case 'mahasiswa':
              return MahasiswaHomeScreen();
            default:
              return _buildUnknownRoleScreen(role);
          }
        }

        // D. KASUS KRITIS: Login Auth Berhasil, Tapi Data Firestore Kosong
        // Kita tampilkan layar debug, JANGAN logout otomatis.
        return _buildMissingDataScreen(uid);
      },
    );
  }

  // --- Helper Widgets untuk Tampilan Error/Debug ---

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildUnknownRoleScreen(String role) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person, size: 60, color: Colors.orange),
            SizedBox(height: 20),
            Text("Akses Ditolak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Role akun Anda ('$role') tidak dikenali."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text("Keluar"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMissingDataScreen(String uid) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Data Pengguna Tidak Ditemukan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Akun Anda terdaftar di Authentication, tetapi data profil tidak ditemukan di Firestore.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                uid,
                style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Text("Salin UID di atas dan buat dokumen di Firestore.", style: TextStyle(fontSize: 12, color: Colors.blue)),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text("Logout & Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
      ),
    );
  }
}