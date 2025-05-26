import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class EmergencySocketService {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws:192.168.1.34:8000/ws/emergencias/'),
  );

  Stream<dynamic> get emergencyStream => _channel.stream.map((data) {
    return jsonDecode(data);
  });

  void dispose() {
    _channel.sink.close();
  }
}