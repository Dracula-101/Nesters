import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/features/user/posts/cubit/user_post_cubit.dart';
import 'package:nesters/features/user/posts/cubit/user_post_state.dart';
import 'package:nesters/theme/theme.dart';

class UserPostScreen extends StatelessWidget {
  final PostView view;
  const UserPostScreen({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPostCubit(postView: view),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Text(
            switch (view) {
              PostView.sublet => "Sublets",
              PostView.marketplace => "Marketplace",
            },
            style: AppTheme.titleLarge,
          ),
        ),
        body: UserPostView(
          view: view,
        ),
      ),
    );
  }
}

class UserPostView extends StatefulWidget {
  final PostView view;
  const UserPostView({super.key, required this.view});

  @override
  State<UserPostView> createState() => _UserPostViewState();
}

class _UserPostViewState extends State<UserPostView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPostCubit, UserPostState>(
      builder: (context, state) {
        return state.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          data: (sublets, marketplace, view) => (sublets.isEmpty &&
                  marketplace.isEmpty)
              ? Center(
                  child: Text(
                    "No ${view == PostView.sublet ? "sublets" : "marketplace"} posts found",
                    style: AppTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: view == PostView.sublet
                      ? sublets.length
                      : marketplace.length,
                  itemBuilder: (context, index) {
                    final post = view == PostView.sublet
                        ? sublets[index]
                        : marketplace[index];
                    return switch (view) {
                      PostView.sublet => SubletModelWidget(
                          sublet: post as SubletModel,
                          action: const SizedBox(),
                          bottom: ActionBar(
                            onEdit: () {
                              GoRouter.of(context).pushReplacement(
                                "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.sublet}/${AppRouterService.sublettingForm}",
                                extra: post,
                              );
                            },
                            isHidden: !(post.isAvailable ?? true),
                            onHideChange: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      post.isAvailable ?? true
                                          ? "Hide Sublet"
                                          : "Show Sublet",
                                      style: AppTheme.titleLarge,
                                    ),
                                    content: Text(
                                      post.isAvailable ?? true
                                          ? "Are you sure you want to hide this sublet?"
                                          : "Are you sure you want to show this sublet?",
                                      style: AppTheme.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<UserPostCubit>()
                                              .changeSubletVisibility(
                                                isVisible:
                                                    !(post.isAvailable ?? true),
                                                subletId: post.id.toString(),
                                              );
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          post.isAvailable ?? true
                                              ? "Hide"
                                              : "Show",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      "Delete Sublet",
                                      style: AppTheme.titleLarge,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            'Are you sure you want to delete this post?'),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Icon(Icons.warning,
                                                color: AppTheme.error),
                                            const SizedBox(width: 10),
                                            Text(
                                              'This action cannot be undone.',
                                              style:
                                                  AppTheme.bodyMedium.copyWith(
                                                color: AppTheme.error,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<UserPostCubit>()
                                              .deleteSublet(
                                                subletId: post.id.toString(),
                                              );
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Delete",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      PostView.marketplace => MarketplaceModelWidget(
                          marketplace: post as MarketplaceModel,
                          onPressed: () {},
                          action: const SizedBox(),
                          bottom: ActionBar(
                            onEdit: () {
                              GoRouter.of(context).pushReplacement(
                                "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.marketplace}/${AppRouterService.marketplaceForm}",
                                extra: post,
                              );
                            },
                            isHidden: !(post.isAvailable ?? true),
                            onHideChange: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      post.isAvailable ?? true
                                          ? "Hide Item"
                                          : "Show Item",
                                      style: AppTheme.titleLarge,
                                    ),
                                    content: Text(
                                      post.isAvailable ?? true
                                          ? "Are you sure you want to hide this marketplace item?"
                                          : "Are you sure you want to show this marketplace item?",
                                      style: AppTheme.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<UserPostCubit>()
                                              .changeMarketplaceVisibility(
                                                isVisible:
                                                    !(post.isAvailable ?? true),
                                                itemId: post.id,
                                              );
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          post.isAvailable ?? true
                                              ? "Hide"
                                              : "Show",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      "Delete Item",
                                      style: AppTheme.titleLarge,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            'Are you sure you want to delete this post?'),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Icon(Icons.warning,
                                                color: AppTheme.error),
                                            const SizedBox(width: 10),
                                            Text(
                                              'This action cannot be undone.',
                                              style:
                                                  AppTheme.bodyMedium.copyWith(
                                                color: AppTheme.error,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<UserPostCubit>()
                                              .deleteMarketplace(
                                                  itemId: post.id);
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Delete",
                                          style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    };
                  },
                ),
          showError: (message) => Center(
            child: Text(message),
          ),
        );
      },
    );
  }
}

class ActionBar extends StatelessWidget {
  final VoidCallback onEdit;
  final bool isHidden;
  final VoidCallback onHideChange;
  final VoidCallback onDelete;
  const ActionBar({
    super.key,
    required this.onEdit,
    required this.isHidden,
    required this.onDelete,
    required this.onHideChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: AppTheme.greyShades.shade400,
          thickness: 1,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Edit",
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.primaryShades.shade500),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 35,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppTheme.greyShades.shade700,
                      width: 1,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: onHideChange,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHidden ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isHidden ? "Show" : "Hide",
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.primaryShades.shade500),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 35,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppTheme.greyShades.shade700,
                      width: 1,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Delete",
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.primaryShades.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
