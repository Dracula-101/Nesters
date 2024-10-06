import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/features/auth/auth.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

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
    return Container(
      padding: const EdgeInsets.all(
        16.0,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLoginBrandingImage(),
          _buildLoginText(),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildLoginBrandingImage() {
    return Expanded(
      flex: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          30.0,
        ),
        child: Image.asset(
          AppRasterImages.onboardingBrandingImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLoginText() {
    return Expanded(
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
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(
        20,
      ),
      width: double.infinity,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.when(error: (message) {
            context.showErrorSnackBar(message);
          });
        },
        builder: (context, state) {
          return ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthGoogleSiginInEvent());
            },
            child: state.maybeWhen(
              loading: () => CircularProgressIndicator(
                color: AppTheme.surface,
                strokeWidth: 1.5,
              ),
              orElse: () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppRasterImages.googleIcon,
                    width: 30.0,
                    height: 30.0,
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Text(
                    'Sign in with Google',
                    style: AppTheme.titleSmall.copyWith(
                      color: AppTheme.surface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
