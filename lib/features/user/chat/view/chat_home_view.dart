import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/chat/view/widgets/chat_user_widget.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppTheme.titleLarge,
        ),
      ),
      body: const SafeArea(
        child: ChatHomeView(),
      ),
    );
  }
}

class ChatHomeView extends StatefulWidget {
  const ChatHomeView({super.key});

  @override
  State<ChatHomeView> createState() => _ChatHomeViewState();
}

class _ChatHomeViewState extends State<ChatHomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CentralChatBloc, CentralChatState>(
      builder: (context, state) {
        return state.chatState.exception != null
            ? _buildChatErrorView(state.chatState.exception!)
            : state.chatState.isLoading == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : state.chatStates.isNotEmpty
                    ? _buildChatsView(state.chatStates)
                    : _buildNoChatsView();
      },
    );
  }

  Widget _buildChatsView(List<ChatInfo> chatStates) {
    return RefreshIndicator(
      onRefresh: () {
        context.read<CentralChatBloc>().add(
              const CentralChatEvent.forcedLoadProfiles(),
            );
        return Future<void>.value();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).go(
                    '${AppRouterService.homeScreen}/${AppRouterService.userRequest}');
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.greyShades.shade300,
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const SizedBox(width: 4.0),
                      Icon(
                        FontAwesomeIcons.telegram,
                        color: AppTheme.primaryShades.shade400,
                        size: 28,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Requests',
                        style: AppTheme.bodyMediumLightVariant,
                      ),
                      const Spacer(),
                      BlocBuilder<RequestBloc, RequestState>(
                        builder: (context, state) {
                          int count = state.requestReceivedUsers.fold(0,
                              (previousValue, element) {
                            if (!element.isAccepted && !element.isBanned) {
                              return (previousValue) + 1;
                            } else {
                              return previousValue;
                            }
                          });
                          if (count != 0) {
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryShades.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.surface,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppTheme.primaryShades.shade400,
                      ),
                      const SizedBox(width: 4.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              color: AppTheme.greyShades.shade200,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                QuickChatUser chatUser = chatStates[index].recipientUser;
                return ChatUserWidget(
                  user: chatUser,
                  lastMessage: context
                      .read<CentralChatBloc>()
                      .getChatController(chatUser.chatId!)
                      .latestMessageStream,
                  newMessageCount: context
                      .read<CentralChatBloc>()
                      .getChatController(chatUser.chatId!)
                      .newMessageCount,
                  isDeleted: chatUser.isUserDeleted ?? false,
                  onTap: () {
                    if (chatUser.isUserDeleted ?? false) {
                      context.showErrorSnackBar(
                        'User has deleted their account',
                      );
                    } else {
                      String route =
                          '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/${AppRouterService.userChatPage}/${chatUser.chatId}';
                      GoRouter.of(context).go(
                        route,
                        extra: chatUser.toUser(),
                      );
                    }
                  },
                );
              },
              childCount: chatStates.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChatsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.8,
            child: SvgPicture.asset(
              AppVectorImages.noChatsBackgroundImage,
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
            ),
          ),
          Text(
            'No chats yet',
            style: AppTheme.titleLarge,
          ),
          Text(
            'Send a request to chat with someone',
            style: AppTheme.bodyMediumLightVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatErrorView(AppException error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 120,
          ),
          const SizedBox(height: 8),
          Text(
            "Error",
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            error.message,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
