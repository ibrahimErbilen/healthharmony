import 'package:flutter/material.dart';
import 'package:healthharmony/services/Auth/auth_service.dart'; // Servisinizin yolu doğru olmalı
import '../utils/validators.dart'; // Yardımcı dosyanızın yolu doğru olmalı

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService(); // Gerçek implementasyonda bu kullanılacak

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // --- GERÇEK API ÇAĞRISI (YORUM SATIRINDA) ---
        // final success = await _authService.sendPasswordResetEmail(_emailController.text.trim());
        // if (success) { ... } else { ... }

        // --- SİMÜLASYON ---
        await Future.delayed(const Duration(seconds: 2)); // Ağ gecikmesini simüle et
        // Rastgele bir başarı/başarısızlık durumu simüle edelim
        // bool simulatedSuccess = Random().nextBool();
        bool simulatedSuccess = true; // Şimdilik hep başarılı olsun

        if (mounted) {
          if (simulatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi (eğer e-posta kayıtlıysa).')),
            );
            // İsteğe bağlı: Kullanıcıyı giriş ekranına yönlendir
            // Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('E-posta gönderilemedi. Lütfen tekrar deneyin.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Şifremi Unuttum',
          style: TextStyle(
            color: Colors.grey[850], // Login sayfasındaki başlık rengiyle uyumlu
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Arka planı şeffaf yapar
        elevation: 0, // Gölgeyi kaldırır
        iconTheme: IconThemeData(
          color: Colors.grey[800], // Geri butonu rengi
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Dikey padding azaltıldı
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/Logo.png', height: 250)), // Logo biraz daha küçük olabilir
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Şifrenizi sıfırlamak için kayıtlı e-posta adresinizi girin. Size bir sıfırlama bağlantısı göndereceğiz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-Posta',
                        hintText: 'ornek@eposta.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendResetLink,
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
                                'Sıfırlama Bağlantısı Gönder',
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
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.pop(context); // Giriş ekranına geri dön
                  },
                  child: Text(
                    'Giriş Ekranına Dön',
                     style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Alt boşluk
            ],
          ),
        ),
      ),
    );
  }
}