import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/features/apartment/list/bloc/apartment_bloc.dart';
import 'package:nesters/features/apartment/list/view/apartment_list_page.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/home.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/home/view/components/home_page_tutorial.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/features/marketplace/list/view/marketplace_list_page.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/features/sublet/list/view/sublet_list_page.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScaffold extends StatefulWidget {
  final int initialIndex;
  const HomeScaffold({super.key, required this.initialIndex});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  bool _isNetworkDisabled = false;

  void showNetworkDisabledBottomSheet() {
    setState(() => _isNetworkDisabled = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: MediaQuery.of(context).size.width * 0.3,
                      color: AppTheme.greyShades.shade300,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'No Internet Available',
                        style: AppTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Check Your Internet Connection and Try Again.',
                      style: AppTheme.bodyMediumLightVariant,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) => setState(() => _isNetworkDisabled = false));
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      String userId = context.read<AuthBloc>().state.maybeWhen(
            authenticated: (user) => user.id,
            orElse: () => throw Exception('User Not Authenticated'),
          );
      context
          .read<CentralChatBloc>()
          .add(CentralChatEvent.initalizeUserStatusSocket(userId));
      context
          .read<CentralChatBloc>()
          .add(const CentralChatEvent.loadProfiles());
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
        BlocProvider(
          create: (context) => UserBloc(
            context.read<AuthBloc>().state.maybeWhen(
                  authenticated: (user) => user,
                  orElse: () => throw Exception('User Not Authenticated'),
                ),
          ),
        ),
        BlocProvider(
          create: (context) => SubletBloc(),
        ),
        BlocProvider(
          create: (context) => ApartmentBloc(),
        ),
        BlocProvider(
          create: (context) => MarketplaceBloc(),
        )
      ],
      child: BlocListener<AppBloc, AppState>(
        listenWhen: (previous, current) =>
            previous.isOnline != current.isOnline,
        listener: (context, state) {
          if (state.isOnline) {
            if (_isNetworkDisabled) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          } else {
            if (!_isNetworkDisabled) {
              showNetworkDisabledBottomSheet();
            }
          }
        },
        child: HomeView(initialIndex: widget.initialIndex),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({super.key, required this.initialIndex});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ValueNotifier<int> _selectedIndex =
      ValueNotifier<int>(widget.initialIndex);

  late TutorialCoachMark tutorialCoachMark;
  final GlobalKey _bottomNavFirstIconKey = GlobalKey();
  final GlobalKey _bottomNavSecondIconKey = GlobalKey();
  final GlobalKey _bottomNavThirdIconKey = GlobalKey();
  final GlobalKey _bottomNavFourthIconKey = GlobalKey();
  final GlobalKey _chatIconKey = GlobalKey();
  final GlobalKey _requestIconKey = GlobalKey();
  final GlobalKey _settingsIconKey = GlobalKey();

  final UserRepository userRepository = GetIt.I<UserRepository>();

  void _initShowTutorial() {
    if (userRepository.checkUserTutorialComplete()) {
      return;
    }
    tutorialCoachMark = TutorialCoachMark(
      targets: addTargetHomePage(
        firstIconKey: _bottomNavFirstIconKey,
        secondIconKey: _bottomNavSecondIconKey,
        thirdIconKey: _bottomNavThirdIconKey,
        fourthIconKey: _bottomNavFourthIconKey,
        chatIconKey: _chatIconKey,
        requestIconKey: _requestIconKey,
        settingsIconKey: _settingsIconKey,
      ),
      colorShadow: AppTheme.shadowColor,
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        userRepository.markUserTutorialComplete();
      },
      onSkip: () {
        userRepository.markUserTutorialComplete();
        return true;
      },
    )..show(context: context);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _initShowTutorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, child) {
          return NavigationBar(
            destinations: [
              NavigationDestination(
                key: _bottomNavFirstIconKey,
                tooltip: 'Network',
                label: 'Network',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    FontAwesomeIcons.userGroup,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
              NavigationDestination(
                key: _bottomNavSecondIconKey,
                tooltip: 'Sublet',
                label: 'Sublet',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    FontAwesomeIcons.bed,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
              NavigationDestination(
                key: _bottomNavThirdIconKey,
                tooltip: 'Apartments',
                label: 'Apartments',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    FontAwesomeIcons.house,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
              NavigationDestination(
                key: _bottomNavFourthIconKey,
                tooltip: 'Marketplace',
                label: 'Marketplace',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    FontAwesomeIcons.store,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ],
            onDestinationSelected: (index) {
              if (index == selectedIndex) {
                return;
              } else {
                _selectedIndex.value = index;
              }
            },
            selectedIndex: selectedIndex,
            indicatorColor: AppTheme.primary.withOpacity(0.15),
            shadowColor: AppTheme.shadowColor,
            elevation: 12,
            height: 70,
          );
        },
      ),
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder: (context, value, child) {
                    return IndexedStack(
                      index: value,
                      children: [
                        UserListPage(
                          chatIconKey: _chatIconKey,
                          requestIconKey: _requestIconKey,
                          settingsIconKey: _settingsIconKey,
                        ),
                        const SubletListPage(),
                        const ApartmentListPage(),
                        const MarketplacePage(),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
