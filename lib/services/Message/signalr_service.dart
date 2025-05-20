import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  late HubConnection _hubConnection;

  // SignalR Hub URL
  final String _hubUrl = "https://localhost:7040/hubs/message"; // HTTPS değilse: http://10.0.2.2:7040

  Future<void> initConnection() async {
    final httpOptions = HttpConnectionOptions(
      transport: HttpTransportType.WebSockets,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(_hubUrl, options: httpOptions)
        .build();

    _hubConnection.onclose(({error}) => print("Bağlantı kapandı: $error"));

    _hubConnection.on("ReceiveMessage", _onReceiveMessage);

    try {
      await _hubConnection.start();
      print("SignalR bağlantısı başlatıldı");
    } catch (e) {
      print("Bağlantı hatası: $e");
    }
  }

  void _onReceiveMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final message = arguments[0];
      print("Mesaj alındı: $message");
    }
  }

  Future<void> sendMessage(String receiverId, String messageContent) async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      await _hubConnection.invoke("SendMessage", args: [receiverId, messageContent]);
    } else {
      print("Bağlantı yok. Mesaj gönderilemedi.");
    }
  }

  Future<void> disconnect() async {
    await _hubConnection.stop();
    print("SignalR bağlantısı kapatıldı.");
  }
}
