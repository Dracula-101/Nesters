import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:nesters/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
// import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileBasicForm extends StatelessWidget {
  const UserProfileBasicForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return state.maybeWhen(
              authenticated: (user) {
                return UserProfileBasicFormView(user: user);
              },
              orElse: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class UserProfileBasicFormView extends StatefulWidget {
  final User user;
  const UserProfileBasicFormView({super.key, required this.user});

  @override
  State<UserProfileBasicFormView> createState() =>
      _UserProfileBasicFormViewState();
}

class _UserProfileBasicFormViewState extends State<UserProfileBasicFormView> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  //image variable
  File? _image;
  String? photoUrl;

  // Full Name, Email, profile image, college name, course name, gender, birthdate
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _genderController =
      TextEditingController(text: "Not Selected");
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullName;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _collegeNameController.dispose();
    _courseNameController.dispose();
    _genderController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _birthdateController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _handleImageButtonPress(context) async {
    final image =
        await _imagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        setState(() {
          _image = File(value.path);
        });
      }
      return value;
    });
    if (image != null) {
      final imageUrl = await GetIt.I<UserRepository>()
          .uploadProfileImage(image.path, widget.user.id)
          .catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading profile image'),
          ),
        );
        return Future.value("");
      });
      if (imageUrl != "") {
        setState(() {
          photoUrl = imageUrl;
        });
      }
    }
  }

  Future<List<University>?> getUniversities(String? searchString) async {
    return GetIt.I<UserRepository>().getUniversities(searchString);
  }

  Future<List<Degree>?> getMastersDegree(String? searchString) async {
    return GetIt.I<UserRepository>().getMastersDegree(searchString);
  }

  Future<void> setBasicUserProfile() async {
    setState(() {
      isLoading = true;
    });
    UserBasicProfile userBasicProfile = UserBasicProfile(
      userId: widget.user.id,
      fullName: _fullNameController.text,
      email: widget.user.email,
      photoUrl: photoUrl ?? widget.user.photoUrl,
      birthDate: selectedDate,
      selectedCollegeName: _collegeNameController.text,
      selectedCourseName: _courseNameController.text,
      gender: _genderController.text,
      state: _stateController.text,
      country: _countryController.text,
    );

    GetIt.I<UserRepository>().setBasicUserProfileData(userBasicProfile);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 16.0, bottom: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(),
                _buildProfileImage(context),
                _buildSpacing(40),
                _buildFullNameField(),
                _buildSpacing(20),
                _buildBirthDate(context),
                _buildSpacing(20),
                _buildGenderField(),
                _buildSpacing(20),
                _buildCollegeNameField(),
                _buildSpacing(20),
                _buildDegreeNameField(),
                _buildSpacing(20),
                _buildStateField(),
                _buildSpacing(20),
                _buildCountryField(),
                _buildSpacing(20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          'Profile Info',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 24.0),
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return CustomTextField(
      controller: _fullNameController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
      labelText: 'Full Name',
      prefixIcon: Icon(
        Icons.person,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildBirthDate(BuildContext context) {
    return CustomTextField(
      controller: _birthdateController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Birthdate';
        }
        return null;
      },
      labelText: 'Birthdate',
      enabled: false,
      prefixIcon: Icon(
        Icons.calendar_today,
        color: AppTheme.primary,
      ),
      onTap: () async {
        await _selectDate(context);
      },
    );
  }

  Widget _buildSpacing(double height) {
    return SizedBox(
      height: height,
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 75,
            child: GestureDetector(
              onTap: () => _handleImageButtonPress(context),
              child: ClipOval(
                child: _image != null
                    ? Image.file(
                        _image!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person,
                        size: 75,
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
                onPressed: () => _handleImageButtonPress(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownSearch<University?>(
        filterFn: (user, filter) {
          return user!.title!.toLowerCase().contains(filter.toLowerCase());
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.bodyLarge,
          dropdownSearchDecoration: InputDecoration(
            labelText: 'College Name',
            prefixIcon: Icon(
              Icons.school,
              color: AppTheme.primary,
            ),
            border: InputBorder.none,
          ),
        ),
        asyncItems: (value) => getUniversities(value).then(
          (value) {
            if (value != null) {
              return value;
            } else {
              return [];
            }
          },
        ),
        popupProps: PopupProps.dialog(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 14.0),
              child: child,
            );
          },
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: 'Search for your college',
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          itemBuilder: (context, University? university, isSelected) {
            return ListTile(
              leading: Image.network(
                university!.logo!,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.greyShades.shade600,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.school,
                      color: AppTheme.greyShades.shade800,
                    ),
                  );
                },
              ),
              title: Text(university.title!),
              selected: isSelected,
            );
          },
          showSearchBox: true,
        ),
        validator: (value) {
          if (value == null) {
            return 'Please select your college';
          }
          return null;
        },
        onChanged: (value) {
          if (value?.title != null) {
            _collegeNameController.text = value!.title!;
          }
        },
        itemAsString: (University? u) => u!.title!,
      ),
    );
  }

  Widget _buildDegreeNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownSearch<Degree?>(
        filterFn: (user, filter) {
          return user!.name.toLowerCase().contains(filter.toLowerCase());
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.bodyLarge,
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Degree Name',
            prefixIcon: Icon(
              Icons.school,
              color: AppTheme.primary,
            ),
            border: InputBorder.none,
          ),
        ),
        asyncItems: (value) => getMastersDegree(value).then(
          (value) {
            if (value != null) {
              return value;
            } else {
              return [];
            }
          },
        ),
        popupProps: PopupProps.dialog(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 12.0),
              child: child,
            );
          },
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: 'Search for your graduate degree',
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          itemBuilder: (context, Degree? degree, isSelected) {
            return ListTile(
              title: Text(degree?.name ?? ''),
              selected: isSelected,
            );
          },
          showSearchBox: true,
        ),
        validator: (value) {
          if (value == null) {
            return 'Please select your college';
          }
          return null;
        },
        onChanged: (value) {
          if (value?.name != null) {
            _courseNameController.text = value!.name;
          }
        },
        itemAsString: (Degree? u) => u!.name,
      ),
    );
  }

  Widget _buildGenderField() {
    return CustomDropdownField(
      prefixIcon: Icon(
        FontAwesomeIcons.venusMars,
        size: 20.0,
        color: AppTheme.primary,
      ),
      labelText: 'Gender',
      validatorText: 'Please select your gender',
      controller: _genderController,
      items: const [
        'Male',
        'Female',
        'Other',
        'Not Selected',
      ],
    );
  }

  Widget _buildStateField() {
    return CustomTextField(
      controller: _stateController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter your state';
        }
        return null;
      },
      labelText: 'State',
      keyboardType: TextInputType.name,
      isCapitalized: true,
      prefixIcon: Icon(
        FontAwesomeIcons.city,
        color: AppTheme.primary,
        size: 18,
      ),
    );
  }

  Widget _buildCountryField() {
    return CustomSearchableDropDownField(
      controller: _countryController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter your country';
        }
        return null;
      },
      asyncItems: (query) {
        return Future.value(GetIt.I<UserRepository>().getCountries());
      },
      filterFn: (item, query) {
        return item.toLowerCase().contains(query.toLowerCase());
      },
      labelText: 'Country',
      prefixIcon: Icon(
        Icons.location_city,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_genderController.text == "Not Selected") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please select your gender',
                  style: AppTheme.bodyLarge,
                ),
              ),
            );
            return;
          }
          if (_stateController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please enter your state',
                  style: AppTheme.bodyLarge,
                ),
              ),
            );
            return;
          }
          if (_countryController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please enter your country',
                  style: AppTheme.bodyLarge,
                ),
              ),
            );
            return;
          }
          if (_formKey.currentState!.validate()) {
            try {
              setBasicUserProfile();
              context.go(AppRouterService.homeScreen);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error setting basic user profile'),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppTheme.primary, // Set background color to primary theme color
        ),
        child: !isLoading
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Submit',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme
                        .onPrimary, // Set text color to onPrimary theme color
                    fontSize: 20,
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
