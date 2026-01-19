import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      UserModel? user = await AuthService().login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        if (user.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (user.role == 'dosen') {
          Navigator.pushReplacementNamed(context, '/dosen');
        } else if (user.role == 'mahasiswa') {
          Navigator.pushReplacementNamed(context, '/mahasiswa');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data user tidak ditemukan di database.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Gagal: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 350,
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  border: Border.all(
                    width: 1,
                    color: Colors.black.withOpacity(0.10),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// LOGO UNIVERSITAS
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://1.bp.blogspot.com/-rGzybmEYVHM/XyMB2ITDpcI/AAAAAAAAC9k/MzGR0c6iF_ES8VgiLbuDa7r9jWVdoPWSQCLcBGAsYHQ/s1600/download%2BLOGO%2BUniversitas%2BTeknokrat%2BPNG.png',
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFA50000),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    /// JUDUL APLIKASI
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aplikasi Pengajuan Jadwal Bimbingan\n',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'UNIVERSITAS TEKNOKRAT INDONESIA',
                            style: TextStyle(
                              color: Color(0xFFA50000),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40),

                    /// EMAIL
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(0.30),
                        ),
                      ),
                      child: TextField(
                        controller: _emailCtrl,
                        style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: Color(0x990B0101),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    /// PASSWORD
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(0.30),
                        ),
                      ),
                      child: TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          hintText: "Masukkan Password",
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.60),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    /// BUTTON LOGIN
                    _isLoading
                        ? CircularProgressIndicator(color: Color(0xFFA50000))
                        : InkWell(
                            onTap: _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFF0000),
                                    Color(0xFF5D0D0D)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                    SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Color(0xFFFF0000),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
