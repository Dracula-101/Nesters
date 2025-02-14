// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class PersonalInformationPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final CurrentFormState currentFormState;
  const PersonalInformationPage({
    super.key,
    required this.formKey,
    required this.currentFormState,
  });

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final TextEditingController personTypeController = TextEditingController();
  final TextEditingController primaryLangController = TextEditingController();
  final TextEditingController otherLangController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final ValueNotifier<int> maxLines = ValueNotifier<int>(1);

  @override
  void initState() {
    super.initState();
    if (widget.currentFormState.userFormProfile.personType != null) {
      personTypeController.text =
          widget.currentFormState.userFormProfile.personType!.name;
    }
    if (widget.currentFormState.userFormProfile.primaryLang != null) {
      primaryLangController.text =
          widget.currentFormState.userFormProfile.primaryLang!;
    }
    if (widget.currentFormState.userFormProfile.secondaryLang != null) {
      otherLangController.text =
          widget.currentFormState.userFormProfile.secondaryLang!;
    }
    if (widget.currentFormState.userFormProfile.bio != null) {
      bioController.text = widget.currentFormState.userFormProfile.bio!;
    }
    if (bioController.text.isNotEmpty) {
      int expectedLines = (bioController.text.length / 25).ceil();
      maxLines.value = expectedLines;
    }
  }

  @override
  void dispose() {
    personTypeController.dispose();
    primaryLangController.dispose();
    otherLangController.dispose();
    bioController.dispose();
    maxLines.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: widget.formKey,
        child: BlocConsumer<FormCubit, CurrentFormState>(
          listener: (context, state) {
            if (state.validationState.isLoading) {
              context.read<FormCubit>().addData(
                    personType: personTypeController.text,
                    primaryLang: primaryLangController.text,
                    secondaryLang: otherLangController.text,
                    bio: bioController.text,
                  );
            }
          },
          builder: (context, state) {
            return BlocBuilder<AppBloc, AppState>(builder: (context, appState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPersonTypeField(),
                    _buildSpacing(),
                    _buildPrimaryLangField(appState.languages),
                    _buildSpacing(),
                    _buildOtherLangField(appState.languages),
                    _buildSpacing(),
                    _buildBioField(),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildSpacing() {
    return const SizedBox(height: 20);
  }

  Widget _buildPersonTypeField() {
    return CustomBottomSheetDropdownField(
      controller: personTypeController,
      hintText: 'Person Type',
      labelText: 'Person Type',
      prefixIcon: const Icon(
        Icons.person,
      ),
      items: PersonType.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a person type';
        }
        return null;
      },
    );
  }

  Widget _buildPrimaryLangField(List<Language> languages) {
    return CustomDynamicSearchableDropDropField(
      controller: primaryLangController,
      hintText: 'Primate Langauge',
      labelText: 'Primary Language',
      prefixIcon: const Icon(
        Icons.language,
      ),
      itemAsString: (language) => language.name,
      itemBuilder: (context, language) {
        return ListTile(
          title: Text(language.name),
          subtitle: Text(language.nativeName),
          dense: true,
        );
      },
      asyncStaticItems: userRepository.getLanguages(),
      validator: (value) {
        if (value == null) {
          return 'Please select a language';
        }
        return null;
      },
      emptyBuilder: (context) {
        return ShowInfoWidget(
          icon: Icons.language,
          message: primaryLangController.text.isEmpty
              ? 'Search'
              : 'No language found',
          subtitle: primaryLangController.text.isEmpty
              ? 'Search for a language'
              : 'No language found for the search query ${primaryLangController.text}',
        );
      },
    );
  }

  Widget _buildOtherLangField(List<Language> languages) {
    return CustomDynamicSearchableDropDropField(
      controller: otherLangController,
      hintText: 'Other Language',
      labelText: 'Other Language',
      prefixIcon: const Icon(
        Icons.language,
      ),
      itemAsString: (language) => language.name,
      itemBuilder: (context, language) {
        return ListTile(
          title: Text(language.name),
          subtitle: Text(language.nativeName),
          dense: true,
        );
      },
      asyncStaticItems: userRepository.getLanguages(),
      emptyBuilder: (context) {
        return ShowInfoWidget(
          icon: Icons.language,
          message: primaryLangController.text.isEmpty
              ? 'Search'
              : 'No language found',
          subtitle: primaryLangController.text.isEmpty
              ? 'Search for a language'
              : 'No language found for the search query ${primaryLangController.text}',
        );
      },
    );
  }

  Widget _buildBioField() {
    return ValueListenableBuilder(
      valueListenable: maxLines,
      builder: (context, value, child) {
        return CustomTextField(
          controller: bioController,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: 'Bio',
          labelText: 'Your description',
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter a bio';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              int expectedLines = (value.length / 25).ceil();
              maxLines.value = expectedLines;
            } else {
              maxLines.value = 1;
            }
          },
          alignLabelWithHint: true,
          maxLines: 5,
        );
      },
    );
  }
}
