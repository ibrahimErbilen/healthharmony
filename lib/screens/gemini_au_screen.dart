import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Şık ikonlar için
import 'package:healthharmony/models/Gemini/message.dart'; // Modelinizin doğru yolu
import 'package:healthharmony/services/Gemini/gemini_service.dart'; // Servisinizin doğru yolu
// import 'package:intl/intl.dart'; // Zaman damgası formatlama için (opsiyonel)

class GeminiAuScreen extends StatefulWidget {
  const GeminiAuScreen({super.key});

  @override
  State<GeminiAuScreen> createState() => _GeminiAuScreenState();
}

class _GeminiAuScreenState extends State<GeminiAuScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final ScrollController _scrollController = ScrollController();

  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    final userMessage = Message(text: userText, isUser: true, 
   // timestamp: DateTime.now()
    );
    if (!mounted) return;
    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _geminiService.askGemini(userText);
      final geminiMessage = Message(text: response, isUser: false, 
      //timestamp: DateTime.now()
      );
      if (!mounted) return;
      setState(() {
        _messages.add(geminiMessage);
      });
    } catch (e) {
      final errorMessage = Message(text: 'Hata: ${e.toString()}', isUser: false,
      // timestamp: DateTime.now()
       );
      if (!mounted) return;
      setState(() {
        _messages.add(errorMessage);
      });
      _showErrorSnackbar('Mesaj gönderilirken bir hata oluştu.');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _buildMessageBubble(Message message) {
    // final timeFormatter = DateFormat('HH:mm'); // Opsiyonel

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18.0),
            topRight: const Radius.circular(18.0),
            bottomLeft: message.isUser ? const Radius.circular(18.0) : const Radius.circular(4.0),
            bottomRight: message.isUser ? const Radius.circular(4.0) : const Radius.circular(18.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5.0,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            // Opsiyonel: Zaman Damgası
            // if (message.timestamp != null) ...[
            //   const SizedBox(height: 4),
            //   Text(
            //     timeFormatter.format(message.timestamp!),
            //     style: TextStyle(
            //       color: message.isUser ? Colors.white70 : Colors.black54,
            //       fontSize: 11,
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(FontAwesomeIcons.robot, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 10),
            const Text(
              "AI Asistan",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.comments, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 20),
                            Text(
                              "AI Asistan ile sohbete başlayın!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Aklınızdaki soruları sorun veya bir konuda yardım isteyin.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      radius: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.blue.shade600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text("AI düşünüyor...", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.only( // Dikey padding azaltıldı
                left: 12.0,
                right: 12.0,
                top: 8.0,
                bottom: 50.0, // <<<--- ALT PADDING AZALTILDI (veya 0.0 yapabilirsiniz)
              ),
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
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Bir mesaj yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      ),
                      onSubmitted: _isLoading ? null : (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _isLoading ? null : _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey.shade400 : Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isLoading ? FontAwesomeIcons.hourglassHalf : FontAwesomeIcons.paperPlane,
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