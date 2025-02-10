import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/form/cubit/apartment_form_cubit.dart';
import 'package:nesters/features/apartment/form/view/apartment_details_form_page.dart';
import 'package:nesters/features/apartment/form/view/apartment_photos_form_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentFormPage extends StatelessWidget {
  final ApartmentModel? apartment;
  const ApartmentFormPage({super.key, this.apartment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApartmentFormCubit(apartment: apartment),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            apartment != null ? 'Edit your Apartment' : 'Issue a Apartment',
          ),
        ),
        body: SafeArea(
          child: ApartmentFormView(
            apartment: apartment,
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final bool editPage;
  const CustomBottomNavigationBar({
    super.key,
    required this.editPage,
  });

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return BlocConsumer<ApartmentFormCubit, ApartmentFormState>(
      listener: (context, state) {
        if (state.submitState?.exception != null) {
          // log("Error: ${state.submitError}");
          context.showSnackBar(
            state.submitState!.exception!.message,
            icon: Icon(
              FontAwesomeIcons.triangleExclamation,
              color: AppTheme.error,
            ),
          );
        }
        if (state.submitState?.isSuccess ?? false) {
          Future.delayed(1.sec).then((value) {
            context.showSnackBar(
              'Apartment ${(state.isPreFilled ?? false) ? 'updated' : 'created'} successfully',
              icon: Icon(
                FontAwesomeIcons.circleCheck,
                color: AppTheme.success,
              ),
            );
            Navigator.of(context).pop();
          });
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.read<ApartmentFormCubit>().validatePage();
          },
          child: Container(
            height: 60,
            margin:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isKeyboardOpen
                  ? Border(
                      top: BorderSide(
                        color: AppTheme.greyShades.shade400,
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: DynamicProgressIndicator(
              currentValue: state.submitState?.isLoading ?? false
                  ? 1.0
                  : state.imageUploadTask?.progress ?? 1.0,
              totalValue: 1.0,
              height: 60,
              width: double.infinity,
              backgroundColor: AppTheme.primaryShades.shade300,
              progressColor: AppTheme.primaryShades.shade600,
              child: Text(
                state.submitState?.isSuccess ?? false
                    ? (state.isPreFilled ?? false)
                        ? 'Updated'
                        : 'Submitted'
                    : state.imageUploadTask != null
                        ? 'Uploading ${((state.imageUploadTask?.progress ?? 0.01) * 100).toInt()}%'
                        : editPage
                            ? 'Update'
                            : state.pageNumber == 2
                                ? 'Submit'
                                : 'Next',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.surface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ApartmentFormView extends StatefulWidget {
  final ApartmentModel? apartment;
  const ApartmentFormView({
    super.key,
    required this.apartment,
  });

  @override
  State<ApartmentFormView> createState() => _ApartmentFormViewState();
}

class _ApartmentFormViewState extends State<ApartmentFormView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _tabController?.addListener(() {
      context.read<ApartmentFormCubit>().onPageChange(_tabIndexNotifier.value);
      _tabIndexNotifier.value = _tabController?.index ?? 0;
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
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
        _buildForwardButton(),
      ],
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<ApartmentFormCubit, ApartmentFormState>(
      builder: (context, state) {
        return TabBar(
          controller: _tabController,
          isScrollable: false,
          onTap: (index) {
            if (!state.hasSecondPageAccess) {
              if ((_tabController?.index ?? 0) >= 1) {
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
            }
          },
          tabs: [
            const Tab(
              child: Text(
                'Details',
              ),
            ),
            Tab(
              child: Text(
                'Photos',
                style: AppTheme.bodyMedium.copyWith(
                  color: _tabIndexNotifier.value == 1
                      ? AppTheme.primary
                      : state.hasSecondPageAccess
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
      child: BlocBuilder<ApartmentFormCubit, ApartmentFormState>(
        builder: (context, state) {
          return TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              ApartmentDetailsForm(
                controller: _tabController,
                apartment: widget.apartment,
              ),
              ApartmentPhotoForm(
                controller: _tabController,
                apartment: widget.apartment,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForwardButton() {
    return CustomBottomNavigationBar(
      editPage: widget.apartment != null,
    );
  }
}
