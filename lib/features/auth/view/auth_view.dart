import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/features/auth/auth.dart';
import 'package:nesters/theme/theme.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
            orElse: () => SafeArea(
              child: Container(
                padding: const EdgeInsets.all(
                  16.0,
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                        child: Image.asset(
                          'assets/images/roommates.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Find Your Perfect\nRoommate Here',
                            textAlign: TextAlign.center,
                            style: AppTheme.headlineSmall,
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            'Explore all the most exciting job roles\nbased on your interest And study major',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      margin: const EdgeInsets.all(
                        20,
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(AuthGoogleSiginInEvent());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/google.png',
                              width: 30.0,
                              height: 30.0,
                            ),
                            const SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              'Sign in with Google',
                              style: AppTheme.titleSmall.copyWith(
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
