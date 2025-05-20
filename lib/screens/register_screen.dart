import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Sosyal medya ikonları için (eğer gerekirse, şu an bu ekranda kullanılmıyor ama tutarlılık için)
import 'package:healthharmony/models/User/user_create_dto.dart';
import 'package:healthharmony/services/Auth/auth_service.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Şifre eşleşme kontrolü zaten TextFormField'ın validator'ünde var,
      // ama burada ek bir kontrol olarak kalabilir veya kaldırılabilir.
      if (_passwordController.text != _confirmPasswordController.text) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şifreler eşleşmiyor.')),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        final registerDto = UserCreateDto(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          passwordHash: _passwordController.text, // Backend'iniz şifreyi hashlemiyorsa düz metin,
                                                // idealde backend hashlemeli ve burası password alanı olmalı.
          registrationDate: DateTime.now().toIso8601String(),
        );

        final result = await _authService.register(registerDto);

        if (mounted) {
          if (result) { // AuthService.register metodunuzun bool döndürdüğünü varsayıyoruz.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kayıt başarılı. Giriş yapabilirsiniz.')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kayıt başarısız. Kullanıcı adı veya e-posta zaten mevcut olabilir.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildRegisterIcon() {
    // LoginScreen'daki logoya benzer bir stil
    return Container(
      width: 120, // Boyut LoginScreen ile benzer
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.shade600, width: 3), // İsteğe bağlı çerçeve
        color: Colors.blue.shade100.withOpacity(0.5), // Hafif bir arka plan rengi
      ),
      child: Icon(
        Icons.person_add_alt_1_outlined, // Daha modern bir kayıt ikonu
        color: Colors.blue.shade700,
        size: 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar kaldırıldı, LoginScreen'a benzetmek için.
      // Gerekirse eklenebilir: AppBar(title: const Text('Kayıt Ol'), elevation: 0, backgroundColor: Colors.transparent)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20), // Üst boşluk
              Center(child: _buildRegisterIcon()), // Yenilenmiş ikon/logo alanı
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: Validators.validateUsername,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-Posta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Şifre Tekrar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi tekrar girin.';
                        }
                        if (value != _passwordController.text) {
                          return 'Şifreler eşleşmiyor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30), // Buton öncesi daha fazla boşluk
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850], // LoginScreen ile aynı stil
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: 17, // Biraz daha büyük
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Zaten hesabınız var mı?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: Colors.blue.shade700, // LoginScreen'daki link stiline benzer
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Alt boşluk
            ],
          ),
        ),
      ),
    );
  }
}