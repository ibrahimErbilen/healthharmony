import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _gender = 'Erkek';
  File? _profileImageFile;
  String? _profileImageUrlFromApi;

  bool _isLoadingPage = true;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoadingPage = true);
    try {
      final userId = await _secureStorage.getUserId();
      final baseUrl = ApiConstants.baseUrl;
      final authToken = await _secureStorage.getAccessToken();
      if (userId == null) throw Exception('Kullanıcı kimliği bulunamadı.');

      final response = await http.get(
        Uri.parse('$baseUrl/api/User/by-id/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _nameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _heightController.text = userData['height']?.toString() ?? '';
          _weightController.text = userData['weight']?.toString() ?? '';
          _ageController.text = userData['age']?.toString() ?? '';
          _gender = userData['gender'] ?? 'Erkek';
          _profileImageUrlFromApi = userData['profileImagePath'];
        });
      } else {
        _showErrorSnackbar('Kullanıcı bilgileri alınamadı (Kod: ${response.statusCode}).');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Profil bilgileri yüklenirken bir sorun oluştu: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingPage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('Lütfen tüm zorunlu alanları doğru şekilde doldurun.');
      return;
    }
    if (!mounted) return;
    setState(() => _isSavingProfile = true);
    try {
      final userId = await _secureStorage.getUserId();
      final baseUrl = ApiConstants.baseUrl;
      final authToken = await _secureStorage.getAccessToken();
      if (userId == null) throw Exception('Kaydetme işlemi için kullanıcı kimliği bulunamadı.');

      Map<String, dynamic> updateData = {
        'userId': userId,
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'height': int.tryParse(_heightController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim().replaceAll(',', '.')),
        'age': int.tryParse(_ageController.text.trim()),
        'gender': _gender,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/User/update/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updateData),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessSnackbar('Profil bilgileri başarıyla güncellendi.');
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Profil güncellenemedi (Kod: ${response.statusCode}).';
        _showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Profil güncellenirken bir sorun oluştu: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
      if (image != null) {
        if (!mounted) return;
        setState(() {
          _profileImageFile = File(image.path);
          _profileImageUrlFromApi = null;
        });
        _showSuccessSnackbar("Profil resmi seçildi. Kaydetmeyi unutmayın.");
      }
    } catch (e) {
      _showErrorSnackbar("Resim seçilemedi: ${e.toString()}");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.blue), // Mavi ikon
                title: const Text('Galeriden Seç'),
                onTap: () { Navigator.of(context).pop(); _pickImage(ImageSource.gallery); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: Colors.blue), // Mavi ikon
                title: const Text('Kameradan Çek'),
                onTap: () { Navigator.of(context).pop(); _pickImage(ImageSource.camera); },
              ),
              if (_profileImageFile != null || _profileImageUrlFromApi != null)
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700),
                  title: Text('Resmi Kaldır', style: TextStyle(color: Colors.red.shade700)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() { _profileImageFile = null; _profileImageUrlFromApi = null; });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade600),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800, // Mavi renk
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon, color: Colors.blue.shade700.withOpacity(0.8)), // Mavi ikon
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? currentImageProvider;
    if (_profileImageFile != null) {
      currentImageProvider = FileImage(_profileImageFile!);
    } else if (_profileImageUrlFromApi != null && _profileImageUrlFromApi!.isNotEmpty) {
      currentImageProvider = NetworkImage(_profileImageUrlFromApi!);
    } else {
      currentImageProvider = const AssetImage('assets/images/profile_placeholder.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profilimi Düzenle',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.blue.withOpacity(0.15), // Mavi tonu
                              backgroundImage: currentImageProvider,
                              onBackgroundImageError: (exception, stackTrace) {
                                print("Profil resmi yüklenemedi: $exception");
                                setState(() => _profileImageUrlFromApi = null);
                              },
                              child: currentImageProvider is AssetImage && _profileImageFile == null && (_profileImageUrlFromApi == null || _profileImageUrlFromApi!.isEmpty)
                                  ? Icon(FontAwesomeIcons.userAstronaut, size: 60, color: Colors.blue.shade700.withOpacity(0.7)) // Mavi ikon
                                  : null,
                            ),
                            Material(
                              color: Colors.blue.shade600, // Mavi renk
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: _showImagePickerOptions,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Kişisel Bilgiler'),
                      _buildTextFormField(
                        controller: _nameController,
                        labelText: 'Ad Soyad',
                        prefixIcon: FontAwesomeIcons.solidUser,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Lütfen adınızı ve soyadınızı girin.';
                          if (value.trim().length < 3) return 'Ad soyad en az 3 karakter olmalıdır.';
                          return null;
                        },
                      ),
                      _buildTextFormField(
                        controller: _emailController,
                        labelText: 'E-posta Adresi',
                        prefixIcon: FontAwesomeIcons.solidEnvelope,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Lütfen e-posta adresinizi girin.';
                          if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) return 'Geçerli bir e-posta adresi girin.';
                          return null;
                        },
                      ),

                      _buildSectionHeader('Fiziksel Bilgiler'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _heightController,
                              labelText: 'Boy (cm)',
                              prefixIcon: FontAwesomeIcons.rulerVertical,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Boy giriniz';
                                final h = int.tryParse(value);
                                if (h == null || h < 50 || h > 250) return 'Geçerli boy (50-250 cm)';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _weightController,
                              labelText: 'Kilo (kg)',
                              prefixIcon: FontAwesomeIcons.weightScale,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Kilo giriniz';
                                final w = double.tryParse(value.replaceAll(',', '.'));
                                if (w == null || w < 20 || w > 300) return 'Geçerli kilo (20-300 kg)';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, // Dikey hizalamayı başa al
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _ageController,
                              labelText: 'Yaş',
                              prefixIcon: FontAwesomeIcons.cakeCandles,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Yaş giriniz';
                                final age = int.tryParse(value);
                                if (age == null || age < 10 || age > 120) return 'Geçerli yaş (10-120)';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Cinsiyet',
                                  prefixIcon: Icon(FontAwesomeIcons.venusMars, color: Colors.blue.shade700.withOpacity(0.8), size: 20), // Mavi ikon
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0), // Padding ayarlandı
                                ),
                                value: _gender,
                                items: ['Erkek', 'Kadın', 'Belirtmek İstemiyorum'].map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Text(value));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() => _gender = newValue);
                                  }
                                },
                                validator: (value) => value == null ? 'Cinsiyet seçiniz' : null,
                                isExpanded: true, // <<<--- OVERFLOW HATASI İÇİN EKLENDİ
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: _isSavingProfile
                            ? Container(width: 20, height: 20, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Icon(Icons.save_alt_rounded),
                        label: Text(_isSavingProfile ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: _isSavingProfile ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700, // Mavi renk
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}