import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/apartment/list/view/components/apartment_list_widget.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_list_widget.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class UserFavouritePostPage extends StatefulWidget {
  const UserFavouritePostPage({super.key});

  @override
  State<UserFavouritePostPage> createState() => _UserFavouritePostPageState();
}

class _UserFavouritePostPageState extends State<UserFavouritePostPage> {
  SelectedUserFavouritePost selectedUserFavouritePost =
      SelectedUserFavouritePost.sublet;

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final ApartmentRepository _apartmentRepository =
      GetIt.I<ApartmentRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  List<MarketplaceModel>? favouriteMarketplacePosts;
  List<SubletModel>? favouriteSubletPosts;
  List<ApartmentModel>? favouriteApartmentPosts;
  bool isLoading = true;
  AppException? error;

  @override
  void initState() {
    super.initState();
    getFavouritePosts();
  }

  Future<void> getFavouritePosts() async {
    try {
      final userId = _authRepository.currentUser!.id;
      await Future.wait([
        _marketplaceRepository.getUserLikedMarketplaces(userId: userId),
        _subletRepository.getUserLikedSublets(userId: userId),
        _apartmentRepository.getUserLikedApartments(userId: userId),
      ]).then((value) {
        favouriteMarketplacePosts = value[0] as List<MarketplaceModel>;
        favouriteSubletPosts = value[1] as List<SubletModel>;
        favouriteApartmentPosts = value[2] as List<ApartmentModel>;
      });
    } on AppException catch (e, s) {
      error = e;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int getItemCount(SelectedUserFavouritePost selectedUserFavouritePost) {
    switch (selectedUserFavouritePost) {
      case SelectedUserFavouritePost.sublet:
        return favouriteSubletPosts!.length;
      case SelectedUserFavouritePost.marketplace:
        return favouriteMarketplacePosts!.length;
      case SelectedUserFavouritePost.apartment:
        return favouriteApartmentPosts!.length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (selectedUserFavouritePost) {
            SelectedUserFavouritePost.sublet => "Liked Sublet",
            SelectedUserFavouritePost.apartment => "Liked Apartment",
            SelectedUserFavouritePost.marketplace => "Liked Marketplace",
          },
        ),
        actions: [
          PopupMenuButton<SelectedUserFavouritePost>(
            onSelected: (SelectedUserFavouritePost result) {
              setState(() {
                selectedUserFavouritePost = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SelectedUserFavouritePost>>[
              const PopupMenuItem<SelectedUserFavouritePost>(
                value: SelectedUserFavouritePost.sublet,
                child: Text('Sublets'),
              ),
              const PopupMenuItem<SelectedUserFavouritePost>(
                value: SelectedUserFavouritePost.apartment,
                child: Text('Apartments'),
              ),
              const PopupMenuItem<SelectedUserFavouritePost>(
                value: SelectedUserFavouritePost.marketplace,
                child: Text('Marketplace'),
              ),
            ],
          ),
        ],
      ),
      body: error != null
          ? _buildErrorWidget()
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : ((favouriteMarketplacePosts?.isEmpty ?? true) &&
                      (favouriteSubletPosts?.isEmpty ?? true) &&
                      (favouriteApartmentPosts?.isEmpty ?? true))
                  ? const ShowNoInfoWidget(
                      title: "No Liked Posts",
                      subtitle: "You have not liked any posts yet",
                    )
                  : getCurrentScreenList().isEmpty
                      ? ShowNoInfoWidget(
                          title: "No Liked Posts",
                          subtitle:
                              "You have not liked any posts yet in ${selectedUserFavouritePost.toString().split('.').last}",
                        )
                      : ListView.builder(
                          itemCount: getItemCount(selectedUserFavouritePost),
                          itemBuilder: (context, index) {
                            if (selectedUserFavouritePost ==
                                SelectedUserFavouritePost.sublet) {
                              final sublet = favouriteSubletPosts![index];
                              return SubletModelWidget(
                                sublet: sublet,
                                onPressed: () {
                                  GoRouter.of(context).go(
                                    "${AppRouterService.homeScreen}/${AppRouterService.subletDetail}",
                                    extra: sublet,
                                  );
                                },
                                action: Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog.adaptive(
                                          title: const Text("Are you sure?"),
                                          content: const Text(
                                              "Do you want to remove this post from your liked posts?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _subletRepository
                                                    .updateLikeStatus(
                                                  subletId: sublet.id,
                                                  userId: _authRepository
                                                      .currentUser!.id,
                                                  isLiked: false,
                                                )
                                                    .then((value) {
                                                  Navigator.pop(ctx);
                                                  context.showSuccessSnackBar(
                                                      "Post removed from liked posts");
                                                  setState(() {
                                                    favouriteSubletPosts!
                                                        .removeAt(index);
                                                  });
                                                  getFavouritePosts();
                                                });
                                              },
                                              child: const Text("Remove"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.error,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: AppTheme.onError,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else if (selectedUserFavouritePost ==
                                SelectedUserFavouritePost.apartment) {
                              final apartment = favouriteApartmentPosts![index];
                              return ApartmentModelWidget(
                                apartment: apartment,
                                onPressed: () {
                                  GoRouter.of(context).go(
                                    "${AppRouterService.homeScreen}/${AppRouterService.apartmentDetail}",
                                    extra: apartment,
                                  );
                                },
                                action: Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog.adaptive(
                                          title: const Text("Are You Sure?"),
                                          content: const Text(
                                            "Do You Want To Remove This Post From Uour Favorites?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _apartmentRepository
                                                    .updateLikeStatus(
                                                  apartmentId: apartment.id,
                                                  userId: _authRepository
                                                      .currentUser!.id,
                                                  isLiked: false,
                                                )
                                                    .then((value) {
                                                  Navigator.pop(ctx);
                                                  context.showSuccessSnackBar(
                                                      "Post Removed From Favorites");
                                                  setState(() {
                                                    favouriteApartmentPosts!
                                                        .removeAt(index);
                                                  });
                                                  getFavouritePosts();
                                                });
                                              },
                                              child: const Text("Remove"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.error,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: AppTheme.onError,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              final marketplace =
                                  favouriteMarketplacePosts![index];
                              return MarketplaceModelWidget(
                                marketplace: marketplace,
                                onPressed: () {
                                  GoRouter.of(context).go(
                                    "${AppRouterService.homeScreen}/${AppRouterService.marketplaceDetail}",
                                    extra: marketplace,
                                  );
                                },
                                action: Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog.adaptive(
                                          title: const Text("Are you sure?"),
                                          content: const Text(
                                              "Do you want to remove this post from your liked posts?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _marketplaceRepository
                                                    .updateLikeStatus(
                                                  itemId: marketplace.id,
                                                  userId: _authRepository
                                                      .currentUser!.id,
                                                  isLiked: false,
                                                )
                                                    .then((value) {
                                                  Navigator.pop(ctx);
                                                  context.showSuccessSnackBar(
                                                      "Post removed from liked posts");
                                                  setState(() {
                                                    favouriteMarketplacePosts!
                                                        .removeAt(index);
                                                  });
                                                  getFavouritePosts();
                                                });
                                              },
                                              child: const Text("Remove"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.error,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: AppTheme.onError,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
    );
  }

  List getCurrentScreenList() {
    switch (selectedUserFavouritePost) {
      case SelectedUserFavouritePost.sublet:
        return favouriteSubletPosts ?? [];
      case SelectedUserFavouritePost.marketplace:
        return favouriteMarketplacePosts ?? [];
      case SelectedUserFavouritePost.apartment:
        return favouriteApartmentPosts ?? [];
      default:
        return [];
    }
  }

  Widget _buildErrorWidget() {
    return ShowErrorWidget(
      error: error!,
      onRetry: () {
        setState(() {
          isLoading = true;
          error = null;
        });
        getFavouritePosts();
      },
    );
  }
}

enum SelectedUserFavouritePost {
  sublet,
  marketplace,
  apartment,
}
