import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/domain/models/user/request/request.dart';
import 'package:nesters/features/user/request/request.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestView();
  }
}

class RequestView extends StatefulWidget {
  const RequestView({super.key});

  @override
  State<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state.requestAcceptState.exception != null) {
          context.showErrorSnackBar(
              state.requestAcceptState.exception?.message ?? '');
        } else if (state.requestAcceptState.isSuccess) {
          context.showSuccessSnackBar('Request accepted successfully');
        }
        if (state.requestDeclineState.exception != null) {
          context.showErrorSnackBar(
              state.requestDeclineState.exception?.message ?? '');
        } else if (state.requestDeclineState.isSuccess) {
          context.showSuccessSnackBar('Request rejected successfully');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text('Requests'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<RequestBloc>().add(const RequestEvent.loadUsers());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: CupertinoSlidingSegmentedControl<RequestScreen>(
                      children: const {
                        RequestScreen.RECEIVED: Text('Received'),
                        RequestScreen.SENT: Text('Sent'),
                      },
                      groupValue: state.currentScreen,
                      onValueChanged: (value) {
                        if (value != null) {
                          context
                              .read<RequestBloc>()
                              .add(RequestEvent.changeScreen(value));
                        }
                      },
                    ),
                  ),
                ),
                if (state.requestUserState.isLoading)
                  _buildLoadingScreen()
                else if (state.requestUserState.exception != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(state.requestUserState.exception.toString()),
                    ),
                  )
                else if (state.currentScreen == RequestScreen.SENT)
                  if (state.requestSentUsers.isEmpty)
                    _buildNoRequestScreen(RequestScreen.SENT)
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = state.requestSentUsers[index];
                          return RequestWidget(
                            user: user,
                            isSent: true,
                            type: RequestScreen.SENT,
                            isRejected: user.isBanned,
                            onAccept: () {
                              showRequestDialog(user);
                            },
                            onReject: () {
                              context.read<RequestBloc>().add(
                                    RequestEvent.cancelRequest(
                                      user.receiver.id,
                                    ),
                                  );
                            },
                          );
                        },
                        childCount: state.requestSentUsers.length,
                      ),
                    )
                else if (state.currentScreen == RequestScreen.RECEIVED)
                  if (state.requestReceivedUsers.isEmpty)
                    _buildNoRequestScreen(RequestScreen.RECEIVED)
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = state.requestReceivedUsers[index];
                          return RequestWidget(
                            user: user,
                            isRejected: user.isBanned,
                            type: RequestScreen.RECEIVED,
                            isSent: false,
                            onAccept: () {
                              showRequestDialog(user);
                            },
                            onReject: () {
                              context.read<RequestBloc>().add(
                                    RequestEvent.rejectRequest(
                                      user.receiver.id,
                                    ),
                                  );
                            },
                          );
                        },
                        childCount: state.requestReceivedUsers.length,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoRequestScreen(RequestScreen screen) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: screen == RequestScreen.SENT ? 0 : 0.5,
              child: Icon(
                FontAwesomeIcons.telegram,
                size: 100,
                color: AppTheme.greyShades.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              screen == RequestScreen.SENT
                  ? 'No sent requests'
                  : 'No received requests',
              style: AppTheme.bodyMediumLightVariant,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void showRequestDialog(Request user) {
    showGeneralDialog(
      context: GoRouter.of(context).routerDelegate.navigatorKey.currentContext!,
      barrierDismissible: true,
      useRootNavigator: false,
      routeSettings: const RouteSettings(name: 'accept_request'),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        double iconSize = 100;
        return Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: (MediaQuery.of(context).size.width * 0.75).clamp(250, 290),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 250 - iconSize / 2,
                    padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: iconSize / 2 + 10,
                        bottom: 10),
                    margin: EdgeInsets.only(top: iconSize / 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.receiver.name,
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'has requested to start a chat. Do you want to accept?',
                          style: AppTheme.bodyMediumLightVariant,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<RequestBloc>().add(
                                      RequestEvent.acceptRequest(
                                        user.receiver.id,
                                      ),
                                    );
                                Navigator.of(buildContext).pop();
                              },
                              child: const Text('Accept'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(buildContext).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: iconSize,
                    width: iconSize,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.greyShades.shade300,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          user.receiver.photoUrl,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }
}

class RequestWidget extends StatelessWidget {
  final Request user;
  final bool isSent;
  final bool isRejected;
  final RequestScreen type;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  const RequestWidget({
    super.key,
    required this.user,
    required this.isSent,
    required this.type,
    this.isRejected = false,
    this.onReject,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    double verticalPadding = 8;
    double horizontalMargin = 16;
    double horizontalPadding = 10;
    double imageSize = 80 - 2 * verticalPadding;
    double gap = 10;
    return IgnorePointer(
      ignoring: isRejected,
      child: Opacity(
        opacity: isRejected ? 0.5 : 1,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: 8,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.greyShades.shade400,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 80,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.greyShades.shade300,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          isSent
                              ? user.sender.photoUrl
                              : user.receiver.photoUrl,
                        ),
                      ),
                    ),
                    height: imageSize,
                    width: imageSize,
                  ),
                  SizedBox(width: gap),
                  Flexible(
                    child: SizedBox(
                      height: imageSize,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            isSent ? user.sender.name : user.receiver.name,
                          ),
                          Flexible(
                            child: Text(
                              user.sentAt.toLongUIDateTime(),
                              style: AppTheme.labelMediumLightVariant,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (type == RequestScreen.SENT)
                            GestureDetector(
                              child: Container(
                                width: (MediaQuery.of(context).size.width -
                                    2 * horizontalMargin -
                                    2 * horizontalPadding -
                                    imageSize -
                                    gap),
                                decoration: BoxDecoration(
                                  color: user.isBanned
                                      ? AppTheme.errorColor.withOpacity(0.1)
                                      : user.isAccepted
                                          ? AppTheme.success.withOpacity(0.1)
                                          : AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: user.isAccepted || user.isBanned
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            user.isBanned
                                                ? FontAwesomeIcons.ban
                                                : FontAwesomeIcons.check,
                                            color: user.isBanned
                                                ? AppTheme.errorColor
                                                : AppTheme.success,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            user.isBanned
                                                ? 'Rejected'
                                                : 'Accepted',
                                            style: AppTheme.labelSmall.copyWith(
                                              color: user.isBanned
                                                  ? AppTheme.errorColor
                                                  : AppTheme.success,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Sent',
                                        style: AppTheme.labelSmall.copyWith(
                                          color: AppTheme.primary,
                                        ),
                                      ),
                              ),
                            )
                          else
                            user.isAccepted || user.isBanned
                                ? Container(
                                    width: (MediaQuery.of(context).size.width -
                                        2 * horizontalMargin -
                                        2 * horizontalPadding -
                                        imageSize -
                                        gap),
                                    decoration: BoxDecoration(
                                      color: user.isBanned
                                          ? AppTheme.errorColor.withOpacity(0.1)
                                          : AppTheme.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          user.isBanned
                                              ? FontAwesomeIcons.ban
                                              : FontAwesomeIcons.check,
                                          color: user.isBanned
                                              ? AppTheme.errorColor
                                              : AppTheme.success,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          user.isBanned
                                              ? 'Rejected'
                                              : 'Accepted',
                                          style: AppTheme.labelSmall.copyWith(
                                            color: user.isBanned
                                                ? AppTheme.errorColor
                                                : AppTheme.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      InkWell(
                                        onTap: onAccept,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3,
                                          ),
                                          width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      2 * horizontalMargin -
                                                      2 * horizontalPadding -
                                                      imageSize -
                                                      gap) /
                                                  2 -
                                              gap / 2,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Accept',
                                            style: AppTheme.labelSmall.copyWith(
                                                color: AppTheme.surface),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: gap),
                                      InkWell(
                                        onTap: onReject,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3,
                                          ),
                                          width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      2 * horizontalMargin -
                                                      2 * horizontalPadding -
                                                      imageSize -
                                                      gap) /
                                                  2 -
                                              gap / 2,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Reject',
                                            style: AppTheme.labelSmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
