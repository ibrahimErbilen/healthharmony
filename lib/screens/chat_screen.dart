import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Şık ikonlar için
import 'package:healthharmony/models/Message/MessageCreateDTO%20.dart'; // Modelinizin doğru yolu
import 'package:healthharmony/services/Message/message_service.dart'; // Servisinizin doğru yolu
// import 'package:intl/intl.dart'; // Zaman damgası formatlama için (opsiyonel)

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String? otherUserName; // Opsiyonel: AppBar'da göstermek için

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    this.otherUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Otomatik kaydırma
  List<MessageCreateDTO> _messages = [];
  bool _isLoadingMessages = true; // Mesajları ilk yükleme durumu
  bool _isSendingMessage = false; // Mesaj gönderme durumu

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _loadMessages({bool scrollToBottomAfterLoad = true}) async {
    if (!mounted) return;
    if (scrollToBottomAfterLoad) { // Sadece ilk yüklemede true olacak
      setState(() => _isLoadingMessages = true);
    }

    try {
      final messages = await _messageService.getMessages(widget.currentUserId, widget.otherUserId);
      if (!mounted) return;
      setState(() {
        // Gelen mesajları tarihe göre sıralayabiliriz (en eski önce)
        messages.sort((a, b) => a.sentTime.compareTo(b.sentTime));
        _messages = messages;
      });
      if (scrollToBottomAfterLoad) {
        _scrollToBottom(animate: false); // İlk yüklemede animasyonsuz kaydır
      }
    } catch (e) {
      _showErrorSnackbar('Mesajlar yüklenirken bir hata oluştu.');
    } finally {
      if (!mounted) return;
      if (scrollToBottomAfterLoad) {
         setState(() => _isLoadingMessages = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSendingMessage) return;

    if (!mounted) return;
    setState(() => _isSendingMessage = true);

    // Mesajı anında UI'a ekle (iyimser güncelleme)
    final optimisticMessage = MessageCreateDTO(
      messageId: DateTime.now().millisecondsSinceEpoch, // Geçici benzersiz ID (UI için)
      senderUserId: widget.currentUserId,
      receiverUserId: widget.otherUserId,
      messageContent: content,
      sentTime: DateTime.now(),
      isRead: false, // Backend bunu güncelleyebilir
    );
    setState(() {
      _messages.add(optimisticMessage);
      _controller.clear();
    });
    _scrollToBottom();

    try {
      await _messageService.sendMessage(optimisticMessage); // Backend'e gönder
      // Başarılı olursa UI zaten güncel. İsterseniz _loadMessages ile yeniden çekebilirsiniz
      // ama genellikle iyimser güncelleme yeterlidir.
      // Hata durumunda iyimser mesajı UI'dan kaldırabilir veya bir hata işareti ekleyebilirsiniz.
    } catch (e) {
      _showErrorSnackbar('Mesaj gönderilemedi.');
      // İyimser güncellemeyi geri al (opsiyonel)
      if (mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg.messageId == optimisticMessage.messageId && msg.messageContent == optimisticMessage.messageContent);
        });
      }
    } finally {
      if (!mounted) return;
      setState(() => _isSendingMessage = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _buildMessageBubble(MessageCreateDTO message) {
    final bool isCurrentUser = message.senderUserId == widget.currentUserId;
    // final timeFormatter = DateFormat('HH:mm'); // Opsiyonel

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).primaryColor // Mevcut kullanıcı mesajı rengi
              : Colors.grey.shade300, // Diğer kullanıcı mesajı rengi
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18.0),
            topRight: const Radius.circular(18.0),
            bottomLeft: isCurrentUser ? const Radius.circular(18.0) : const Radius.circular(4.0),
            bottomRight: isCurrentUser ? const Radius.circular(4.0) : const Radius.circular(18.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 4.0,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.messageContent,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            // Opsiyonel: Zaman Damgası
            // const SizedBox(height: 3),
            // Text(
            //   timeFormatter.format(message.sentTime.toLocal()),
            //   style: TextStyle(
            //     color: isCurrentUser ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5),
            //     fontSize: 11,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherUserName ?? "Sohbet", // Diğer kullanıcının adı veya varsayılan
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        // Opsiyonel: Kullanıcı avatarı ve online durumu eklenebilir
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: CircleAvatar(child: Text(widget.otherUserName?[0] ?? "?")),
        // ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: _isLoadingMessages
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.comments, size: 50, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  "Henüz mesaj yok.",
                                  style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
                                ),
                                Text(
                                  "İlk mesajı göndererek sohbete başlayın!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          // reverse: true, // Mesajları tersten ekleyip _scrollToBottom kullanıyoruz
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            // reverse:true kullanılıyorsa: final msg = _messages[index];
                            // reverse:false ve _scrollToBottom kullanılıyorsa:
                            final msg = _messages[index];
                            return _buildMessageBubble(msg);
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 45.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      ),
                      onSubmitted: _isSendingMessage ? null : (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _isSendingMessage ? null : _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isSendingMessage ? Colors.grey.shade400 : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: _isSendingMessage
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(
                                FontAwesomeIcons.paperPlane,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}