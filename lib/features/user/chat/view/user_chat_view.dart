import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user.dart';
import 'package:nesters/domain/models/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/user/chat/bloc/chat_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:nesters/utils/merdia_service.dart';

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
  final MediaService _mediaService = GetIt.I<MediaService>();
  final RemoteChatRepository _remoteChatRepository =
      GetIt.I<RemoteChatRepository>();
  ChatUser? _currentChatUser, _otherChatUser;
  ChatBloc? _chatBloc;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => throw Exception('User not authenticated'),
        );
    _currentChatUser = ChatUser(
      id: currentUser.id,
      firstName: currentUser.name.split(' ').first,
      lastName: currentUser.name.split(' ').last,
      profileImage: currentUser.photoUrl,
    );
    _otherChatUser = ChatUser(
      id: widget.receiverProf.id!,
      firstName: widget.receiverProf.fullName!.split(' ').first,
      lastName: widget.receiverProf.fullName!.split(' ').last,
      profileImage: widget.receiverProf.profileImage,
    );

    context.read<ChatBloc>().add(
          ChatEvent.checkChat(
            currentUser.id,
            widget.receiverProf.id!,
          ),
        );
    _chatBloc = context.read<ChatBloc>();
  }

  //cancel the event added to chatMessage listener,
  @override
  void dispose() {
    _chatBloc!.add(const ChatEvent.cancelChatSubscription());
    super.dispose();
  }

  Widget _mediaMessageButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.add,
      ),
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatId = _remoteChatRepository.generateChatId(
            currentUser.id,
            widget.receiverProf.id!,
          );
          String? downloadUrl = await _remoteChatRepository.uploadImageToChat(
            file: file,
            chatID: chatId,
          );
          if (downloadUrl != null) {
            Message message = Message(
              senderId: currentUser.id,
              content: downloadUrl,
              sentAt: Timestamp.fromDate(
                DateTime.now(),
              ),
              messageType: ChatMessageType.IMAGE,
            );
            context.read<ChatBloc>().add(
                  ChatEvent.sendMessage(message),
                );
          }
        }
      },
    );
  }

  Widget _cameraButton() {
    return IconButton(
      icon: const Icon(
        Icons.camera_alt,
      ),
      onPressed: () {},
    );
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : !state.doesChatExist
                    ? const Center(
                        child: Text(
                          'Start Messaging',
                        ),
                      )
                    : StreamBuilder<List<ChatMessage>>(
                        stream: context.read<ChatBloc>().chatMessages.map(
                              (event) => event.map(
                                (e) {
                                  if (e.messageType == ChatMessageType.TEXT) {
                                    return ChatMessage(
                                      user: e.senderId == currentUser.id
                                          ? _currentChatUser as ChatUser
                                          : _otherChatUser as ChatUser,
                                      createdAt: e.sentAt!.toDate(),
                                      text: e.content ?? '',
                                    );
                                  } else {
                                    return ChatMessage(
                                      user: e.senderId == currentUser.id
                                          ? _currentChatUser as ChatUser
                                          : _otherChatUser as ChatUser,
                                      createdAt: e.sentAt!.toDate(),
                                      medias: [
                                        ChatMedia(
                                          url: e.content!,
                                          fileName: '',
                                          type: MediaType.image,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ).toList(),
                            ),
                        builder: (context, snapshot) {
                          return DashChat(
                            currentUser: _currentChatUser!,
                            messages: snapshot.data ?? [],
                            messageOptions: const MessageOptions(
                              showOtherUsersAvatar: true,
                              showTime: true,
                            ),
                            inputOptions: InputOptions(
                              alwaysShowSend: false,
                              // showTraillingBeforeSend: true,
                              leading: [
                                _mediaMessageButton(context),
                                _cameraButton(),
                              ],
                              // trailing: [

                              // ],
                            ),
                            onSend: (message) {
                              context.read<ChatBloc>().add(
                                    ChatEvent.sendMessage(
                                      Message(
                                        senderId: currentUser.id,
                                        content: message.text,
                                        sentAt: Timestamp.fromDate(
                                          message.createdAt,
                                        ),
                                        messageType: ChatMessageType.TEXT,
                                      ),
                                    ),
                                  );
                            },
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}
