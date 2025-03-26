import 'dart:async';
import 'dart:developer';

import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/status/status.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/chat/bloc/local_chat/chat_bloc.dart';
import 'package:nesters/theme/theme.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:rxdart/rxdart.dart';

class UserChatPage extends StatelessWidget {
  final String chatId;
  final User userProfile;
  const UserChatPage(
      {super.key, required this.chatId, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        controller: context.read<CentralChatBloc>().getChatController(chatId),
      ),
      child: ChatView(receiverProf: userProfile, chatId: chatId),
    );
  }
}

class ChatView extends StatefulWidget {
  final User receiverProf;
  final String chatId;

  const ChatView({super.key, required this.receiverProf, required this.chatId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final User currentUser;
  final ValueNotifier<bool> _isInputMessageEmpty = ValueNotifier<bool>(true);
  ChatUser? _currentChatUser, _otherChatUser;
  bool isInputMessageEmpty = true;
  bool isOtherChatUserDeleted = false;
  List<ChatMessage> messages = [];
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    currentUser = GetIt.I<AuthRepository>().currentUser!;
    _currentChatUser = ChatUser(
      id: currentUser.id,
      firstName: currentUser.fullName.split(' ').first.capitalize,
      lastName: currentUser.fullName.split(' ').last.capitalize,
      profileImage: currentUser.photoUrl,
    );
    _otherChatUser = ChatUser(
      id: widget.receiverProf.id,
      firstName: widget.receiverProf.fullName.split(' ').first.capitalize,
      lastName: widget.receiverProf.fullName.split(' ').last.capitalize,
      profileImage: widget.receiverProf.photoUrl,
    );
    // log('chatId from UserChatPage: ${state.chatId}');
    context.read<ChatBloc>().add(
          ChatEvent.checkChat(
            currentUser.id,
            widget.receiverProf.id,
          ),
        );
    _loadMessages();
  }

  @override
  void dispose() {
    _isInputMessageEmpty.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }

  void _loadMessages() {
    messages = context
        .read<ChatBloc>()
        .getInitialMessages()
        .map((e) => e.toChatMessage())
        .toList();
    _chatSubscription = _getChatMessageStream().listen((event) {
      setState(() {
        messages = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (value) {
        log('PopScope invoked');
        context.read<ChatBloc>().add(const ChatEvent.closeChat());
      },
      child: Scaffold(
        appBar: _buildAppBarUI(context),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            return SafeArea(
              child: state.chatState?.isLoading ?? false
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : !state.doesChatExist
                      ? const Center(
                          child: Text(
                            'Start Messaging',
                          ),
                        )
                      : _buildChatView(),
            );
          },
        ),
      ),
    );
  }

  void _handleTextChange(String value) {
    _isInputMessageEmpty.value = value.isEmpty;
  }

  AppBar _buildAppBarUI(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      leadingWidth: 45,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(
              widget.receiverProf.photoUrl,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.receiverProf.fullName.toTitleCase,
                  style: AppTheme.labelLarge),
              StreamBuilder<UserStatus?>(
                stream: context.read<ChatBloc>().userStatus,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data?.status == Status.ONLINE
                        ? (snapshot.data?.status.toString() ?? '')
                        : snapshot.data?.lastSeen != null
                            ? 'Last Seen ${DateFormat('hh:mm a').format(snapshot.data!.lastSeen!)}'
                            : 'Offline',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyShades.shade400,
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppTheme.greyShades.shade200,
          height: 1,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return DashChat(
      currentUser: _currentChatUser!,
      messages: messages,
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
        onTextChange: _handleTextChange,
        leading: [
          ValueListenableBuilder<bool>(
            valueListenable: _isInputMessageEmpty,
            builder: (context, isEmpty, child) {
              return isEmpty
                  ? _buildLeading(
                      context,
                    )
                  : Container();
            },
          ),
        ],
      ),
      onSend: (message) {
        _sendMessage(message, context);
      },
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            return state.isLoadingMedia
                ? const CircularProgressIndicator(
                    strokeWidth: 1.5,
                  )
                : const SizedBox();
          },
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return _buildOptions();
              },
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.add,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(
        16.0,
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildOptionItem(
                Icons.photo,
                'Gallery',
                () {
                  Navigator.pop(
                    context,
                  );
                  context.read<ChatBloc>().add(
                        ChatEvent.sendDocument(
                          DocumentSource.GALLERY,
                          currentUser.id,
                        ),
                      );
                },
              ),
              _buildOptionItem(
                Icons.camera_alt,
                'Camera',
                () {
                  Navigator.pop(
                    context,
                  );
                  context.read<ChatBloc>().add(
                        ChatEvent.sendDocument(
                          DocumentSource.CAMERA,
                          currentUser.id,
                        ),
                      );
                },
              ),
            ],
          ),
          // Add more Row widgets for additional options as needed
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
            ),
            Text(
              label,
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<ChatMessage>> _getChatMessageStream() {
    return context.read<ChatBloc>().chatMessages.map(
      (event) {
        return event.map(
          (e) {
            if (e.messageType == ChatMessageType.TEXT) {
              return ChatMessage(
                user: e.senderId == currentUser.id
                    ? _currentChatUser as ChatUser
                    : _otherChatUser as ChatUser,
                createdAt: e.sentAt?.toDate() ?? DateTime.now(),
                text: e.content ?? '',
              );
            } else {
              return ChatMessage(
                user: e.senderId == currentUser.id
                    ? _currentChatUser!
                    : _otherChatUser!,
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
        ).toList();
      },
    );
  }

  void _sendMessage(ChatMessage message, BuildContext context) {
    context.read<ChatBloc>().add(
          ChatEvent.sendMessage(
            Message(
              id: "0",
              senderId: currentUser.id,
              content: message.text,
              sentAt: Timestamp.fromDate(
                message.createdAt,
              ),
              epochTime: DateTime.fromMillisecondsSinceEpoch(
                message.createdAt.millisecondsSinceEpoch,
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
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
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
                        AppTheme.greyShades.shade100,
                      ),
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
                        AppTheme.greyShades.shade100,
                      ),
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
                                Navigator.of(dialogContext).pop();
                                dialogContext.showSuccessSnackBar(
                                  'File downloaded successfully',
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
