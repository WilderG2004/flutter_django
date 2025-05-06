import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  String? _accessToken; // Para almacenar el token de acceso
  String? _refreshToken; // Para almacenar el token de refresco

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_instance.baseUrl}login/'), // Usa _instance.baseUrl
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _instance._accessToken = data['access']; // Usa _instance._accessToken
        _instance._refreshToken = data['refresh']; // Usa _instance._refreshToken
        print('Access Token recibido: ${_instance._accessToken}');
        print('Refresh Token recibido: ${_instance._refreshToken}');
        return {
          'access': data['access'],
          'refresh': data['refresh'],
          'tipo_usuario': data['tipo_usuario'],
        };
      } else {
        print('Error en login: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Método para obtener el token de acceso actual
  Future<String?> getToken() async {
    return _instance._accessToken; // Usa _instance._accessToken
  }

  // Método para registrar un usuario
  Future<bool> register(String username, String password, String email, String phone, String tipousuario, String? adminKey, String name) async {
    if (username.isEmpty || password.isEmpty || email.isEmpty || phone.isEmpty || tipousuario.isEmpty || name.isEmpty) {
      return false;
    }

    final Map<String, String> requestBody = {
      'username': username,
      'password': password,
      'email': email,
      'telefono': phone,
      'tipo_usuario': tipousuario,
      'nombre': name,
    };

    if (tipousuario == 'admin' && adminKey != null && adminKey.isNotEmpty) {
      requestBody['clave_admin'] = adminKey;
    }

    try {
      final response = await http.post(
        Uri.parse('${_instance.baseUrl}registro/'), // Usa _instance.baseUrl
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error en register: $e');
      return false;
    }
  }

  // Método para obtener el tipo de usuario
  Future<String?> getUserType(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${_instance.baseUrl}mi-perfil/'), // Usa _instance.baseUrl
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['tipo_usuario'];
      } else {
        print('Error al obtener tipo de usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en getUserType: $e');
      return null;
    }
  }

  // Método para refrescar el token de acceso
  Future<bool> refreshToken() async {
    if (_instance._refreshToken == null) { // Usa _instance._refreshToken
      print('Error: No hay token de refresco disponible');
      return false; // No hay token de refresco para usar
    }

    try {
      final response = await http.post(
        Uri.parse('${_instance.baseUrl}token/refresh/'), // Usa _instance.baseUrl
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': _instance._refreshToken}), // Usa _instance._refreshToken
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _instance._accessToken = data['access']; // Actualiza el token de acceso usando _instance
        return true; // El token se refrescó exitosamente
      } else {
        print('Error al refrescar el token: ${response.statusCode} - ${response.body}');
        _instance._accessToken = null;
        _instance._refreshToken = null;
        return false; // Forzar al usuario a iniciar sesión nuevamente
      }
    } catch (e) {
      print('Error en refreshToken: $e');
      return false; // Error de red
    }
  }

 final String baseUrl = 'https://backend-django-l51z.onrender.com/api/usuarios/';
}