import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class ChatUserWidget extends StatelessWidget {
  final QuickChatUser user;
  final Stream<Message?> lastMessage;
  final Stream<int?> newMessageCount;
  final VoidCallback? onTap;
  final bool isDeleted;
  const ChatUserWidget(
      {super.key,
      required this.user,
      this.onTap,
      required this.lastMessage,
      required this.newMessageCount,
      required this.isDeleted});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: isDeleted ? 0.7 : 1,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            isDeleted ? AppTheme.background : Colors.transparent,
            BlendMode.saturation,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.greyShades.shade300,
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CachedNetworkImage(
                          imageUrl: user.photoUrl ?? '',
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 22,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.primary,
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName.capitalizeEachWord,
                              style: AppTheme.titleMedium,
                            ),
                            StreamBuilder<Message?>(
                              stream: lastMessage,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final message = snapshot.data!;
                                  return Text(
                                    message.content?.startsWith('http') ?? false
                                        ? '📷 Image'
                                        : message.content ?? '',
                                    style: AppTheme.bodyMediumLightVariant,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<int?>(
                  stream: newMessageCount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          snapshot.data.toString(),
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.background,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.greyShades.shade500,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
