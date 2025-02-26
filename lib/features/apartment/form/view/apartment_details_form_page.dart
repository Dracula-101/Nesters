import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/components/amenities_sheet.dart';
import 'package:nesters/features/apartment/form/cubit/apartment_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentDetailsForm extends StatefulWidget {
  final TabController? controller;
  final ApartmentModel? apartment;
  const ApartmentDetailsForm({super.key, this.controller, this.apartment});

  @override
  State<ApartmentDetailsForm> createState() => _ApartmentDetailsFormState();
}

class _ApartmentDetailsFormState extends State<ApartmentDetailsForm>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _apartmentDescriptionController =
      TextEditingController();
  Amenities? amenities;
  DateTime? startDate, endDate;
  int baths = 0, beds = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    if (widget.apartment != null) {
      _addressController.text = widget.apartment!.address ?? '';
      _rentPriceController.text = widget.apartment!.rent.toString();
      startDate = widget.apartment!.leasePeriod?.startDate;
      endDate = widget.apartment!.leasePeriod?.endDate;
      baths = widget.apartment!.apartmentSize?.baths ?? 0;
      beds = widget.apartment!.apartmentSize?.beds ?? 0;

      _apartmentDescriptionController.text =
          widget.apartment!.apartmentDescription ?? '';
      amenities = widget.apartment!.amenitiesAvailable;
    }
    widget.controller!.addListener(() => addData());
  }

  void addData() {
    context.read<ApartmentFormCubit>().addFirstPageData(
          address: _addressController.text.trim(),
          startDate: startDate,
          rentPrice: double.tryParse(_rentPriceController.text.trim()) ?? 0,
          beds: beds,
          baths: baths,
          apartmentDescription: _apartmentDescriptionController.text.trim(),
          amenitiesAvailable: amenities ?? Amenities(),
        );
  }

  bool validateAllFields() {
    bool isAllTextFieldsValid = _formKey.currentState!.validate();
    bool isStartDateValid = startDate != null;
    bool isBedsValid = beds > 0;
    bool isBathsValid = baths > 0;
    if (!isAllTextFieldsValid) {
      showErrorSnackBar('Please fill all the fields');
      return false;
    } else if (!isStartDateValid) {
      showErrorSnackBar('Please select the start date');
      return false;
    } else if (!isBedsValid) {
      showErrorSnackBar('Please select the no of beds');
      return false;
    } else if (!isBathsValid) {
      showErrorSnackBar('Please select the no of baths');
      return false;
    }
    return true;
  }

  void showErrorSnackBar(String message) {
    context.showErrorSnackBar(message);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _rentPriceController.dispose();
    _apartmentDescriptionController.dispose();
    widget.controller!.removeListener(() => addData());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ApartmentFormCubit, ApartmentFormState>(
      listener: (context, state) {
        if (state.isValidating) {
          if (validateAllFields() || state.hasSecondPageAccess) {
            context.read<ApartmentFormCubit>().onPageChange(1);
            context.read<ApartmentFormCubit>().showPageValid(1);
            widget.controller!.animateTo(1);
          }
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressField(),
                _buildSpacing(),
                _buildStartDatePicker(),
                _buildSpacing(),
                _buildPriceField(),
                _buildSpacing(),
                _buildApartmentSize(),
                _buildSpacing(),
                _buildRoomDescription(),
                _buildSpacing(),
                _buildAmenities(),
              ],
            ),
          ),
        );
      },
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

  Widget _buildStartDatePicker() {
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
              ).then((value) =>
                  setState(() => beds = int.tryParse(value.toString()) ?? 0));
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
              ).then((value) =>
                  setState(() => baths = int.tryParse(value.toString()) ?? 0));
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

  Widget _buildRoomDescription() {
    return CustomTextField(
      controller: _apartmentDescriptionController,
      labelText: 'Apartment Description',
      hintText:
          'Ex. This spacious apartment is bright and cheerful with natural light 🌞 streaming through a large window 🪟. It features a luxurious king-size bed 🛏️, stylish furniture 🪑 with ample storage, cozy reading corner 🌿, and modern decor accented with tasteful artwork 🖼️.',
      alignLabelWithHint: true,
      maxLines: 5,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a apartment description';
        }
        return null;
      },
    );
  }

  Widget _buildAmenities() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return AmenitiesBottomSheet(
              amenities: amenities,
              onChanged: (value) {
                setState(() => amenities = value);
              },
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: BlocBuilder<ApartmentFormCubit, ApartmentFormState>(
          builder: (context, state) {
            return Row(
              children: [
                Icon(
                  (state.isPreFilled == true)
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                ),
                const SizedBox(width: 8),
                Text(
                  "Select${state.isPreFilled == true ? "ed" : ""} Amenties",
                  style: AppTheme.bodyLarge,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class AmentityWidget extends StatefulWidget {
  final bool value;
  final String title;
  final IconData icon;
  final Function(bool) onChanged;
  final double? iconsSize;
  const AmentityWidget(
      {super.key,
      required this.value,
      required this.title,
      required this.icon,
      required this.onChanged,
      this.iconsSize});

  @override
  State<AmentityWidget> createState() => _AmentityWidgetState();
}

class _AmentityWidgetState extends State<AmentityWidget> {
  bool currentValue = false;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentValue = !currentValue;
          widget.onChanged(currentValue);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: currentValue
              ? AppTheme.primaryShades.shade100
              : AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                currentValue ? AppTheme.primary : AppTheme.greyShades.shade300,
            width: currentValue ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: currentValue
                  ? AppTheme.primary
                  : AppTheme.primaryShades.shade300,
              size: widget.iconsSize ?? 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: AppTheme.bodyMedium.copyWith(
                color: currentValue
                    ? AppTheme.primary
                    : AppTheme.primaryShades.shade300,
              ),
            ),
            const SizedBox(width: 8),
            if (currentValue)
              Icon(
                Icons.check,
                color: AppTheme.primary,
              )
            else
              Icon(
                Icons.close,
                color: AppTheme.primaryShades.shade300,
              ),
          ],
        ),
      ),
    );
  }
}
