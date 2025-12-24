import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:{{project_name.snakeCase()}}/app/app.dart';
import 'package:{{project_name.snakeCase()}}/authentication/repository/authentication_repository.dart';

/// Choose your authentication backend
const authBackend = AuthBackend.firebase; // or AuthBackend.supabase

/// Supabase configuration (required if using Supabase)
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize authentication backend
  if (authBackend == AuthBackend.firebase) {
    await Firebase.initializeApp();
  } else {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Initialize repositories
  final authenticationRepository = AuthenticationRepository(
    backend: authBackend,
  );

  runApp(
    App(authenticationRepository: authenticationRepository),
  );
}
