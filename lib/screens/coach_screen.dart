import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Coach/Coach.dart'; // Coach modelinizin yolu
import 'package:healthharmony/utils/constants.dart'; // ApiConstants için
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:healthharmony/widget/coach_card.dart';// CoachCard widget'ınızın yolu
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:healthharmony/screens/chat_screen.dart'; // ChatScreen'a yönlendirme için

class CoachSearchPage extends StatefulWidget {
  const CoachSearchPage({super.key});

  @override
  _CoachSearchPageState createState() => _CoachSearchPageState();
}

class _CoachSearchPageState extends State<CoachSearchPage> {
  List<Coach> _coaches = [];
  bool _showCodeInput = false;
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isSearchingCoach = false;
  bool _isPageLoading = true;
  String? _searchErrorMessage;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SecureStorage _secureStorage = SecureStorage(); 

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isPageLoading = true);
    await _loadCoachesFromStorage();
    if (!mounted) return;
    setState(() => _isPageLoading = false);
  }

  Future<void> _loadCoachesFromStorage() async {
    final String? storedCoachesJson = await _storage.read(key: 'saved_coaches_v1');
    if (storedCoachesJson != null) {
      try {
        List<dynamic> jsonList = json.decode(storedCoachesJson);
        List<Coach> loadedCoaches = jsonList.map((jsonItem) => Coach.fromJson(jsonItem)).toList();
        if (!mounted) return;
        setState(() => _coaches = loadedCoaches);
      } catch (e) {
        print("Kaydedilmiş koçlar yüklenirken hata: $e");
        await _storage.delete(key: 'saved_coaches_v1');
      }
    }
  }

  Future<void> _saveCoachesToStorage() async {
    try {
      List<Map<String, dynamic>> jsonList = _coaches.map((c) => c.toJson()).toList();
      await _storage.write(key: 'saved_coaches_v1', value: json.encode(jsonList));
    } catch (e) {
      print("Koçlar kaydedilirken hata: $e");
    }
  }

  Future<void> _searchCoachByCode(String code) async {
    if (!mounted) return;
    setState(() {
      _isSearchingCoach = true;
      _searchErrorMessage = null;
    });
    _codeFocusNode.unfocus();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/Coach/get-by-invitation-code/$code');
      final authToken = await _secureStorage.getAccessToken(); // Token'ı al
      final response = await http.get(
        url,
        headers: { // Headers eklendi
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );


      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isEmpty || (data.containsKey('coachId') && data['coachId'] == null) ) { // Daha kapsamlı boş kontrolü
          setState(() => _searchErrorMessage = 'Bu kod ile eşleşen bir koç bulunamadı.');
        } else {
          final coach = Coach.fromJson(data);
          setState(() {
            if (!_coaches.any((c) => c.coachId == coach.coachId)) {
              _coaches.add(coach);
              _saveCoachesToStorage();
              _showSnackbar("'${coach.coachName}' listenize eklendi.", success: true);
            } else {
              _showSnackbar("'${coach.coachName}' zaten listenizde.", success: false, isInfo: true);
            }
            _showCodeInput = false;
            _codeController.clear();
          });
        }
      } else if (response.statusCode == 404) {
        setState(() => _searchErrorMessage = 'Bu kod ile eşleşen bir koç bulunamadı.');
      } else {
         try { // Hata mesajını JSON'dan okumaya çalış
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Koç aranırken bir hata oluştu (Kod: ${response.statusCode}).';
          setState(() => _searchErrorMessage = message);
        } catch (_) { // JSON parse edilemezse genel hata
          setState(() => _searchErrorMessage = 'Koç aranırken bir hata oluştu (Kod: ${response.statusCode}).');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _searchErrorMessage = 'Bir ağ hatası oluştu: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isSearchingCoach = false);
    }
  }

  Future<void> _removeCoach(int index) async {
    if (!mounted) return;
    final coachToRemove = _coaches[index];
    // Onay dialogu
    final bool? confirmRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Koçu Kaldır'),
          content: Text("'${coachToRemove.coachName}' adlı koçu listenizden kaldırmak istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Kaldır'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmRemove == true) {
      setState(() {
        _coaches.removeAt(index);
      });
      await _saveCoachesToStorage();
      _showSnackbar("'${coachToRemove.coachName}' listenizden kaldırıldı.", success: true);
    }
  }

  void _showSnackbar(String message, {bool success = true, bool isInfo = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isInfo ? Colors.blueGrey.shade600 : (success ? Colors.green.shade600 : Colors.red.shade700),
      ),
    );
  }

  Widget _buildCodeInputSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Koç Ekle", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade800)), // Mavi başlık
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              focusNode: _codeFocusNode,
              decoration: InputDecoration(
                hintText: 'Koçun davet kodunu girin',
                prefixIcon: Icon(FontAwesomeIcons.barcode, size: 20, color: Colors.blue.shade700), // Mavi ikon
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _handleSearchAction(),
            ),
            const SizedBox(height: 12),
            if (_searchErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_searchErrorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),
            ElevatedButton.icon(
              icon: _isSearchingCoach
                  ? Container(width: 20, height: 20, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Icon(Icons.search_rounded, color: Colors.white), // Buton ikonu için renk
              label: Text(_isSearchingCoach ? 'Aranıyor...' : 'Koçu Bul ve Ekle'),
              onPressed: _isSearchingCoach ? null : _handleSearchAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700, // Mavi buton
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchAction() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      _searchCoachByCode(code);
    } else {
      if (!mounted) return;
      setState(() => _searchErrorMessage = 'Lütfen bir davet kodu girin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı al
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koçlarım', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isPageLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor)) // Mavi yükleme
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(_showCodeInput ? FontAwesomeIcons.circleXmark : FontAwesomeIcons.userPlus, size: 18, color: Colors.white),
                      label: Text(_showCodeInput ? 'Ekleme İptal' : 'Yeni Koç Ekle'),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _showCodeInput = !_showCodeInput;
                          _searchErrorMessage = null;
                          if (!_showCodeInput) _codeController.clear();
                        });
                        if (_showCodeInput) {
                           WidgetsBinding.instance.addPostFrameCallback((_) => _codeFocusNode.requestFocus());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showCodeInput ? Colors.grey.shade600 : Colors.blue.shade600, // Koşullu mavi
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(sizeFactor: animation, child: child);
                      },
                      child: _showCodeInput ? _buildCodeInputSection() : const SizedBox.shrink(),
                    ),
                    if (_coaches.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                        child: Text(
                          "Kayıtlı Koçlar",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade800), // Mavi başlık
                        ),
                      ),
                    Expanded(
                      child: (_coaches.isEmpty && !_isSearchingCoach)
                          ? Center(
                              child: Opacity(
                                opacity: _showCodeInput ? 0.3 : 1.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.usersSlash, size: 50, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Henüz kayıtlı koçunuz bulunmuyor.",
                                      style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Yukarıdaki butonu kullanarak davet kodu ile koç ekleyebilirsiniz.", // Metin güncellendi
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _isSearchingCoach
                              ? Center(child: CircularProgressIndicator(color: theme.primaryColor)) // Mavi yükleme
                              : ListView.builder(
                                  itemCount: _coaches.length,
                                  itemBuilder: (context, index) {
                                    final coach = _coaches[index];
                                    return CoachCard( // CoachCard'ın içindeki renkleri de mavi temaya göre ayarladığınızdan emin olun
                                      coach: coach,
                                      onMessageTap: () {
                                        _showSnackbar('Mesaj gönderiliyor: ${coach.coachName} (TODO)', isInfo: true);
                                        // TODO: ChatScreen'a yönlendirme
                                      },
                                      onDismissed: () => _removeCoach(index),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}