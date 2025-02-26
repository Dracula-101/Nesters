import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/apartment/list/view/components/apartment_list_widget.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/features/user/posts/cubit/user_post_cubit.dart';
import 'package:nesters/features/user/posts/cubit/user_post_state.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

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
              PostView.apartment => "Apartments",
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
          error: (error) => ShowErrorWidget(
            error: error,
            onRetry: () {
              switch (state.postView) {
                case PostView.sublet:
                  context.read<UserPostCubit>().fetchSubletUserPosts();
                case PostView.marketplace:
                  context.read<UserPostCubit>().fetchMarketplaceUserPosts();
                case PostView.apartment:
                  context.read<UserPostCubit>().fetchApartmentUserPosts();
              }
            },
          ),
          data: (sublets, marketplace, apartments, view) => (sublets.isEmpty &&
                  marketplace.isEmpty &&
                  apartments.isEmpty)
              ? const ShowNoInfoWidget(
                  title: "No Posts Found",
                  subtitle: "Try adding a new post and check back later.",
                )
              : ListView.builder(
                  itemCount: (view) {
                    switch (view) {
                      case PostView.sublet:
                        return sublets.length;
                      case PostView.marketplace:
                        return marketplace.length;
                      case PostView.apartment:
                        return apartments.length;
                      default:
                        return 0;
                    }
                  }(view),
                  itemBuilder: (context, index) {
                    final post = switch (view) {
                      PostView.sublet => sublets[index],
                      PostView.marketplace => marketplace[index],
                      PostView.apartment => apartments[index],
                    };

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
                                  return AlertDialog.adaptive(
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
                                  return AlertDialog.adaptive(
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
                                            Flexible(
                                              child: Text(
                                                'This action cannot be undone.',
                                                style: AppTheme.bodyMedium
                                                    .copyWith(
                                                  color: AppTheme.error,
                                                ),
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
                      PostView.apartment => ApartmentModelWidget(
                          apartment: post as ApartmentModel,
                          action: const SizedBox(),
                          bottom: ActionBar(
                            onEdit: () {
                              GoRouter.of(context).pushReplacement(
                                "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.apartment}/${AppRouterService.apartmentForm}",
                                extra: post,
                              );
                            },
                            isHidden: !(post.isAvailable ?? true),
                            onHideChange: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog.adaptive(
                                    title: Text(
                                      post.isAvailable ?? true
                                          ? "Hide Apartment"
                                          : "Show Apartment",
                                      style: AppTheme.titleLarge,
                                    ),
                                    content: Text(
                                      post.isAvailable ?? true
                                          ? "Are you sure you want to hide this apartment?"
                                          : "Are you sure you want to show this apartment?",
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
                                              .changeApartmentVisibility(
                                                isVisible:
                                                    !(post.isAvailable ?? true),
                                                apartmentId: post.id.toString(),
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
                                  return AlertDialog.adaptive(
                                    title: Text(
                                      "Delete Apartment",
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
                                              .deleteApartment(
                                                apartmentId: post.id.toString(),
                                              );
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          "Delete",
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.primary,
                                          ),
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
                                  return AlertDialog.adaptive(
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
                                  return AlertDialog.adaptive(
                                    actionsPadding: const EdgeInsets.only(
                                        right: 8, bottom: 8),
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
                                            Flexible(
                                              child: Text(
                                                'This action cannot be undone.',
                                                style: AppTheme.bodyMedium
                                                    .copyWith(
                                                  color: AppTheme.error,
                                                ),
                                              ),
                                            )
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
                      // TODO: Handle this case.
                      Object() => null,
                    };
                  },
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
