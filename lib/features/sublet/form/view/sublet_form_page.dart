import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/sublet/apartment_size.dart';
import 'package:nesters/features/sublet/form/cubit/sublet_form_cubit.dart';
import 'package:nesters/features/sublet/form/view/sublet_background_form_page.dart';
import 'package:nesters/features/sublet/form/view/sublet_details_form_page.dart';
import 'package:nesters/features/sublet/form/view/sublet_photos_form_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletFormPage extends StatelessWidget {
  const SubletFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubletFormCubit(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Issue a Sublet'),
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(),
        body: const SafeArea(child: SubletFormView()),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubletFormCubit, SubletFormState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.read<SubletFormCubit>().validatePage();
          },
          child: Container(
            height: 60,
            margin:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Next',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.surface,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SubletFormView extends StatefulWidget {
  const SubletFormView({super.key});

  @override
  State<SubletFormView> createState() => _SubletFormViewState();
}

class _SubletFormViewState extends State<SubletFormView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 2,
      length: 3,
      vsync: this,
    );
    _tabIndexNotifier.addListener(() {
      context.read<SubletFormCubit>().onPageChange(_tabIndexNotifier.value);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _tabIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<SubletFormCubit, SubletFormState>(
      builder: (context, state) {
        return TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1 && !state.hasSecondPageAccess) {
              context.showSnackBar(
                'Please fill in the details page first',
                icon: Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: AppTheme.error,
                ),
              );
              _tabController?.animateTo(0);
              return;
            }
            if (index == 2 && !state.hasThirdPageAccess) {
              context.showSnackBar(
                'Please fill in the details first and location page second',
                icon: Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: AppTheme.error,
                ),
              );
              _tabController?.animateTo(0);
              return;
            }
            _tabIndexNotifier.value = index;
          },
          tabs: [
            const Tab(
              child: Text(
                'Details',
              ),
            ),
            Tab(
              child: Text(
                'Background',
                style: AppTheme.bodyMedium.copyWith(
                  color: _tabIndexNotifier.value == 1
                      ? AppTheme.primary
                      : state.hasSecondPageAccess
                          ? AppTheme.greyShades.shade700
                          : AppTheme.greyShades.shade400,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Photos',
                style: AppTheme.bodyMedium.copyWith(
                  color: _tabIndexNotifier.value == 2
                      ? AppTheme.primary
                      : state.hasThirdPageAccess
                          ? AppTheme.greyShades.shade700
                          : AppTheme.greyShades.shade400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabContent() {
    return Expanded(
      child: BlocBuilder<SubletFormCubit, SubletFormState>(
        builder: (context, state) {
          return TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              SubletDetailsForm(
                controller: _tabController,
              ),
              SubletBackgroundInfo(
                controller: _tabController,
              ),
              SubletPhotoForm(
                controller: _tabController,
              ),
            ],
          );
        },
      ),
    );
  }
}
