import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class EmergencySocketService {
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://backend-django-l51z.onrender.com/ws/emergencias/'),
  );

  Stream<dynamic> get emergencyStream => _channel.stream.map((data) {
    return jsonDecode(data);
  });

  void dispose() {
    _channel.sink.close();
  }
}