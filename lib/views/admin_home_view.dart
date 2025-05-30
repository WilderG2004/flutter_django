import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/emergency_service.dart';
import '../models/emergency.dart';
import 'package:flutter/foundation.dart'; 

class AdminHomeView extends StatefulWidget {
  final String token;

  const AdminHomeView({Key? key, required this.token}) : super(key: key);

  @override
  _AdminHomeViewState createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final EmergencyService emergencyService = EmergencyService();
  List<Emergencia> emergencies = [];
  bool isLoading = true;

  late WebSocketChannel channel;
  String? lastEmergencyNotificationIp;

  @override
  void initState() {
    super.initState();
    fetchEmergencies();
    initWebSocket();
  }

 void initWebSocket() {
  channel = WebSocketChannel.connect(
    Uri.parse('wss://backend-django-l51z.onrender.com/ws/emergencias/'),
  );

  channel.stream.listen((message) {
    final data = jsonDecode(message);
    debugPrint('WS recibido: $data'); // Muestra el JSON completo en consola.

    // Maneja 'pong' para latencia RTT.
    if (data['type'] == 'pong' && data['client_send_ts'] != null) {
      final clientSendTs = DateTime.parse(data['client_send_ts']).toUtc();
      final clientReceiveTs = DateTime.now().toUtc();
      final rttMs = clientReceiveTs.difference(clientSendTs).inMilliseconds;
      debugPrint('Latencia WS (RTT): $rttMs ms');
      return;
    }

    // Maneja notificaciones de nueva emergencia e imprime la IP en consola.
    if (data['type'] == 'nueva_emergencia_notificacion') {
      // final Map<String, dynamic> emergenciaData = data['emergencia']; // Puedes usar esto si necesitas los datos de la emergencia en consola
      final String? notifiedIp = data['ip_administrador']; // Extrae la IP.
      
      debugPrint('Nueva emergencia recibida.');
      debugPrint('IP del administrador que recibió la notificación: $notifiedIp'); // IP solo en consola.
      
      fetchEmergencies(); // Refresca la lista de emergencias.
      return;
    }
  }, onError: (error) {
    debugPrint('Error WS: $error');
    // Puedes mantener el SnackBar para errores de conexión críticos si quieres.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexión WebSocket: $error')),
    );
  });

  sendPingForLatency(); // Envía ping inicial.
}

// Envía un ping para medir la latencia RTT.
void sendPingForLatency() {
  if (channel.closeCode == null) {
    channel.sink.add(jsonEncode({
      'type': 'ping',
      'client_send_ts': DateTime.now().toUtc().toIso8601String(),
    }));
    debugPrint('Ping para latencia enviado.');
  } else {
    debugPrint('No se pudo enviar ping: WS cerrado.');
  }
}

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Future<void> fetchEmergencies() async {
    setState(() => isLoading = true);
    try {
      final List<Emergencia> data = await emergencyService.listEmergency(widget.token);
      setState(() {
        emergencies = data.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar emergencias: $e')),
      );
    }
  }

  Future<void> deleteEmergency(int id) async {
    try {
      bool success = await emergencyService.deleteEmergency(id, widget.token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergencia eliminada correctamente')),
        );
        fetchEmergencies();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la emergencia')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Panel de Emergencias',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.supervised_user_circle_outlined),
            tooltip: 'Administrar Estudiantes',
            onPressed: () {
              Navigator.pushNamed(context, '/admin_users', arguments: widget.token);
            },
          ),
        ],
      ),
      body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                )
              : emergencies.isEmpty
                  ? Center(
                      child: Text(
                        'No hay emergencias registradas',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? screenSize.width * 0.05 : 16,
                            vertical: 12,
                          ),
                          itemCount: emergencies.length,
                          itemBuilder: (context, index) {
                            final emergency = emergencies[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.only(
                                bottom: 12,
                                left: isLandscape ? screenSize.width * 0.02 : 0,
                                right: isLandscape ? screenSize.width * 0.02 : 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  radius: isLandscape ? 24 : 28,
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.redAccent,
                                    size: isLandscape ? 20 : 28,
                                  ),
                                ),
                                title: Text(
                                  emergency.tipo ?? 'Emergencia',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLandscape ? 16 : 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '📍 Piso: ${emergency.piso ?? 'Desconocido'}',
                                        style: GoogleFonts.poppins(
                                          fontSize: isLandscape ? 12 : 14,
                                        ),
                                      ),
                                      Text(
                                        '👤 Usuario: ${emergency.usuario_nombre?.isNotEmpty == true ? emergency.usuario_nombre : 'Anónimo'}',
                                        style: GoogleFonts.poppins(
                                          fontSize: isLandscape ? 12 : 14,
                                        ),
                                      ),
                                      Text(
                                        '📅 Fecha: ${emergency.fecha != null ? DateFormat('yyyy-MM-dd HH:mm').format(emergency.fecha!) : 'Sin fecha'}',
                                        style: GoogleFonts.poppins(
                                          fontSize: isLandscape ? 12 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent,
                                    size: isLandscape ? 20 : 24,
                                  ),
                                  tooltip: 'Eliminar',
                                  onPressed: () => deleteEmergency(emergency.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}