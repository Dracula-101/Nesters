import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
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
          child: const Scaffold(
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
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          leadingWidth: 120,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.primary,
                  ),
                  Text(
                    'Back',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Text('Account', style: AppTheme.bodyLarge),
          floating: true,
          snap: true,
        ),
        _buildProfile(),
        _buildProfileSettings(isSwitched),
      ],
    );
  }

  Widget _buildProfile() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(state.user.photoUrl),
                ),
                const SizedBox(height: 20),
                Text(
                  state.user.fullName,
                  style: AppTheme.headlineVerySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${state.user.email.split('@').first.substring(0, 5)}*****@${state.user.email.split('@').last}',
                  style: AppTheme.bodyMediumLightVariant,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSettings(bool isSwitched) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Personal Information",
                  style: AppTheme.titleLarge,
                ),
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Edit Profile',
                subtitle: 'Update your profile information',
                icon: Icons.person,
                onTap: () {
                  GoRouter.of(context).go(
                      "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.editProfile}");
                },
              ),
              const Divider(thickness: 1, height: 1),
              SettingSwitch(
                title: "Visibility",
                subtitle: "Still looking for roomates?",
                icon: Icons.visibility,
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  const SettingsTile(
      {super.key, required this.title, this.subtitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: AppTheme.primary,
                  )
                : Container(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                  subtitle != null
                      ? Text(
                          subtitle!,
                          style: AppTheme.bodySmallLightVariant,
                        )
                      : Container(),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: AppTheme.primary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingSwitch extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SettingSwitch> createState() => _SettingSwitchState();
}

class _SettingSwitchState extends State<SettingSwitch> {
  bool _currentValue = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: AppTheme.bodySmallLightVariant,
                  ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: _currentValue,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onChanged(value);
              },
              activeColor: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
