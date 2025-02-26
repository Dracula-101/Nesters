// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

import 'background_info_view.dart';
import 'lifestyle_info_view.dart';
import 'personal_info_view.dart';

class UserProfileAdvanceForm extends StatefulWidget {
  const UserProfileAdvanceForm({super.key});

  @override
  State<UserProfileAdvanceForm> createState() => _UserProfileAdvanceFormState();
}

class _UserProfileAdvanceFormState extends State<UserProfileAdvanceForm> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormCubit(),
      child: const Scaffold(
        body: SafeArea(child: AdvancedFormViewPage()),
      ),
    );
  }
}

class AdvancedFormViewPage extends StatefulWidget {
  const AdvancedFormViewPage({super.key});

  @override
  State<AdvancedFormViewPage> createState() => _AdvancedFormViewPageState();
}

class _AdvancedFormViewPageState extends State<AdvancedFormViewPage>
    with SingleTickerProviderStateMixin {
  FormPage _currentPage = FormPage.PERSONAL_INFO;
  final GlobalKey<FormState> _personalInfoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _lifeStyleInfoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _backgroundInfoKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormCubit, CurrentFormState>(
      listener: (context, state) {
        if (state.validationState.isLoading) {
          switch (_currentPage) {
            case FormPage.PERSONAL_INFO:
              if (_personalInfoKey.currentState?.validate() == true) {
                goToPage(FormPage.LIFESTYLE_INFO);
              } else {
                context.showErrorSnackBar('Please fill all fields');
              }
              break;
            case FormPage.LIFESTYLE_INFO:
              if (_lifeStyleInfoKey.currentState?.validate() == true) {
                goToPage(FormPage.BACKGROUND_INFO);
                context.read<FormCubit>().confirmPage(1);
              } else {
                context.showErrorSnackBar('Please fill all fields');
              }
              break;
            case FormPage.BACKGROUND_INFO:
              if (_backgroundInfoKey.currentState?.validate() == true) {
                context.read<FormCubit>().confirmPage(2);
              } else {
                context.showErrorSnackBar('Please fill all fields');
              }
              break;
            default:
              break;
          }
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderText(),
            _buildSpacing(20),
            _buildPageViewContent(),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  void goToPage(FormPage page) {
    context.read<FormCubit>().confirmPage(
          switch (page) {
            FormPage.PERSONAL_INFO => 0,
            FormPage.LIFESTYLE_INFO => 1,
            FormPage.BACKGROUND_INFO => 2,
          },
        );
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildSpacing(double height) {
    return SizedBox(height: height);
  }

  Widget _buildHeaderText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                switch (_currentPage) {
                  FormPage.PERSONAL_INFO => "Personal Information",
                  FormPage.LIFESTYLE_INFO => "LifeStyle Information",
                  FormPage.BACKGROUND_INFO => "Background Information",
                },
                style: AppTheme.headlineVerySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  SizedBox(
                    width: AppTheme.bodyLarge.fontSize! * 4,
                    height: AppTheme.bodyLarge.fontSize! * 4,
                    child: CircularProgressIndicator(
                      value: 1,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.surface),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  SizedBox(
                    width: AppTheme.bodyLarge.fontSize! * 4,
                    height: AppTheme.bodyLarge.fontSize! * 4,
                    child: CircularProgressIndicator(
                      value: switch (_currentPage) {
                        FormPage.PERSONAL_INFO => 0.33,
                        FormPage.LIFESTYLE_INFO => 0.66,
                        FormPage.BACKGROUND_INFO => 1,
                      },
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  BlocBuilder<FormCubit, CurrentFormState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: AppTheme.bodyLarge.fontSize! * 4,
                        child: Text(
                          switch (_currentPage) {
                            FormPage.PERSONAL_INFO => "1/3",
                            FormPage.LIFESTYLE_INFO => "2/3",
                            FormPage.BACKGROUND_INFO => "3/3",
                          },
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPageViewContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.675,
      child: BlocBuilder<FormCubit, CurrentFormState>(
        builder: (context, state) {
          return IndexedStack(
            index: switch (_currentPage) {
              FormPage.PERSONAL_INFO => 0,
              FormPage.LIFESTYLE_INFO => 1,
              FormPage.BACKGROUND_INFO => 2,
            },
            children: [
              PersonalInformationPage(
                formKey: _personalInfoKey,
                currentFormState: state,
              ),
              LifeStyleInfoPage(
                formKey: _lifeStyleInfoKey,
                currentFormState: state,
              ),
              BackgroundInfoPage(
                formKey: _backgroundInfoKey,
                currentFormState: state,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return const SubmitButton();
  }
}

enum FormPage {
  PERSONAL_INFO,
  LIFESTYLE_INFO,
  BACKGROUND_INFO,
}

class SubmitButton extends StatefulWidget {
  const SubmitButton({super.key});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormCubit, CurrentFormState>(
      listener: (context, state) {
        if (state.submitState.exception != null) {
          context.showErrorSnackBar(
              state.submitState.exception?.message ?? "Error occurred");
        }
        if (state.submitState.isSuccess) {
          context.showSuccessSnackBar("Profile completed successfully");
          if (mounted) {
            Future.delayed(const Duration(seconds: 1), () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              }
            });
          }
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.read<FormCubit>().validatePage();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                state.submitState.isLoading
                    ? SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          color: AppTheme.surface,
                          strokeWidth: 1.5,
                        ),
                      )
                    : const SizedBox(width: 0),
                if (state.submitState.isLoading) const SizedBox(width: 10),
                Text(
                  'Next',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.surface.withOpacity(
                      state.submitState.isLoading ? 0.5 : 1,
                    ),
                    fontWeight: FontWeight.w600,
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
