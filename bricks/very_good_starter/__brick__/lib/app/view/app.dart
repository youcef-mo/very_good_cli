import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name.snakeCase()}}/authentication/authentication.dart';
import 'package:{{project_name.snakeCase()}}/authentication/repository/authentication_repository.dart';
import 'package:{{project_name.snakeCase()}}/authentication/view/login_page.dart';
import 'package:{{project_name.snakeCase()}}/home/view/home_page.dart';
import 'package:{{project_name.snakeCase()}}/onboarding/view/onboarding_page.dart';

class App extends StatelessWidget {
  const App({
    required this.authenticationRepository,
    super.key,
  });

  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthenticationBloc>();

    _router = GoRouter(
      initialLocation: '/onboarding',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isOnboarding = state.matchedLocation == '/onboarding';
        final isLogin = state.matchedLocation == '/login';

        if (authState.status == AuthenticationStatus.authenticated) {
          return isOnboarding || isLogin ? '/home' : null;
        }

        if (authState.status == AuthenticationStatus.unauthenticated) {
          return isOnboarding ? null : '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '{{project_name.titleCase()}}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
