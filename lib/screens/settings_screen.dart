import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:healthharmony/utils/secure_storage.dart';
// import 'package:healthharmony/utils/navigation_service.dart'; // Kullanılıyorsa
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SecureStorage _secureStorage = SecureStorage();

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'Türkçe';
  String _measurementUnit = 'Metrik (km, kg)';

  String? _userId;
  String? _userEmail;
  String? _userName;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = await _secureStorage.getUserId();
      final baseUrl = ApiConstants.baseUrl;
      final authToken = await _secureStorage.getAccessToken();

      if (userId == null) {
        throw Exception('Kullanıcı kimliği bulunamadı. Lütfen tekrar giriş yapın.');
      }

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
          _userId = userId;
          _userEmail = userData['email'] ?? 'E-posta bilgisi yok';
          _userName = userData['username'] ?? 'Kullanıcı adı yok';
        });
      } else {
        _showErrorSnackbar('Kullanıcı bilgileri alınamadı (Kod: ${response.statusCode}).');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Veriler yüklenirken bir sorun oluştu: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Çıkış Yap'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await _secureStorage.deleteAccessToken();
        await _secureStorage.deleteRefreshToken();
        await _secureStorage.deleteUserId();
        if (mounted) {
           Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackbar('Çıkış yapılırken bir hata oluştu: ${e.toString()}');
      }
    }
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

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blue.shade700, size: 22), // <<<--- İKON RENGİ MAVİ
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800, // <<<--- BAŞLIK RENGİ MAVİ TONU
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600, size: 26), // <<<--- İKON RENGİ MAVİ
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade500) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                _buildSectionHeader('Kullanıcı Profili', icon: FontAwesomeIcons.solidUserCircle),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withOpacity(0.1), // <<<--- AVATAR ARKA PLANI MAVİ TONU
                    child: Text(
                      _userName?.isNotEmpty == true ? _userName![0].toUpperCase() : "K",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade700), // <<<--- AVATAR YAZI RENGİ MAVİ
                    ),
                  ),
                  title: Text(_userName ?? 'Kullanıcı Adı', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(_userEmail ?? 'E-posta', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  trailing: Icon(Icons.edit_outlined, color: Colors.grey.shade600),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const Divider(height: 20, indent: 16, endIndent: 16),

                _buildSectionHeader('Uygulama Tercihleri', icon: FontAwesomeIcons.sliders),
                SwitchListTile.adaptive(
                  title: const Text('Karanlık Mod', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  subtitle: Text('Uygulama temasını değiştir', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    _showSuccessSnackbar("Karanlık mod ${_isDarkMode ? 'aktif' : 'devre dışı'}.");
                  },
                  secondary: Icon(FontAwesomeIcons.moon, color: Colors.blue.shade600), // <<<--- İKON RENGİ MAVİ
                  activeColor: Colors.blue.shade700, // <<<--- SWITCH AKTİF RENK MAVİ
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                ),
                SwitchListTile.adaptive(
                  title: const Text('Bildirimler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  subtitle: Text('Uygulama bildirimlerini al', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                     _showSuccessSnackbar("Bildirimler ${_notificationsEnabled ? 'aktif' : 'devre dışı'}.");
                  },
                  secondary: Icon(FontAwesomeIcons.solidBell, color: Colors.blue.shade600), // <<<--- İKON RENGİ MAVİ
                  activeColor: Colors.blue.shade700, // <<<--- SWITCH AKTİF RENK MAVİ
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                ),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.language,
                  title: 'Dil',
                  subtitle: _language,
                  onTap: _showLanguageDialog,
                ),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.rulerCombined,
                  title: 'Ölçü Birimi',
                  subtitle: _measurementUnit,
                  onTap: _showUnitDialog,
                ),
                const Divider(height: 20, indent: 16, endIndent: 16),

                _buildSectionHeader('Güvenlik', icon: FontAwesomeIcons.shieldHalved),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.key,
                  title: 'Şifre Değiştir',
                  onTap: () => Navigator.pushNamed(context, '/change-password'),
                ),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.userSecret,
                  title: 'Gizlilik Ayarları',
                  onTap: () => Navigator.pushNamed(context, '/privacy-settings'),
                ),
                const Divider(height: 20, indent: 16, endIndent: 16),

                _buildSectionHeader('Destek ve Hakkında', icon: FontAwesomeIcons.circleInfo),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.solidCircleQuestion,
                  title: 'Yardım ve Destek',
                  onTap: () => Navigator.pushNamed(context, '/help'),
                ),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.bookOpenReader,
                  title: 'Kullanım Şartları',
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                ),
                _buildSettingsTile(
                  icon: FontAwesomeIcons.fileContract,
                  title: 'Gizlilik Politikası',
                  onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                ),
                 _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Hakkında',
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
                const Divider(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.rightFromBracket),
                    label: const Text('Çıkış Yap', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    onPressed: _logout,
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'HealthHarmony v1.0.0',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: Colors.blue.shade700, // <<<--- SEÇİLİ İKON RENGİ MAVİ
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.personRunning), label: 'Aktiviteler'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.wandMagicSparkles), label: 'AI\'a Sor'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.brain), label: 'Koç\'a Sor'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
        onTap: (index) {
          if (index == 4) return;
          String routeName;
          switch (index) {
            case 0: routeName = '/'; break;
            case 1: routeName = '/activities'; break;
            case 2: routeName = '/gemini'; break;
            case 3: routeName = '/coach'; break;
            default: return;
          }
          Navigator.pushReplacementNamed(context, routeName);
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dil Seçimi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('Türkçe'),
              _buildLanguageOption('English'),
              // ... diğer diller ...
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _language == language ? Icon(Icons.check, color: Colors.blue.shade700) : null, // <<<--- CHECK İKONU RENGİ MAVİ
      onTap: () {
        setState(() => _language = language);
        Navigator.pop(context);
        // TODO: Dil değişikliğini kaydet ve uygula
      },
    );
  }

  void _showUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ölçü Birimi Seçimi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitOption('Metrik (km, kg)'),
              _buildUnitOption('İngiliz (mil, lb)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitOption(String unit) {
    return ListTile(
      title: Text(unit),
      trailing: _measurementUnit == unit ? Icon(Icons.check, color: Colors.blue.shade700) : null, // <<<--- CHECK İKONU RENGİ MAVİ
      onTap: () {
        setState(() => _measurementUnit = unit);
        Navigator.pop(context);
        // TODO: Ölçü birimi değişikliğini kaydet ve uygula
      },
    );
  }
}