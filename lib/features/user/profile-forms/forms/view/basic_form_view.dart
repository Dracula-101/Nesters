// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/location/city_info.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';
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
  //image variable
  File? _image;
  String? photoUrl;
  CityInfo? userCityInfo;

  // Full Name, Email, profile image, college name, course name, gender, birthdate, intake period and year
  final MediaRepository _mediaRepository = GetIt.I<MediaRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _genderController =
      TextEditingController(text: "Not Selected");
  final TextEditingController _intakePeriodController =
      TextEditingController(text: "Not Selected");
  final TextEditingController _intakeYearController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _locationContoller = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime _selectedYear = DateTime.now();
  bool isLoading = false;
  University? _selectedUniversity;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullName.toTitleCase;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _collegeNameController.dispose();
    _courseNameController.dispose();
    _genderController.dispose();
    _intakePeriodController.dispose();
    _intakeYearController.dispose();
    _birthdateController.dispose();
    _locationContoller.dispose();

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

  void _handleImageButtonPress(context, image) async {
    if (image != null) {
      final imageUrl = await GetIt.I<UserRepository>()
          .uploadProfileImage(image.path, widget.user.id)
          .catchError((err) {
        context.showErrorSnackbar('Error uploading profile image');
        return Future.value("");
      });
      if (imageUrl != "") {
        setState(() {
          photoUrl = imageUrl;
        });
        log(photoUrl!);
      }
    }
  }

  Future<List<University>> getUniversities(String? searchString) async {
    return GetIt.I<UserRepository>().getUniversities(searchString);
  }

  Future<List<Degree>> getMastersDegree(String? searchString) async {
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
      userCollege: _selectedUniversity,
      selectedCourseName: _courseNameController.text,
      gender: _genderController.text,
      intakePeriod: _intakePeriodController.text,
      intakeYear: _selectedYear.year,
      city: userCityInfo?.cityName ?? "",
      state: userCityInfo?.stateName,
      country: userCityInfo?.countryName,
    );
    try {
      final isProfileSet = await GetIt.I<UserRepository>()
          .setBasicUserProfileData(userBasicProfile);
      await _authRepository.updateUserInfo(null);
      if (isProfileSet) {
        context.showSuccessSnackBar('Profile created successfully');
        GoRouter.of(context).go(AppRouterService.homeScreen);
      } else {
        context.showErrorSnackBar('Error while creating user profile');
      }
    } on AppException catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.message);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                _buildYearPicker(context),
                _buildSpacing(20),
                _buildIntakePeriodField(),
                _buildSpacing(20),
                _buildDegreeNameField(),
                _buildSpacing(20),
                _buildLocationField(),
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

  Widget _buildYearPicker(BuildContext context) {
    return CustomTextField(
      controller: _intakeYearController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Intake Year';
        }
        return null;
      },
      labelText: 'Intake Year',
      enabled: false,
      prefixIcon: Icon(
        Icons.calendar_today,
        color: AppTheme.primary,
      ),
      onTap: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Select Year"),
              content: SizedBox(
                width: 300,
                height: 300,
                child: YearPicker(
                  firstDate: DateTime(DateTime.now().year - 100, 1),
                  lastDate: DateTime(DateTime.now().year + 100, 1),
                  // save the selected date to _selectedDate DateTime variable.
                  // It's used to set the previous selected date when
                  // re-showing the dialog.
                  selectedDate: _selectedYear,
                  onChanged: (DateTime dateTime) {
                    Navigator.pop(context);
                    _intakeYearController.text = dateTime.year.toString();
                    _selectedYear = dateTime;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpacing(double height) {
    return SizedBox(
      height: height,
    );
  }

  // _handleImageButtonPress(context)
  Widget _buildProfileImage(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(
                  16.0,
                ),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        _buildOptionItem(
                          Icons.photo,
                          'Gallery',
                          () {
                            Navigator.pop(context);
                            _mediaRepository
                                .getImageFromGallery()
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  _image = File(value.path);
                                });
                                _handleImageButtonPress(context, value);
                              }
                            });
                          },
                        ),
                        _buildOptionItem(
                          Icons.camera_alt,
                          'Camera',
                          () {
                            Navigator.pop(context);
                            _mediaRepository.getImageFromCamera().then((value) {
                              if (value != null) {
                                setState(() {
                                  _image = File(value.path);
                                });
                                _handleImageButtonPress(context, value);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    // Add more Row widgets for additional options as needed
                  ],
                ),
              );
            },
          )
        },
        child: Stack(
          children: [
            CircleAvatar(
              radius: 75,
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
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
            ),
            Text(
              label,
            ),
          ],
        ),
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
        asyncItems: (value) => getUniversities(value),
        popupProps: PopupProps.dialog(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 14.0),
              child: child,
            );
          },
          errorBuilder: (context, searchEntry, error) {
            return ShowErrorWidget(error: error);
          },
          emptyBuilder: (context, searchEntry) {
            return ShowInfoWidget(
              message: searchEntry.isNotEmpty ? 'No items found' : 'Search',
              subtitle: searchEntry.isNotEmpty
                  ? 'No data related to "$searchEntry" found'
                  : 'Search for your graduate degree',
            );
          },
          loadingBuilder: (context, searchEntry) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
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
        asyncItems: (value) => getMastersDegree(value),
        popupProps: PopupProps.dialog(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 12.0),
              child: child,
            );
          },
          errorBuilder: (context, searchEntry, error) {
            return ShowErrorWidget(error: error);
          },
          emptyBuilder: (context, searchEntry) {
            return ShowInfoWidget(
              message: searchEntry.isNotEmpty ? 'No items found' : 'Search',
              subtitle: searchEntry.isNotEmpty
                  ? 'No data related to "$searchEntry" found'
                  : 'Search for your graduate degree',
            );
          },
          loadingBuilder: (context, searchEntry) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
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

  Widget _buildIntakePeriodField() {
    return CustomDropdownField(
      prefixIcon: Icon(
        FontAwesomeIcons.venusMars,
        size: 20.0,
        color: AppTheme.primary,
      ),
      labelText: 'Intake Period',
      validatorText: 'Please select your intake period',
      controller: _intakePeriodController,
      items: UserIntake.values.map((e) => e.toString()).toList(),
    );
  }

  Widget _buildLocationField() {
    return CustomDynamicSearchableDropDropField(
      controller: _locationContoller,
      labelText: 'City',
      prefixIcon: Icon(
        Icons.location_on,
        color: AppTheme.primary,
      ),
      asyncSearchItems: (value) => Stream.fromFuture(
        GetIt.I<UserRepository>()
            .searchCities(searchQuery: value.isEmpty ? "Aa" : value),
      ),
      searchText: "Search City",
      hintText: 'Search for your city',
      validator: (value) {
        if (value == null) {
          return 'Please select your city';
        }
        return null;
      },
      emptyBuilder: (p0) {
        return ShowInfoWidget(
          message:
              _locationContoller.text.isEmpty ? 'Location' : 'No items found',
          subtitle: _locationContoller.text.isEmpty
              ? 'Find and select your city'
              : 'No data related to "${_locationContoller.text}" found',
          icon: Icons.search,
        );
      },
      onItemClick: (value) {
        userCityInfo = value;
      },
      itemBuilder: (context, value) {
        return ListTile(
          title: Text(value.cityName ?? ''),
          subtitle: Text("${value.stateName}, ${value.countryName}"),
        );
      },
      itemAsString: (value) => "${value.cityName}, ${value.countryName}",
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_genderController.text == "Not Selected") {
            context.showErrorSnackBar('Please Select Your Gender');
            return;
          }
          if (_intakePeriodController.text == "Not Selected") {
            context.showErrorSnackBar('Please Select Your Intake Period');
            return;
          }
          if (_formKey.currentState!.validate()) {
            setBasicUserProfile();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppTheme.primary, // Set background color to primary theme color
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: !isLoading
              ? Text(
                  'Submit',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme
                        .onPrimary, // Set text color to onPrimary theme color
                    fontSize: 20,
                  ),
                )
              : SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
