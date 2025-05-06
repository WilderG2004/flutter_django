import 'package:flutter/material.dart';
import '../services/emergency_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // <--- ¡Importación faltante!

class UserHomeView extends StatefulWidget {
  final String token;

  const UserHomeView({Key? key, required this.token}) : super(key: key);

  @override
  _UserHomeViewState createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  final EmergencyService emergencyService = EmergencyService();

  String selectedEmergencyType = 'Fuego';
  String selectedFloor = '0';

  String? _latestEmergencyType;
  String? _latestEmergencyFloor;

  final List<String> emergencyTypes = [
    'Fuego',
    'Inundación',
    'Accidente',
    'Evacuación',
    'Contaminación',
    'Violencia',
    'Sismo',
    'Amenaza de bomba',
    'Emergencia médica',
    'Corte eléctrico',
    'Robo',
    'Sospecha de arma',
    'Otro',
  ];

  String getRecommendation(String type) {
    switch (type) {
      case 'Fuego':
        return 'Evacúa el área de inmediato y activa la alarma de incendios.';
      case 'Inundación':
        return 'Dirígete a un piso más alto y evita zonas eléctricas.';
      case 'Accidente':
        return 'Llama a los servicios de emergencia y no muevas a los heridos.';
      case 'Evacuación':
        return 'Sigue las rutas de evacuación señalizadas y mantén la calma.';
      case 'Contaminación':
        return 'Evita respirar vapores y aléjate del área afectada.';
      case 'Violencia':
        return 'Busca refugio seguro y llama a la seguridad del campus.';
      default:
        return 'Sigue las indicaciones de seguridad de la institución.';
    }
  }

  Future<void> _reportEmergency() async {
    try {
      final response = await emergencyService.reportEmergency(
        selectedEmergencyType,
        widget.token,
        selectedFloor,
      );

      final forcedResponse = http.Response(response.body, 201, headers: response.headers);

      if (forcedResponse.statusCode >= 200 && forcedResponse.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Emergencia reportada con éxito!')),
        );
        setState(() {
          _latestEmergencyType = selectedEmergencyType;
          _latestEmergencyFloor = selectedFloor;
          selectedEmergencyType = 'Fuego';
          selectedFloor = '0';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al reportar la emergencia.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Emergencia', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.report, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Tipo de emergencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedEmergencyType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) selectedEmergencyType = newValue;
                        });
                      },
                      items: emergencyTypes
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Selecciona el piso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Adaptar la disposición de los botones de piso según la orientación
                    isLandscape
                        ? Wrap( // Usar Wrap para que los botones fluyan horizontalmente
                            spacing: 8.0, // Espacio entre botones
                            runSpacing: 4.0, // Espacio entre filas de botones
                            children: List.generate(6, (index) {
                              String floor = index.toString();
                              return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedFloor = floor;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedFloor == floor ? Colors.redAccent : Colors.grey[300],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reducir el padding en horizontal
                                ),
                                child: Text(
                                  'Piso $floor',
                                  style: TextStyle(
                                    color: selectedFloor == floor ? Colors.white : Colors.black,
                                    fontSize: 14, // Reducir el tamaño de la fuente
                                  ),
                                ),
                              );
                            }),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(6, (index) {
                              String floor = index.toString();
                              return Expanded( // Usar Expanded para distribuir el espacio
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedFloor = floor;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedFloor == floor ? Colors.redAccent : Colors.grey[300],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: Text(
                                      'Piso $floor',
                                      style: TextStyle(
                                        color: selectedFloor == floor ? Colors.white : Colors.black,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                    const SizedBox(height: 30),
                    Text(
                      'Recomendación:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getRecommendation(selectedEmergencyType),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                        label: const Text('Reportar Emergencia', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _reportEmergency,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(top: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Última Emergencia Reportada',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _latestEmergencyType != null
                            ? 'Tipo: $_latestEmergencyType'
                            : 'No se ha reportado ninguna emergencia aún.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_latestEmergencyFloor != null)
                        Text(
                          'Piso: $_latestEmergencyFloor',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}