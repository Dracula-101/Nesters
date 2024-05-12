// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/city.dart';
import 'package:nesters/domain/models/indian_state.dart';
import 'package:nesters/domain/models/person_type.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class PersonalInformationPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(PersonType, String String, City, IndianState, String) onSubmit;
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
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final TextEditingController personTypeController = TextEditingController();
  final TextEditingController primaryLangController = TextEditingController();
  final TextEditingController otherLangController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
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
    cityController.dispose();
    stateController.dispose();
    bioController.dispose();
    maxLines.dispose();
    super.dispose();
  }

  Future<List<City>> getCities(String searchQuery) async {
    return userRepository.getCites(searchQuery).then((value) {
      GetIt.I<AppLoggerService>().debug(value);
      return value;
    });
  }

  Future<List<IndianState>> getStates(String? searchQuery) async {
    return await userRepository.getIndianStates(searchQuery).then((value) {
      GetIt.I<AppLoggerService>().debug('value: $value');
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          _buildPersonTypeField(),
          _buildSpacing(),
          _buildPrimaryLangField(),
          _buildSpacing(),
          _buildOtherLangField(),
          _buildSpacing(),
          _buildCityField(),
          _buildSpacing(),
          _buildStateField(),
          _buildSpacing(),
          _buildBioField(),
        ],
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

  Widget _buildPrimaryLangField() {
    return CustomBottomSheetDropdownField(
      controller: primaryLangController,
      hintText: 'Primary Language',
      labelText: 'Primary Language',
      prefixIcon: const Icon(
        Icons.language,
      ),
      items: PersonType.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a primary language';
        }
        return null;
      },
    );
  }

  Widget _buildOtherLangField() {
    return CustomBottomSheetDropdownField(
      controller: otherLangController,
      hintText: 'Other Language',
      labelText: 'Other Language',
      prefixIcon: const Icon(
        Icons.language,
      ),
      items: PersonType.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a other language';
        }
        return null;
      },
    );
  }

  Widget _buildCityField() {
    return CustomSearchableDropDownField(
      controller: cityController,
      hintText: 'City',
      labelText: 'City',
      prefixIcon: const Icon(
        Icons.location_city,
      ),
      asyncItems: getCities,
      filterFn: (city, searchQuery) {
        return (city as City)
            .name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      } as bool Function(dynamic, String),
      itemBuilder: (context, city, isSelected) {
        return ListTile(
          title: Text(city.name),
        );
      } as ListTile Function(BuildContext, dynamic, bool),
      validator: (value) {
        if (value == null) {
          return 'Please select a city';
        }
        return null;
      },
    );
  }

  Widget _buildStateField() {
    return CustomSearchableDropDownField<IndianState>(
      controller: stateController,
      hintText: 'State',
      labelText: 'State',
      prefixIcon: const Icon(
        Icons.location_city,
      ),
      asyncItems: getStates,
      filterFn: (state, searchQuery) {
        return (state as IndianState)
            .name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      } as bool Function(dynamic, String),
      itemBuilder: (context, state, isSelected) {
        return ListTile(
          title: Text(state.name),
        );
      } as ListTile Function(BuildContext, dynamic, bool),
      validator: (value) {
        if (value == null) {
          return 'Please select a state';
        }
        return null;
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
