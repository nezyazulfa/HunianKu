import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _controller = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Warna yang disesuaikan dari desain
  final Color backgroundColor = const Color(0xFFEFEBE1); // Warna background krem
  final Color cardColor = const Color(0xFFFBFBF9); // Warna card putih tulang
  final Color primaryGreen = const Color(0xFF4A6525); // Warna tombol hijau olive
  final Color inputBackgroundColor = Colors.white; // Warna kotak input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Judul
                        const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Sub-judul
                        const Text(
                          'Masukkan nama pengguna dan kata sandi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Input Nama Pengguna / Email
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Nama Pengguna',
                        ),
                        const SizedBox(height: 16),

                        // Input Kata Sandi
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Kata Sandi',
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),

                        // Tombol Masuk dengan Loading Indicator
                        ValueListenableBuilder<bool>(
                          valueListenable: _controller.isLoading,
                          builder: (context, isLoading, child) {
                            return isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: primaryGreen,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      _controller.login(
                                        context,
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 50),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Divider 'atau'
                        const Text(
                          'atau',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tombol Masuk dengan Google
                        ElevatedButton(
                          onPressed: () {
                            _controller.loginWithGoogle(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // --- INI BAGIAN LOGO GOOGLE ASLI ---
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white, // Lingkaran putih kecil di belakang logo
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/google_logo.png', // Panggil gambar yang sudah kita siapkan
                                  height: 20, // Atur ukurannya agar pas
                                  width: 20,
                                ),
                              ),
                              // -----------------------------------
                              const SizedBox(width: 12),
                              const Text(
                                'Masuk dengan Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold, // Ini agar text-nya tebal
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Link ke Halaman Daftar (Dipindah ke luar card agar lebih rapi)
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text(
                      'Belum punya akun? Daftar di sini',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget custom untuk TextField agar desainnya seragam dan rapi
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none, // Menghilangkan garis default
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}