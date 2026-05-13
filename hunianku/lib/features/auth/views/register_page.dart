import 'package:flutter/material.dart';
import 'package:hunianku/features/auth/controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _controller = AuthController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRole; 

  final Color backgroundColor = const Color(0xFFEFEBE1);
  final Color cardColor = const Color(0xFFFBFBF9);
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color activeRoleColor = const Color(0xFF6B1212);
  final Color inputBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60), 
                      
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
                            const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Masukkan nama pengguna dan kata sandi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email',
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _namaController,
                              hintText: 'Nama Lengkap',
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildRoleButton(
                                    title: 'Pemilik Kost',
                                    roleValue: 'pemilik',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildRoleButton(
                                    title: 'Penghuni Kost',
                                    roleValue: 'penghuni',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

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
                                      // PERUBAHAN ADA DI BAGIAN INI
                                      onPressed: () async {
                                        if (_selectedRole == null) {
                                          _controller.showMessage(
                                            context, 
                                            'Silakan pilih Pemilik Kost atau Penghuni Kost terlebih dahulu!', 
                                            isError: true
                                          );
                                          return; 
                                        }

                                        // Tunggu proses register selesai, Controller akan urus navigasinya
                                        await _controller.register(
                                          context,
                                          _namaController.text.trim(),
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                          _selectedRole!, 
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
                                        'Daftar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                              },
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'atau',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: () {
                                _controller.loginWithGoogle(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                minimumSize: const Size(double.infinity, 50),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      'assets/google_logo.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Daftar dengan Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRoleButton({required String title, required String roleValue}) {
    bool isActive = _selectedRole == roleValue;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleValue;
        });
      },
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeRoleColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive 
              ? [] 
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : activeRoleColor,
          ),
        ),
      ),
    );
  }
}