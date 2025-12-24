import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name.snakeCase()}}/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationBloc>().add(
                    const AuthenticationLogoutRequested(),
                  );
            },
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to {{project_name.titleCase()}}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (state.user.email != null)
                  Text(
                    'Logged in as: ${state.user.email}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
