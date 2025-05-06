import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> _login() async {
    final result = await authService.login(
      usernameController.text,
      passwordController.text,
    );

    if (result != null) {
      String tipoUsuario = result['tipo_usuario'];
      String token = result['access'];

      if (tipoUsuario == 'admin') {
        Navigator.pushNamed(context, '/admin_home', arguments: token);
      } else {
        Navigator.pushNamed(context, '/user_home', arguments: token);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Iniciar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.red[600],
        elevation: 8,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red[600]),
              const SizedBox(height: 20),
              Text(
                'Sistema de Emergencias',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Usuario o Email',
                  labelStyle: const TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.next, // Move focus to password field after Enter
                onSubmitted: (_) {
                  FocusScope.of(context).nextFocus();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done, // Trigger login on Enter
                onSubmitted: (_) {
                  _login();
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _login,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}