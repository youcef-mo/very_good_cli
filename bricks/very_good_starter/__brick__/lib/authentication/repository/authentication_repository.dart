import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Authentication backend to use
enum AuthBackend {
  /// Use Firebase Authentication
  firebase,

  /// Use Supabase Authentication
  supabase,
}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// Supports both Firebase and Supabase backends.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    supabase.SupabaseClient? supabaseClient,
    this.backend = AuthBackend.firebase,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _supabaseClient = supabaseClient ?? supabase.Supabase.instance.client;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final supabase.SupabaseClient _supabaseClient;
  final AuthBackend backend;
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    if (backend == AuthBackend.firebase) {
      return _firebaseAuth.authStateChanges().map((firebaseUser) {
        final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
        return user;
      });
    } else {
      return _supabaseClient.auth.onAuthStateChange.map((state) {
        final user =
            state.session?.user == null ? User.empty : state.session!.user.toUser;
        return user;
      });
    }
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    if (backend == AuthBackend.firebase) {
      return _firebaseAuth.currentUser?.toUser ?? User.empty;
    } else {
      return _supabaseClient.auth.currentUser?.toUser ?? User.empty;
    }
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
      if (backend == AuthBackend.firebase) {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final response = await _supabaseClient.auth.signUp(
          email: email,
          password: password,
        );
        if (response.user == null) {
          throw const SignUpWithEmailAndPasswordFailure(
            'Failed to create user',
          );
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } on supabase.AuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure(e.message);
    } catch (e) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (backend == AuthBackend.firebase) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final response = await _supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user == null) {
          throw const LogInWithEmailAndPasswordFailure('Login failed');
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } on supabase.AuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure(e.message);
    } catch (e) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs in anonymously.
  ///
  /// Throws a [LogInAnonymouslyFailure] if an exception occurs.
  Future<void> logInAnonymously() async {
    try {
      if (backend == AuthBackend.firebase) {
        await _firebaseAuth.signInAnonymously();
      } else {
        final response = await _supabaseClient.auth.signInAnonymously();
        if (response.user == null) {
          throw const LogInAnonymouslyFailure('Anonymous login failed');
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInAnonymouslyFailure.fromCode(e.code);
    } on supabase.AuthException catch (e) {
      throw LogInAnonymouslyFailure(e.message);
    } catch (e) {
      throw const LogInAnonymouslyFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      if (backend == AuthBackend.firebase) {
        await _firebaseAuth.signOut();
      } else {
        await _supabaseClient.auth.signOut();
      }
    } catch (e) {
      throw LogOutFailure();
    }
  }

  /// Checks if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Marks onboarding as seen
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(
      id: uid,
      email: email,
      name: displayName,
      photo: photoURL,
      isAnonymous: isAnonymous,
    );
  }
}

extension on supabase.User {
  User get toUser {
    return User(
      id: id,
      email: email,
      name: userMetadata?['name'] as String?,
      photo: userMetadata?['avatar_url'] as String?,
      isAnonymous: isAnonymous,
    );
  }
}

/// {@template user}
/// User model
/// {@endtemplate}
class User {
  /// {@macro user}
  const User({
    required this.id,
    this.email,
    this.name,
    this.photo,
    this.isAnonymous = false,
  });

  /// The current user's id.
  final String id;

  /// The current user's email address.
  final String? email;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  /// Whether the user is anonymous.
  final bool isAnonymous;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;
}

/// {@template sign_up_with_email_and_password_failure}
/// Thrown during the sign up process if a failure occurs.
/// {@endtemplate}
class SignUpWithEmailAndPasswordFailure implements Exception {
  /// {@macro sign_up_with_email_and_password_failure}
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed. Please contact support.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_email_and_password_failure}
/// Thrown during the login process if a failure occurs.
/// {@endtemplate}
class LogInWithEmailAndPasswordFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_anonymously_failure}
/// Thrown during the anonymous login process if a failure occurs.
/// {@endtemplate}
class LogInAnonymouslyFailure implements Exception {
  /// {@macro log_in_anonymously_failure}
  const LogInAnonymouslyFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInAnonymouslyFailure.fromCode(String code) {
    switch (code) {
      case 'operation-not-allowed':
        return const LogInAnonymouslyFailure(
          'Anonymous accounts are not enabled. Please contact support.',
        );
      default:
        return const LogInAnonymouslyFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}
