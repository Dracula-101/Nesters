// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/location/city_info.dart';
import 'package:nesters/domain/models/location/location_city.dart';
import 'package:nesters/domain/models/location/location_state.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class PersonalInformationPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(PersonType, String String, LocationCity, LocationState, String)
      onSubmit;
  const PersonalInformationPage(
      {super.key, required this.formKey, required this.onSubmit});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  // personType
  // primaryLang
  // otherLang
  // city
  // state
  // bio
  CityInfo? userCityInfo;
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final TextEditingController personTypeController = TextEditingController();
  final TextEditingController primaryLangController = TextEditingController();
  final TextEditingController otherLangController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final ValueNotifier<int> maxLines = ValueNotifier<int>(1);

  @override
  void initState() {
    super.initState();
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

  // Stream<List<LocationCity>> getCities(String searchQuery) {
  //   return userRepository.getCites(searchQuery);
  // }

  // Future<List<LocationState>> getStates(String? searchQuery) async {
  //   return await userRepository.getIndianStates(searchQuery);
  // }

  Future<List<Language>> getLanguages(String? searchQuery) async {
    return await userRepository.getLanguage(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            _buildPersonTypeField(),
            _buildSpacing(),
            _buildPrimaryLangField(),
            _buildSpacing(),
            _buildOtherLangField(),
            _buildSpacing(),
            _buildBioField(),
          ],
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
      onEditingComplete: () {
        context.read<FormCubit>().checkFirstStage(
              personType: personTypeController.text,
              primaryLang: primaryLangController.text,
              secondaryLang: otherLangController.text,
              bio: bioController.text,
            );
      },
    );
  }

  Widget _buildPrimaryLangField() {
    return CustomSearchableDropDownField(
      controller: primaryLangController,
      hintText: 'Primate Langauge',
      labelText: 'Primary Language',
      prefixIcon: const Icon(
        Icons.language,
      ),
      itemAsString: (language) => language.name,
      asyncItems: getLanguages,
      filterFn: (state, searchQuery) {
        return (state as Language)
            .name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      },
      itemBuilder: (context, state, isSelected) {
        return ListTile(
          title: Text(state.name),
        );
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a language';
        }
        return null;
      },
      onEditingComplete: () {
        context.read<FormCubit>().checkFirstStage(
              personType: personTypeController.text,
              primaryLang: primaryLangController.text,
              secondaryLang: otherLangController.text,
              bio: bioController.text,
            );
      },
    );
  }

  Widget _buildOtherLangField() {
    return CustomSearchableDropDownField(
      controller: otherLangController,
      hintText: 'Other Language',
      labelText: 'Other Language',
      prefixIcon: const Icon(
        Icons.language,
      ),
      itemAsString: (language) => language.name,
      asyncItems: getLanguages,
      filterFn: (state, searchQuery) {
        return (state as Language)
            .name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      },
      itemBuilder: (context, state, isSelected) {
        return ListTile(
          title: Text(state.name),
        );
      },
      onEditingComplete: () {
        context.read<FormCubit>().checkFirstStage(
              personType: personTypeController.text,
              primaryLang: primaryLangController.text,
              secondaryLang: otherLangController.text,
              bio: bioController.text,
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
          onFieldSaved: () {
            context.read<FormCubit>().checkFirstStage(
                  personType: personTypeController.text,
                  primaryLang: primaryLangController.text,
                  secondaryLang: otherLangController.text,
                  bio: bioController.text,
                );
          },
          alignLabelWithHint: true,
          maxLines: 5,
        );
      },
    );
  }
}
