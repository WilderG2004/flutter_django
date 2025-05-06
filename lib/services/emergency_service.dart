import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emergency.dart';

class EmergencyService {
  final String baseUrl = 'https://backend-django-l51z.onrender.com/api/emergencias/';

  // Método para listar emergencias
  Future<List<Emergencia>> listEmergency(String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}lista/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Emergencia.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load emergencies');
    }
  }

  // Método para reportar una emergencia
  Future<http.Response> reportEmergency(String tipo, String token, String piso) async {
    final response = await http.post(
      Uri.parse('${baseUrl}crear/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipo': tipo,
        'piso': piso,
      }),
    );

    return response; // Devuelve el objeto http.Response
  }

  // Método para eliminar una emergencia
  Future<bool> deleteEmergency(int emergencyId, String token) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}eliminar/$emergencyId/eliminar/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204; // 204 No Content para eliminación exitosa
  }
}