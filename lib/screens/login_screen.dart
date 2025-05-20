import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // FontAwesome paketini import et
import 'package:healthharmony/models/User/user_login_dto.dart'; // Modelinizin yolu doğru olmalı
import 'package:healthharmony/screens/forgot_password_screen.dart';
import 'package:healthharmony/screens/home_screen.dart';
import 'package:healthharmony/screens/register_screen.dart';    // Ekranınızın yolu doğru olmalı
import 'package:healthharmony/services/Auth/auth_service.dart'; // Servisinizin yolu doğru olmalı
import '../utils/validators.dart'; // Yardımcı dosyanızın yolu doğru olmalı

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- _LOGIN METODU ORİJİNAL HALİNE DÖNDÜRÜLDÜ ---
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
      final loginDto = UserLoginDto(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final result = await _authService.login(loginDto);

      if (result != null) {
        // Giriş başarılı, ana sayfaya yönlendir VE TÜM ÖNCEKİ SAYFALARI YIĞINDAN KALDIR
        if (mounted) { // mounted kontrolü eklendi
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), // HomeScreen widget'ınızı buraya koyun
            (Route<dynamic> route) => false, // Bu koşul tüm önceki yolları kaldırır
          );
        }
      } else {
        // Giriş başarısız
        if (mounted) { // mounted kontrolü eklendi
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giriş başarısız.')),
          );
        }
      }
    } catch (e) {
      if (mounted) { // mounted kontrolü eklendi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) { // mounted kontrolü eklendi
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
  // --- ORİJİNAL _LOGIN METODU SONU ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/Logo.png', height: 300)), // Logonuzun yolu ve pubspec tanımı doğru olmalı
              const SizedBox(height: 0), // Logonun hemen altında boşluk olmaması için 0
                                         // veya küçük bir değer (örn: 20) ayarlayabilirsiniz.

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-Posta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
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
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Şifremi Unuttum',
                    style: TextStyle(color: Colors.grey[700], decoration: TextDecoration.underline),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Hesabın yok mu? Kayıt Ol',
                     style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Farklı Giriş Yöntemleri',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialLoginButton(
                    icon: FaIcon(FontAwesomeIcons.apple, color: Colors.black, size: 30),
                    onPressed: () { /* Apple ile giriş */ }
                  ),
                  _socialLoginButton(
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.red.shade600, size: 28),
                    onPressed: () { /* Google ile giriş */ }
                  ),
                  _socialLoginButton(
                    icon: FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: 28),
                    onPressed: () { /* X (Twitter) ile giriş */ }
                  ),
                  _socialLoginButton(
                    icon: FaIcon(FontAwesomeIcons.facebookF, color: Colors.blue.shade800, size: 28),
                    onPressed: () { /* Facebook ile giriş */ }
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({required Widget icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: IconButton(
        icon: icon,
        onPressed: _isLoading ? null : onPressed,
        splashRadius: 28,
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}