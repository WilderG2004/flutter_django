import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart'; // Importa AuthService

class UserService {
final String baseUrl = 'https://backend-django-l51z.onrender.com/api/usuarios/';
  final AuthService _authService = AuthService(); // Obtiene la instancia única

  Future<String?> getAccessToken() async {
    final token = await _authService.getToken(); // Llama al método getToken de la instancia única
    return token;
  }

  Future<List<User>> getStudentUsers() async {
    String? accessToken = await getAccessToken();
    print('Token de acceso que se enviará: $accessToken');
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      print('Intentando refrescar token. Refresh Token actual: (no accesible directamente desde UserService)');
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        accessToken = await getAccessToken(); // Obtiene el nuevo token
        print('Token de acceso DESPUÉS del refresco: $accessToken');
        final retryResponse = await http.get(
          Uri.parse(baseUrl),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        if (retryResponse.statusCode == 200) {
          final List<dynamic> body = json.decode(retryResponse.body);
          return body.map((json) => User.fromJson(json)).toList();
        }
      }
      throw Exception('Error de autenticación al cargar usuarios estudiantes.');
    } else if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar usuarios estudiantes: ${response.statusCode}');
    }
  }

  // Implementa lógica similar de refresco de token para updateUser y deleteUser
  Future<bool> updateUser(int id, Map<String, dynamic> userData) async {
    String? accessToken = await getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl$id/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 401) {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        final retryResponse = await http.put(
          Uri.parse('$baseUrl$id/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(userData),
        );
        return retryResponse.statusCode == 200;
      }
      return false;
    }
    return response.statusCode == 200;
  }

  Future<bool> deleteUser(int id) async {
    String? accessToken = await getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$id/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        final retryResponse = await http.delete(
          Uri.parse('$baseUrl$id/'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        return retryResponse.statusCode == 204;
      }
      return false;
    }
    return response.statusCode == 204;
  }

  Future<User> getUserDetails(int id) async {
    String? accessToken = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl$id/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        final retryResponse = await http.get(
          Uri.parse('$baseUrl$id/'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        if (retryResponse.statusCode == 200) {
          return User.fromJson(json.decode(retryResponse.body));
        }
      }
      throw Exception('Error de autenticación al cargar detalles del usuario $id.');
    } else if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar detalles del usuario $id: ${response.statusCode}');
    }
  }
}