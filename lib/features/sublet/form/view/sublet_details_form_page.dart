import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/features/sublet/form/cubit/sublet_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletDetailsForm extends StatefulWidget {
  final TabController? controller;
  const SubletDetailsForm({super.key, this.controller});

  @override
  State<SubletDetailsForm> createState() => _SubletDetailsFormState();
}

class _SubletDetailsFormState extends State<SubletDetailsForm>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _roomTypeContoller = TextEditingController();
  final TextEditingController _roomateGenderController =
      TextEditingController();
  DateTime? startDate, endDate;
  int baths = 0, beds = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    _rentPriceController.dispose();
    _roomTypeContoller.dispose();
    _roomateGenderController.dispose();
    super.dispose();
  }

  bool validateAllFields() {
    bool isAllTextFieldsValid = _formKey.currentState!.validate();
    bool isStartDateValid = startDate != null;
    bool isEndDateValid = endDate != null;
    bool isRoomTypeValid = _roomTypeContoller.text.isNotEmpty;
    bool isRoomateGenderValid = _roomateGenderController.text.isNotEmpty;
    bool isBedsValid = beds > 0;
    bool isBathsValid = baths > 0;
    if (!isAllTextFieldsValid) {
      showErrorSnackBar('Please fill all the fields');
      return false;
    } else if (!isStartDateValid) {
      showErrorSnackBar('Please select the start date');
      return false;
    } else if (!isEndDateValid) {
      showErrorSnackBar('Please select the end date');
      return false;
    } else if (!isRoomTypeValid) {
      showErrorSnackBar('Please select the room type');
      return false;
    } else if (!isRoomateGenderValid) {
      showErrorSnackBar('Please select the gender preference');
      return false;
    } else if (!isBedsValid) {
      showErrorSnackBar('Please select the no of beds');
      return false;
    } else if (!isBathsValid) {
      showErrorSnackBar('Please select the no of baths');
      return false;
    }
    // check if start date is before end date
    if (startDate!.isAfter(endDate!)) {
      showErrorSnackBar('Start date cannot be after end date');
      return false;
    }
    return true;
  }

  void showErrorSnackBar(String message) {
    context.showErrorSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SubletFormCubit, SubletFormState>(
      listener: (context, state) {
        bool validatePage = state.validatingPage == 0;
        if (validatePage) {
          if (validateAllFields()) {
            context.read<SubletFormCubit>().showPageValid(1);
            widget.controller!.animateTo(1);
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressField(),
              _buildSpacing(),
              _buildStartEndDate(),
              _buildSpacing(),
              _buildPriceField(),
              _buildSpacing(),
              _buildRoomTypeDropdown(),
              _buildSpacing(),
              _buildRoomateGenderDropdown(),
              _buildSpacing(height: 24),
              _buildSubSectionTitle('Your Apartment Size'),
              _buildSpacing(),
              _buildApartmentSize(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpacing({double height = 16}) {
    return SizedBox(height: height);
  }

  Widget _buildAddressField() {
    return CustomTextField(
      controller: _addressController,
      labelText: 'Address',
      prefixIcon: Icon(
        FontAwesomeIcons.locationDot,
        color: AppTheme.greyShades.shade600,
        size: 22,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the address';
        }
        return null;
      },
      hintText: 'Enter the address of the apartment',
    );
  }

  Widget _buildStartEndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ).then((value) {
                if (value != null) {
                  setState(() => startDate = value);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.calendarAlt,
                    color: AppTheme.greyShades.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date'),
                        if (startDate != null)
                          Text(
                            startDate!.toShortUIDate(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.greyShades.shade600,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ).then((value) {
                if (value != null) {
                  setState(() => endDate = value);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.calendarAlt,
                    color: AppTheme.greyShades.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Date'),
                        if (endDate != null)
                          Text(
                            endDate!.toShortUIDate(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.greyShades.shade600,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPriceField() {
    return CustomTextField(
      controller: _rentPriceController,
      labelText: 'Rent Price / month',
      prefixIcon: Icon(
        FontAwesomeIcons.dollarSign,
        color: AppTheme.greyShades.shade600,
        size: 20,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the rent price';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      hintText: 'Enter the rent price',
    );
  }

  Widget _buildRoomTypeDropdown() {
    return CustomDropdownField(
      controller: _roomTypeContoller,
      labelText: 'Room Type',
      hintText: 'Select the room type',
      prefixIcon: Icon(
        Icons.home_rounded,
        color: AppTheme.greyShades.shade600,
        size: 26,
      ),
      items: const [
        UserRoomType.PRIVATE,
        UserRoomType.SHARED,
        UserRoomType.FLEX,
      ].map((e) => e.toUI()).toList(),
      validatorText: 'Please select the room type',
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(),
        Container(
          decoration: BoxDecoration(color: AppTheme.surface),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
          ),
        )
      ],
    );
  }

  Widget _buildApartmentSize() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CustomValuePicker(
                    title: 'Select no of Beds',
                    values: List.generate(5, (index) => index + 1).map((e) {
                      return e.toString();
                    }).toList(),
                  );
                },
              ).then((value) => setState(() => beds = int.parse(value)));
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.bed,
                    color: AppTheme.greyShades.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Beds'),
                        Text(
                          beds.toString(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.greyShades.shade600,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CustomValuePicker(
                    title: 'Select no of Baths',
                    values: List.generate(5, (index) => index + 1).map((e) {
                      return e.toString();
                    }).toList(),
                  );
                },
              ).then((value) => setState(() => baths = int.parse(value)));
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.bath,
                    color: AppTheme.greyShades.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Baths'),
                        Text(
                          baths.toString(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.greyShades.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRoomateGenderDropdown() {
    return CustomDropdownField(
      controller: _roomateGenderController,
      items: const [
        'Male',
        'Female',
        'Any',
      ],
      labelText: 'Gender Preference',
      prefixIcon: Icon(
        FontAwesomeIcons.venusMars,
        color: AppTheme.greyShades.shade600,
        size: 20,
      ),
      validatorText: 'Please select gender preference',
    );
  }

  @override
  bool get wantKeepAlive => true;
}
