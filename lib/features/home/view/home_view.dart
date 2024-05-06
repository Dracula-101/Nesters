import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Home Screen'),
        ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(AuthSignOutEvent());
          },
          child: const Text('Logout'),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () => const Text("Not Logged in"),
              authenticated: (user) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Email ${user.email}"),
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                    radius: 40,
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
