import 'package:flutte_django/views/AdminUsersView.dart';
import 'package:flutter/material.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/admin_home_view.dart';
import 'views/user_home_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergencias App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/admin_home': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String?;
          if (token == null) {
            return Scaffold(
              body: Center(
                child: Text('Error: Token no proporcionado'),
            ),
          );
        }
      return AdminHomeView(token: token);
    },
        '/user_home': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String;
          return UserHomeView(token: token);
        },
        '/admin_users': (context) {
             final token = ModalRoute.of(context)!.settings.arguments as String;
             return AdminUsersView(token: token);
},
      },
    );
  }
}