import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              GoRouter.of(context).canPop() ? GoRouter.of(context).pop() : null;
            },
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

class _ChatHomeViewState extends State<ChatHomeView> {
  final ObxStorageRepository _obxStorageRepository =
      GetIt.I<ObxStorageRepository>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _obxStorageRepository.getChatUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
            ),
          );
        }
        List<QuickChatUser> items = snapshot.data as List<QuickChatUser>;

        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ListTile(
                    onTap: () {
                      log('ChatId: ${items[index].chatId}');
                      log('User: ${items[index].toUser()}');
                      GoRouter.of(context).go(
                        '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/${items[index].chatId}',
                        extra: items[index].toUser(),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        items[index].photoUrl ?? '',
                      ),
                    ),
                    title: Text(
                      items[index].fullName ?? '',
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
