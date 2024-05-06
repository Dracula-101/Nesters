import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/features/auth/auth.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthView(),
    );
  }
}

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Center(
          child: state.maybeWhen(
            loading: () => const CircularProgressIndicator(),
            orElse: () => ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthGoogleSiginInEvent());
              },
              child: const Text('Sign up with Google'),
            ),
          ),
        );
      },
    );
  }
}
