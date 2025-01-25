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
          data: (sublets, marketplace, view) =>
              (sublets.isEmpty && marketplace.isEmpty)
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
                              action: Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.greyShades.shade500
                                            .withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    child: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                    onTap: () {
                                      GoRouter.of(context).pushReplacement(
                                        "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.sublet}/${AppRouterService.sublettingForm}",
                                        extra: post,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          PostView.marketplace => MarketplaceModelWidget(
                              marketplace: post as MarketplaceModel,
                              onPressed: () {},
                              action: Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.greyShades.shade500
                                            .withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    child: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                    onTap: () {
                                      GoRouter.of(context).pushReplacement(
                                        "${AppRouterService.homeScreen}/${AppRouterService.settings}/${AppRouterService.userPosts}/${PostView.marketplace}/${AppRouterService.marketplaceForm}",
                                        extra: post,
                                      );
                                    },
                                  ),
                                ),
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
