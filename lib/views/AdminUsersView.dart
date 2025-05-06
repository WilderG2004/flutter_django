import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class AdminUsersView extends StatefulWidget {
  final String token;
  const AdminUsersView({Key? key, required this.token}) : super(key: key);

  @override
  _AdminUsersViewState createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final UserService userService = UserService();
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listUsers();
  }

  Future<void> listUsers() async {
    setState(() => isLoading = true);
    try {
      final List<User> data = await userService.getStudentUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      bool success = await userService.deleteUser(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado')),
        );
        listUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar al usuario.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _showEditUserDialog(User user) async {
    final nameController = TextEditingController(text: user.nombre ?? '');
    final emailController = TextEditingController(text: user.email ?? '');
    final phoneController = TextEditingController(text: user.telefono ?? '');
    final usernameController = TextEditingController(text: user.username ?? '');
    String? selectedTipoUsuario = user.tipoUsuario;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.edit, color: Colors.red),
              SizedBox(width: 8),
              Text('Editar Usuario'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Asegura que los campos ocupen el ancho
              children: <Widget>[
                _buildInputField('Nombre de Usuario', usernameController),
                _buildInputField('Nombre', nameController),
                _buildInputField('Correo', emailController),
                _buildInputField('Teléfono', phoneController),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo de Usuario'),
                  value: selectedTipoUsuario,
                  items: <String>['estudiante', 'admin'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTipoUsuario = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final updatedUserData = {
                  'username': usernameController.text,
                  'nombre': nameController.text,
                  'email': emailController.text,
                  'telefono': phoneController.text,
                  'tipo_usuario': selectedTipoUsuario,
                };
                try {
                  bool success = await userService.updateUser(user.id!, updatedUserData);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario actualizado')),
                    );
                    listUsers();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se pudo actualizar el usuario')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e')),
                  );
                } finally {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Aumentar un poco el padding vertical
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Bordes más redondeados
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Mayor padding interno
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Lista de Estudiantes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red,
        elevation: 6,
      ),
      body: Column(
        children: [
          SizedBox(height: isLandscape ? 12 : 16), // Reducir el espacio en landscape
          AdminBanner(),
          SizedBox(height: isLandscape ? 8 : 10), // Reducir el espacio en landscape
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : users.isEmpty
                    ? const Center(child: Text('No hay usuarios registrados'))
                    : LayoutBuilder( // Usar LayoutBuilder para adaptar la lista
                        builder: (context, constraints) {
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isLandscape ? screenSize.width * 0.05 : 16), // Ajustar padding horizontal
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final User user = users[index];
                              return FadeInRight(
                                duration: const Duration(milliseconds: 300),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(vertical: 8), // Reducir el margen horizontal en landscape
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.person, color: Colors.red),
                                                const SizedBox(width: 8),
                                                Text(
                                                  user.username ?? 'Sin usuario',
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                                  onPressed: () => _showEditUserDialog(user),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                  onPressed: () => deleteUser(user.id!),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text('📛 Nombre: ${user.nombre ?? 'Sin nombre'}', style: GoogleFonts.poppins()),
                                        Text('✉️ Correo: ${user.email ?? 'Sin correo'}', style: GoogleFonts.poppins()),
                                        Text('📞 Teléfono: ${user.telefono ?? 'Sin teléfono'}', style: GoogleFonts.poppins()),
                                        Text('🏷️ Tipo: ${user.tipoUsuario ?? 'Sin tipo'}', style: GoogleFonts.poppins()),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AdminBanner extends StatelessWidget {
  const AdminBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Container(
      height: isLandscape ? 120 : 150, // Reducir la altura en landscape
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: isLandscape ? screenSize.width * 0.1 : 16), // Ajustar margen horizontal
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.supervised_user_circle,
            size: isLandscape ? 40 : 60, // Reducir el tamaño del icono en landscape
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'Lista de Estudiantes',
            style: TextStyle(
              fontSize: isLandscape ? 18 : 20, // Reducir el tamaño del texto en landscape
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Asegurar que el texto esté centrado
          ),
        ],
      ),
    );
  }
}