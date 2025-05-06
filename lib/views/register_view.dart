import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController adminKeyController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final AuthService authService = AuthService();

  String selectedRole = 'estudiante';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Registro de Usuario'),
        backgroundColor: Colors.red[600],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.app_registration, size: 80, color: Colors.red[600]),
              SizedBox(height: 20),
              Text(
                'Crear una cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 30),
              _buildTextField(
                controller: usernameController,
                label: 'Usuario',
                icon: Icons.person,
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: nameController,
                label: 'Nombre completo',
                icon: Icons.badge,
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: emailController,
                label: 'Correo Electrónico',
                icon: Icons.email,
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: phoneController,
                label: 'Número de Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: passwordController,
                label: 'Contraseña',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.grey[700]),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                      items: <String>['estudiante', 'admin']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value[0].toUpperCase() + value.substring(1)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              if (selectedRole == 'admin') ...[
                SizedBox(height: 12),
                _buildTextField(
                  controller: adminKeyController,
                  label: 'Clave Secreta de Admin',
                  icon: Icons.vpn_key,
                  obscureText: true,
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.check),
                label: Text('Registrar', style: TextStyle(fontSize: 16)),
                onPressed: () async {
                  if (usernameController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Todos los campos son obligatorios.')),
                    );
                    return;
                  }

                  if (selectedRole == 'admin' && adminKeyController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('La clave secreta es obligatoria para administradores.')),
                    );
                    return;
                  }

                  String? adminSecret = selectedRole == 'admin' ? adminKeyController.text : null;

                  bool success = await authService.register(
                    usernameController.text,
                    passwordController.text,
                    emailController.text,
                    phoneController.text,
                    selectedRole,
                    adminSecret,
                    nameController.text,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registro exitoso')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error en el registro')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
