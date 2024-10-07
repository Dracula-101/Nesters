import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/settings/bloc/settings_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            context.read<AuthBloc>().state.maybeWhen(
                  authenticated: (user) => user,
                  orElse: () => throw Exception('User not authenticated'),
                ),
          ),
          child: Scaffold(
            body: SettingsView(),
          ),
        );
      },
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Settings'),
          floating: true,
          snap: true,
        ),
        _buildProfile(),
      ],
    );
  }

  Widget _buildProfile() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: CustomCard(
              padding: const EdgeInsets.all(12),
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(state.user.photoUrl),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.fullName,
                        style: AppTheme.titleLarge,
                      ),
                      Text(
                        '${state.user.email.split('@').first.substring(0, 5)}*****@${state.user.email.split('@').last}',
                        style: AppTheme.labelSmallLightVariant,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
