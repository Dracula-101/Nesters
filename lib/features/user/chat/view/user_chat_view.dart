import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/domain/models/user/status/status.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/user/chat/bloc/chat_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart'; //for DateFormat

class UserChatPage extends StatelessWidget {
  final String chatId;
  final User userProfile;
  const UserChatPage(
      {super.key, required this.chatId, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatId: chatId),
      child: ChatView(receiverProf: userProfile),
    );
  }
}

class ChatView extends StatefulWidget {
  final User receiverProf;

  const ChatView({super.key, required this.receiverProf});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final User currentUser;
  ValueNotifier<bool> _isInputMessageEmpty = ValueNotifier<bool>(true);
  ChatUser? _currentChatUser, _otherChatUser;
  bool isInputMessageEmpty = true;

  @override
  void initState() {
    super.initState();
    currentUser = GetIt.I<AuthRepository>().currentUser!;
    _currentChatUser = ChatUser(
      id: currentUser.id,
      firstName: currentUser.fullName.split(' ').first,
      lastName: currentUser.fullName.split(' ').last,
      profileImage: currentUser.photoUrl,
    );
    _otherChatUser = ChatUser(
      id: widget.receiverProf.id,
      firstName: widget.receiverProf.fullName.split(' ').first,
      lastName: widget.receiverProf.fullName.split(' ').last,
      profileImage: widget.receiverProf.photoUrl,
    );

    context.read<ChatBloc>().add(
          ChatEvent.checkChat(
            currentUser.id,
            widget.receiverProf.id,
          ),
        );
  }

  @override
  void dispose() {
    _isInputMessageEmpty.dispose();
    super.dispose();
  }

  void _handleTextChange(String value) {
    _isInputMessageEmpty.value = value.isEmpty;
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
              Text(widget.receiverProf.fullName, style: AppTheme.labelLarge),
              StreamBuilder<UserStatus>(
                stream: context.read<ChatBloc>().userStatus,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data?.status == Status.ONLINE
                        ? (snapshot.data?.status.toString() ?? '')
                        : snapshot.data?.lastSeen != null
                            ? 'Last seen ${DateFormat('hh:mm a').format(snapshot.data!.lastSeen!)}'
                            : 'Offline',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyShades.shade400,
                    ),
                  );
                },
              )
            ],
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
      },
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            return state.uploadTask != null
                ? const CircularProgressIndicator()
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
              _buildOptionItem(Icons.photo, 'Gallery', () {
                Navigator.pop(
                  context,
                );
                context.read<ChatBloc>().add(
                      ChatEvent.sendDocument(
                        DocumentSource.GALLERY,
                        currentUser.id,
                      ),
                    );
              }),
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
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'File downloaded successfully',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppTheme.primary,
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
