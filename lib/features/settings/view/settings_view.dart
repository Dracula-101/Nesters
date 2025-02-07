import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/settings/bloc/settings_bloc.dart';
import 'package:nesters/features/user/posts/cubit/user_post_state.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        _buildUserPostSettings(),
        _buildAppInfoSettings(),
        _buildDeleteAccount(),
        _buildLogout(),
        _buildSpacing(),
      ],
    );
  }

  Widget _buildSpacing() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: SizedBox(height: 40),
      ),
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

  Widget _buildUserPostSettings() {
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
                  "Your Posts",
                  style: AppTheme.titleLarge,
                ),
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Sublets',
                subtitle: 'Manage Your Sublet Listings',
                icon: Icons.bed,
                onTap: () {
                  GoRouter.of(context).go(
                      "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.sublet}");
                },
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Apartments',
                subtitle: 'Manage Your Apartment Listings',
                icon: Icons.bed,
                onTap: () {
                  GoRouter.of(context).go(
                      "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.apartment}");
                },
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Marketplace',
                subtitle: 'Manage Your Marketplace Listings',
                icon: Icons.shopping_bag,
                onTap: () {
                  GoRouter.of(context).go(
                      "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.marketplace}");
                },
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Liked Posts',
                subtitle: 'For Sublets, Apartments and Marketplaces',
                icon: Icons.favorite,
                onTap: () {
                  GoRouter.of(context).go(
                      "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.favouritePosts}");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSettings() {
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
                  "General",
                  style: AppTheme.titleLarge,
                ),
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Terms of Service',
                subtitle: 'View our terms of service',
                icon: FontAwesomeIcons.handshake,
                iconSize: 18,
                onTap: () {
                  const url =
                      "https://nesters-org.github.io/terms-and-conditions/";
                  try {
                    launchUrlString(url);
                  } catch (e) {
                    // ignore: avoid_print
                  }
                },
              ),
              const Divider(thickness: 1, height: 1),
              SettingsTile(
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                icon: FontAwesomeIcons.userShield,
                iconSize: 18,
                onTap: () {
                  const url = "https://nesters-org.github.io/privacy-policy/";
                  try {
                    launchUrlString(url);
                  } catch (e) {
                    // ignore: avoid_print
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccount() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsTile(
                title: 'Delete Account',
                subtitle: 'Delete your account permanently',
                icon: Icons.delete,
                color: AppTheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog.adaptive(
                        title: const Text('Delete Account'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Are you sure you want to delete your account?'),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.warning, color: AppTheme.error),
                                const SizedBox(width: 10),
                                Text(
                                  'This action cannot be undone.',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(_).pop();
                            },
                            child: Text('Cancel', style: AppTheme.bodyLarge),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(_).pop();
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEvent.deleteAccount());
                            },
                            child: Text(
                              'Delete',
                              style: AppTheme.bodyLarge
                                  .copyWith(color: AppTheme.error),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogout() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsTile(
                title: 'Logout',
                titleStyle: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                subtitle: 'Logout from your account',
                icon: Icons.logout,
                color: AppTheme.onSurface,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog.adaptive(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: const Text('Logout'),
                        content: const Text(
                            'Are you sure you want to logout from your account?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEvent.authSignOut());
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final IconData? icon;
  final double iconSize;
  final VoidCallback? onTap;
  final Color? color;
  const SettingsTile(
      {super.key,
      required this.title,
      this.titleStyle,
      this.subtitle,
      this.icon,
      this.onTap,
      this.iconSize = 24,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: color ?? AppTheme.primary,
                    size: iconSize,
                  )
                : Container(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (titleStyle ?? AppTheme.bodyMedium).copyWith(
                      color: color ?? AppTheme.primary,
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
              color: (color ?? AppTheme.primary).withOpacity(0.5),
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
