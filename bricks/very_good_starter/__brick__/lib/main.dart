import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/app.dart';
import 'package:{{project_name.snakeCase()}}/authentication/repository/authentication_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize repositories
  final authenticationRepository = AuthenticationRepository();

  runApp(
    App(authenticationRepository: authenticationRepository),
  );
}
