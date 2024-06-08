import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/theme/theme.dart';

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
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: SubmitButton(),
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
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final GlobalKey<FormState> _personalInfoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _lifeStyleInfoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _backgroundInfoKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageControllerHandler);
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageControllerHandler);
    _pageController.dispose();
    super.dispose();
  }

  void _pageControllerHandler() {
    final currentPage = _pageController.page?.round();
    if (currentPage != _currentPage.value) {
      _currentPage.value = currentPage ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderText(),
          _buildSpacing(20),
          _buildPageViewContent(),
        ],
      ),
    );
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
                child: ValueListenableBuilder(
                  valueListenable: _currentPage,
                  builder: (context, value, child) {
                    return Text(
                      value == 0
                          ? 'Personal Information'
                          : value == 1
                              ? 'Lifestyle and Hobbies'
                              : 'Background and Interests',
                      style: AppTheme.headlineVerySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: BlocBuilder<FormCubit, CurrentFormState>(
                  builder: (context, state) {
                    return Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        SizedBox(
                          width: AppTheme.bodyLarge.fontSize! * 4,
                          height: AppTheme.bodyLarge.fontSize! * 4,
                          child: CircularProgressIndicator(
                            value: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryShades.shade200),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        BlocBuilder<FormCubit, CurrentFormState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: AppTheme.bodyLarge.fontSize! * 4,
                              height: AppTheme.bodyLarge.fontSize! * 4,
                              child: CircularProgressIndicator(
                                value: state.questionsComplete / 17,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.surface,
                                ),
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                              ),
                            );
                          },
                        ),
                        BlocBuilder<FormCubit, CurrentFormState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: AppTheme.bodyLarge.fontSize! * 4,
                              child: Text(
                                '${state.questionsComplete}%',
                                style: AppTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildPageViewContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.3,
      child: PageView(
        controller: _pageController,
        children: [
          PersonalInformationPage(
            formKey: _personalInfoKey,
            onSubmit: (p0, p1, p2, p3, p4) {},
          ),
          LifeStyleInfoPage(
            formKey: _lifeStyleInfoKey,
            onContinue: () {},
            onSaved: (p0, p1, p2, p3, p4, p5) {},
          ),
          BackgroundInfoPage(
            formKey: _backgroundInfoKey,
          ),
        ],
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  const SubmitButton({super.key});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Next',
        style: AppTheme.titleLarge.copyWith(
          color: AppTheme.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
