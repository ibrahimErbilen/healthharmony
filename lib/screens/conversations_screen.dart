import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/widget/conversation_tile.dart'; // Yeni widget'ı import edin
import 'chat_screen.dart'; // ChatScreen'ı import edin

class ConversationsScreen extends StatefulWidget {
  final String currentUserId;

  const ConversationsScreen({super.key, required this.currentUserId});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addFriendController = TextEditingController(); // Dialog için ayrı controller
  final FocusNode _searchFocusNode = FocusNode();

  // Örnek veri, bunu API'den dinamik almalısınız.
  // Gerçek uygulamada bu bir List<ConversationModel> gibi bir model listesi olmalı.
  List<Map<String, dynamic>> _allConversations = [
    {"userId": "friend1", "username": "Elif Yılmaz", "lastMessage": "Harika! Yarın görüşürüz o zaman.", "avatarUrl": null, "timestamp": "10:30", "hasUnread": true},
    {"userId": "friend2", "username": "Ahmet Kaya", "lastMessage": "Tamamdır, sana döneceğim.", "avatarUrl": null, "timestamp": "Dün", "hasUnread": false},
    {"userId": "friend3", "username": "Zeynep Demir", "lastMessage": "Proje hakkında konuşalım mı?", "avatarUrl": null, "timestamp": "Paz", "hasUnread": false},
    {"userId": "friend4", "username": "Mehmet Çelik", "lastMessage": "Yarın Sırt Çalışırım", "avatarUrl": null, "timestamp": "2g önce", "hasUnread": true},
  ];

  List<Map<String, dynamic>> _filteredConversations = [];

  @override
  void initState() {
    super.initState();
    _filteredConversations = _allConversations;
    _searchController.addListener(_filterConversations);
    // TODO: API'den gerçek konuşmaları yükle (_loadConversations)
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterConversations);
    _searchController.dispose();
    _addFriendController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _allConversations;
      } else {
        _filteredConversations = _allConversations.where((convo) {
          final username = convo['username']?.toString().toLowerCase() ?? '';
          final lastMessage = convo['lastMessage']?.toString().toLowerCase() ?? '';
          return username.contains(query) || lastMessage.contains(query);
        }).toList();
      }
    });
  }

  // TODO: Gerçek API çağrısı ile arkadaş ekleme
  Future<void> _addFriendByUsername(String username) async {
    if (!mounted) return;
    // Simülasyon
    print("Arkadaş Ekleme İsteği: $username");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("'$username' için arkadaşlık isteği gönderildi (simülasyon).")),
    );
    // Gerçek API çağrısı:
    // try {
    //   bool success = await FriendService().addFriendByUsername(username);
    //   if (success) {
    //     _showSuccessSnackbar("Arkadaşlık isteği gönderildi.");
    //     // Konuşma listesini yenile
    //   } else {
    //     _showErrorSnackbar("Kullanıcı bulunamadı veya bir hata oluştu.");
    //   }
    // } catch (e) {
    //   _showErrorSnackbar("Hata: ${e.toString()}");
    // }
  }

  void _showAddFriendDialog() {
    _addFriendController.clear(); // Dialog açıldığında önceki metni temizle
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // dialogContext kullanımı önemli
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Row(
            children: [
              Icon(FontAwesomeIcons.userPlus, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text("Yeni Arkadaş Ekle"),
            ],
          ),
          content: TextField(
            controller: _addFriendController,
            decoration: InputDecoration(
              hintText: "Kullanıcı adı girin",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              prefixIcon: const Icon(Icons.person_search_outlined),
            ),
            autofocus: true,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: const Text("İstek Gönder"),
              onPressed: () {
                final username = _addFriendController.text.trim();
                if (username.isNotEmpty) {
                  _addFriendByUsername(username);
                }
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mesajlar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade50, // Hafif bir arka plan
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.userPlus, color: Colors.blue.shade700, size: 22),
            tooltip: "Yeni Arkadaş Ekle",
            onPressed: _showAddFriendDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Yüksekliği biraz artırdık
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0), // Daha iyi boşluklar
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Konuşmalarda ara...',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white, // Veya Colors.grey.shade200
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // Kenarlığı kaldırıp gölge ile vurgu
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                // Gölge ekleyebiliriz
                // focusedBorder: OutlineInputBorder(...) // Odaklandığında farklı stil
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector( // Klavyeyi kapatmak için
        onTap: () => _searchFocusNode.unfocus(),
        child: _filteredConversations.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isEmpty
                            ? FontAwesomeIcons.comments // Henüz konuşma yoksa
                            : FontAwesomeIcons.magnifyingGlass, // Arama sonucu yoksa
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? "Henüz bir konuşmanız yok."
                            : "'${_searchController.text}' ile eşleşen konuşma bulunamadı.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
                      ),
                      if (_searchController.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Sağ üstteki '+' ikonuna dokunarak arkadaş ekleyebilirsiniz.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(top: 8.0),
                itemCount: _filteredConversations.length,
                itemBuilder: (context, index) {
                  final conversation = _filteredConversations[index];
                  return ConversationTile(
                    username: conversation['username'] ?? 'Bilinmeyen Kullanıcı',
                    lastMessage: conversation['lastMessage'] ?? '',
                    avatarUrl: conversation['avatarUrl'], // API'den gelirse
                    timestamp: conversation['timestamp'], // API'den gelirse
                    hasUnreadMessages: conversation['hasUnread'] ?? false, // API'den gelirse
                    onTap: () {
                      _searchFocusNode.unfocus(); // Chat ekranına gitmeden klavyeyi kapat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUserId: widget.currentUserId,
                            otherUserId: conversation['userId']!,
                            // otherUserName: conversation['username'], // ChatScreen'a isim de gönderebilirsiniz
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 80, // Avatar genişliği + padding kadar
                  endIndent: 16,
                  color: Colors.grey.shade200,
                ),
              ),
      ),
    );
  }
}