import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/status/status.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Messages',
          ),
        ),
        body: const ChatHomeView(),
      ),
    );
  }
}

class ChatHomeView extends StatefulWidget {
  const ChatHomeView({super.key});

  @override
  State<ChatHomeView> createState() => _ChatHomeViewState();
}

class _ChatHomeViewState extends State<ChatHomeView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<CentralChatBloc>().add(
          CentralChatEvent.updateUserStatus(
            state == AppLifecycleState.resumed ? Status.ONLINE : Status.OFFLINE,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CentralChatBloc, CentralChatState>(
      builder: (context, state) {
        return state.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.error == null
                ? RefreshIndicator(
                    onRefresh: () {
                      context.read<CentralChatBloc>().add(
                            const CentralChatEvent.forcedLoadProfiles(),
                          );
                      return Future<void>.value();
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              QuickChatUser chatUser =
                                  state.chatStates[index].recipientUser;
                              return Column(
                                children: [
                                  ListTile(
                                      onTap: () {
                                        String route =
                                            '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/${chatUser.chatId}';
                                        GoRouter.of(context).go(
                                          route,
                                          extra: chatUser.toUser(),
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          chatUser.photoUrl ?? '',
                                        ),
                                      ),
                                      title: Text(
                                        chatUser.fullName ?? '',
                                      ),
                                      subtitle: StreamBuilder<Message?>(
                                        stream: context
                                            .read<CentralChatBloc>()
                                            .getChatController(chatUser.chatId!)
                                            .latestMessageStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            bool isMe =
                                                snapshot.data?.senderId ==
                                                    context
                                                        .read<UserBloc>()
                                                        .state
                                                        .user
                                                        .id;
                                            String senderName =
                                                isMe ? 'You: ' : '';
                                            return Text(
                                              '$senderName${(snapshot.data?.messageType == ChatMessageType.TEXT) ? snapshot.data?.content ?? '' : '📷 Attachment'}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          } else {
                                            return const Text('');
                                          }
                                        },
                                      )),
                                  // const Divider(),
                                ],
                              );
                            },
                            childCount: state.chatStates.length,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No chats available'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CentralChatBloc>().add(
                                const CentralChatEvent.forcedLoadProfiles());
                          },
                          child: const Text('Refresh'),
                        )
                      ],
                    ),
                  );
      },
    );
  }
}
