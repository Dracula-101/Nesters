import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/user/chat/bloc/chat_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';

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

  ChatUser? _currentChatUser, _otherChatUser;
  bool isInputMessageEmpty = true;

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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (value) {
        context.read<ChatBloc>().add(const ChatEvent.closeChat());
      },
      child: Scaffold(
        appBar: _buildAppBarUI(context),
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
                      : _buildChatStreamBuilder(),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBarUI(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _mediaMessageButton() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return state.uploadTask?.containsKey(DocumentSource.GALLERY) ??
                      false
                  ? CircularProgressIndicator(
                      value:
                          state.uploadTask![DocumentSource.GALLERY]!.progress,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    )
                  : const SizedBox();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.image,
              color: AppTheme.primary,
            ),
            onPressed: () async {
              context.read<ChatBloc>().add(ChatEvent.sendDocument(
                  DocumentSource.GALLERY, currentUser.id));
            },
          )
        ],
      ),
    );
  }

  Widget _cameraButton() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return state.uploadTask?.containsKey(DocumentSource.CAMERA) ??
                      false
                  ? CircularProgressIndicator(
                      value: state.uploadTask![DocumentSource.CAMERA]!.progress,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    )
                  : const SizedBox();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_rounded,
              color: AppTheme.primary,
            ),
            onPressed: () async {
              context.read<ChatBloc>().add(ChatEvent.sendDocument(
                  DocumentSource.CAMERA, currentUser.id));
            },
          )
        ],
      ),
    );
  }

  StreamBuilder<List<ChatMessage>> _buildChatStreamBuilder() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _getChatMessageStream(),
      builder: (context, snapshot) {
        return DashChat(
          currentUser: _currentChatUser!,
          messages: snapshot.data ?? [],
          messageOptions: MessageOptions(
            showOtherUsersAvatar: false,
            showTime: true,
            showOtherUsersName: false,
            currentUserContainerColor: AppTheme.primaryShades.shade500,
            currentUserTimeTextColor: AppTheme.greyShades.shade400,
            timeFormat: DateFormat('hh:mm a'),
            onTapMedia: (media) async {
              await showMedia(media);
            },
          ),
          messageListOptions: MessageListOptions(
            dateSeparatorFormat: DateFormat('dd MMMM yyyy'),
          ),
          inputOptions: InputOptions(
            alwaysShowSend: false,
            showTraillingBeforeSend: false,
            onTextChange: (value) {
              setState(() {
                isInputMessageEmpty = value.isEmpty;
              });
            },
            leading: isInputMessageEmpty ? [_mediaMessageButton()] : [],
            trailing: isInputMessageEmpty ? [_cameraButton()] : [],
          ),
          onSend: (message) {
            _sendMessage(message, context);
          },
        );
      },
    );
  }

  Stream<List<ChatMessage>> _getChatMessageStream() {
    return context.read<ChatBloc>().chatMessages.map(
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
        );
  }

  void _sendMessage(ChatMessage message, BuildContext context) {
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
  }

  Future<void> showMedia(ChatMedia media) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Material(
            color: AppTheme.blackShades.shade400,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(
                      16,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: media.url,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppTheme.greyShades.shade100),
                    ),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.primary,
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppTheme.greyShades.shade100),
                    ),
                    icon: Icon(
                      Icons.download,
                      color: AppTheme.primary,
                    ),
                    onPressed: () {
                      context.read<ChatBloc>().add(
                            ChatEvent.downloadDocument(
                              media.url,
                              () {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'File downloaded successfully in /downloads'),
                                  ),
                                );
                              },
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
