import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/domain/models/chat_message.dart';
import 'package:nesters/domain/models/user.dart';
import 'package:nesters/domain/models/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/user/chat/bloc/chat_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class UserChatPage extends StatelessWidget {
  final String chatId;
  final UserQuickProfile userQuickProfile;
  const UserChatPage(
      {super.key, required this.chatId, required this.userQuickProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: ChatView(receiverProf: userQuickProfile),
    );
  }
}

class ChatView extends StatefulWidget {
  final UserQuickProfile receiverProf;

  const ChatView({super.key, required this.receiverProf});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => throw Exception('User not authenticated'),
        );
    context
        .read<ChatBloc>()
        .add(ChatEvent.checkChat(currentUser.id, widget.receiverProf.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(
                  widget.receiverProf.profileImage ?? ''),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverProf.fullName ?? '',
                    style: AppTheme.labelLarge),
                Text(
                  '${(widget.receiverProf.city ?? '').toString().trim()}, ${widget.receiverProf.state ?? ''}',
                  style: AppTheme.labelSmallLightVariant,
                ),
              ],
            )
          ],
        ),
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !state.doesChatExist
                    ? const Center(child: Text('No chat found'))
                    : StreamBuilder<List<ChatMessage>>(
                        stream: context.read<ChatBloc>().chatMessages.map(
                            (event) =>
                                event.map((e) => e.toChatMessage()).toList()),
                        builder: (context, snapshot) {
                          return DashChat(
                            currentUser: ChatUser(
                              id: currentUser.id,
                              firstName: currentUser.name.split(' ').first,
                              lastName: currentUser.name.split(' ').last,
                              profileImage: currentUser.photoUrl,
                            ),
                            messages: snapshot.data ?? [],
                            onSend: (message) {
                              context.read<ChatBloc>().add(
                                    ChatEvent.sendMessage(
                                      Message(
                                        senderId: currentUser.id,
                                        receiverId: widget.receiverProf.id!,
                                        message: message.text,
                                        timestamp: DateTime.now(),
                                        chatId: state.chatId,
                                      ),
                                    ),
                                  );
                            },
                          );
                        }),
          );
        },
      ),
    );
  }
}
