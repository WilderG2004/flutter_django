import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/emergency_service.dart';
import '../models/emergency.dart';

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

  @override
  void initState() {
    super.initState();
    fetchEmergencies();
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
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: emergencies.length,
                  itemBuilder: (context, index) {
                    final emergency = emergencies[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          radius: 28,
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                        ),
                        title: Text(
                          emergency.tipo ?? 'Emergencia',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📍 Piso: ${emergency.piso ?? 'Desconocido'}',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '👤 Usuario: ${emergency.usuario_nombre?.isNotEmpty == true ? emergency.usuario_nombre : 'Anónimo'}',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '📅 Fecha: ${emergency.fecha != null ? DateFormat('yyyy-MM-dd HH:mm').format(emergency.fecha!) : 'Sin fecha'}',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          tooltip: 'Eliminar',
                          onPressed: () => deleteEmergency(emergency.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
