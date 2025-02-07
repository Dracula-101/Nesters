// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:nesters/domain/models/apartment/apartment_model.dart';
// import 'package:nesters/features/apartment/form/cubit/apartment_form_cubit.dart';
// import 'package:nesters/theme/theme.dart';
// import 'package:nesters/utils/widgets/widgets.dart';

// class ApartmentBackgroundInfo extends StatefulWidget {
//   final TabController? controller;
//   final ApartmentModel? apartment;
//   const ApartmentBackgroundInfo({super.key, this.controller, this.apartment});

//   @override
//   State<ApartmentBackgroundInfo> createState() =>
//       ApartmentBackgroundInfoState();
// }

// class ApartmentBackgroundInfoState extends State<ApartmentBackgroundInfo>
//     with AutomaticKeepAliveClientMixin {
//   final TextEditingController _roomDescriptionController =
//       TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // bool hasDryer = false,
  //     hasWashingMachine = false,
  //     hasDishwasher = false,
  //     hasParking = false,
  //     hasGym = false,
  //     hasPool = false,
  //     hasBalcony = false,
  //     hasPatio = false,
  //     hasAC = false,
  //     hasHeater = false,
  //     hasFurnished = false;
  // List<String>? extraAmenities;

  // @override
  // bool get wantKeepAlive => true;

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.apartment != null) {
  //     _roomDescriptionController.text = widget.apartment!.roomDescription ?? '';
  //     hasDryer = widget.apartment!.amenitiesAvailable?.hasDryer ?? false;
  //     hasWashingMachine =
  //         widget.apartment!.amenitiesAvailable?.hasWashingMachine ?? false;
  //     hasDishwasher =
  //         widget.apartment!.amenitiesAvailable?.hasDishwasher ?? false;
  //     hasParking = widget.apartment!.amenitiesAvailable?.hasParking ?? false;
  //     hasGym = widget.apartment!.amenitiesAvailable?.hasGym ?? false;
  //     hasPool = widget.apartment!.amenitiesAvailable?.hasPool ?? false;
  //     hasBalcony = widget.apartment!.amenitiesAvailable?.hasBalcony ?? false;
  //     hasPatio = widget.apartment!.amenitiesAvailable?.hasPatio ?? false;
  //     hasAC = widget.apartment!.amenitiesAvailable?.hasAC ?? false;
  //     hasHeater = widget.apartment!.amenitiesAvailable?.hasHeater ?? false;
  //     hasFurnished =
  //         widget.apartment!.amenitiesAvailable?.hasFurnished ?? false;
  //   }
  //   widget.controller?.addListener(() => addData());
  // }

  // bool validatePage() {
  //   bool allFieldsValid = _formKey.currentState?.validate() ?? false;
  //   return allFieldsValid;
  // }

  // void addData() {
  //   context.read<ApartmentFormCubit>().addSecondPageData(
  //         roomDescription: _roomDescriptionController.text.trim(),
  //         hasAC: hasAC,
  //         hasBalcony: hasBalcony,
  //         hasDishwasher: hasDishwasher,
  //         hasDryer: hasDryer,
  //         hasFurnished: hasFurnished,
  //         hasGym: hasGym,
  //         hasHeater: hasHeater,
  //         hasParking: hasParking,
  //         hasPatio: hasPatio,
  //         hasPool: hasPool,
  //         hasWashingMachine: hasWashingMachine,
  //       );
  // }

  // @override
  // void dispose() {
  //   _roomDescriptionController.dispose();
  //   widget.controller?.removeListener(() => addData());
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   super.build(context);
  //   return BlocListener<ApartmentFormCubit, ApartmentFormState>(
  //     listener: (context, state) {
  //       if (state.isValidating) {
  //         if (validatePage() || state.hasThirdPageAccess) {
  //           context.read<ApartmentFormCubit>().showPageValid(2);
  //           widget.controller?.animateTo(2);
  //         }
  //       }
  //     },
  //     child: SingleChildScrollView(
  //       padding: const EdgeInsets.all(16),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             _buildRoomDescription(),
  //             _buildSpacing(),
  //             _buildAmenities(),
  //             _buildSpacing(height: 32),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSpacing({double height = 16}) => SizedBox(height: height);

  // Widget _buildRoomDescription() {
  //   return CustomTextField(
  //     controller: _roomDescriptionController,
  //     labelText: 'Room Description',
  //     hintText:
  //         'Ex. This spacious room is bright and cheerful with natural light 🌞 streaming through a large window 🪟. It features a luxurious king-size bed 🛏️, stylish furniture 🪑 with ample storage, cozy reading corner 🌿, and modern decor accented with tasteful artwork 🖼️.',
  //     alignLabelWithHint: true,
  //     maxLines: 5,
  //     validator: (value) {
  //       if (value.isEmpty) {
  //         return 'Please enter a room description';
  //       }
  //       return null;
  //     },
  //   );
  // }

  // Widget _buildAmenities() {
  //   return GestureDetector(
  //     onTap: () {
  //       showModalBottomSheet(
  //         context: context,
  //         builder: ((context) => _buildAmenitiesBottomSheet()),
  //       );
  //     },
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  //       decoration: BoxDecoration(
  //         color: AppTheme.greyShades.shade200,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: BlocBuilder<ApartmentFormCubit, ApartmentFormState>(
  //         builder: (context, state) {
  //           return Row(
  //             children: [
  //               Icon(
  //                 (state.isPreFilled == true)
  //                     ? Icons.check_circle_outline
  //                     : Icons.add_circle_outline,
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 "Select${state.isPreFilled == true ? "ed" : ""} Amenties",
  //                 style: AppTheme.bodyLarge,
  //               )
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

//   Widget _buildAmenitiesBottomSheet() {
//     return SizedBox(
//       width: double.infinity,
//       height: 400,
//       child: Column(
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'Select Amenities',
//               style: AppTheme.titleLarge,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Flexible(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 12,
//                 children: [
//                   AmentityWidget(
//                     title: 'Dryer',
//                     value: hasDryer,
//                     icon: Icons.dry,
//                     onChanged: (value) {
//                       setState(() {
//                         hasDryer = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Gym',
//                     value: hasGym,
//                     icon: Icons.fitness_center,
//                     onChanged: (value) {
//                       setState(() {
//                         hasGym = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Pool',
//                     value: hasPool,
//                     icon: Icons.pool,
//                     onChanged: (value) {
//                       setState(() {
//                         hasPool = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'AC',
//                     value: hasAC,
//                     icon: Icons.ac_unit,
//                     onChanged: (value) {
//                       setState(() {
//                         hasAC = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Dishwasher',
//                     value: hasDishwasher,
//                     icon: Icons.dinner_dining,
//                     onChanged: (value) {
//                       setState(() {
//                         hasDishwasher = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Parking',
//                     value: hasParking,
//                     icon: Icons.local_parking,
//                     onChanged: (value) {
//                       setState(() {
//                         hasParking = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Balcony',
//                     value: hasBalcony,
//                     icon: Icons.balcony,
//                     onChanged: (value) {
//                       setState(() {
//                         hasBalcony = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Patio',
//                     value: hasPatio,
//                     icon: FontAwesomeIcons.piedPiperHat,
//                     onChanged: (value) {
//                       setState(() {
//                         hasPatio = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Heater',
//                     value: hasHeater,
//                     icon: FontAwesomeIcons.fire,
//                     onChanged: (value) {
//                       setState(() {
//                         hasHeater = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Furnished',
//                     value: hasFurnished,
//                     icon: Icons.weekend,
//                     onChanged: (value) {
//                       setState(() {
//                         hasFurnished = value;
//                       });
//                     },
//                   ),
//                   AmentityWidget(
//                     title: 'Washing Machine',
//                     value: hasWashingMachine,
//                     icon: Icons.wash,
//                     onChanged: (value) {
//                       setState(() {
//                         hasWashingMachine = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class AmentityWidget extends StatefulWidget {
//   final bool value;
//   final String title;
//   final IconData icon;
//   final Function(bool) onChanged;
//   final double? iconsSize;
//   const AmentityWidget(
//       {super.key,
//       required this.value,
//       required this.title,
//       required this.icon,
//       required this.onChanged,
//       this.iconsSize});

//   @override
//   State<AmentityWidget> createState() => _AmentityWidgetState();
// }

// class _AmentityWidgetState extends State<AmentityWidget> {
//   bool currentValue = false;

//   @override
//   void initState() {
//     super.initState();
//     currentValue = widget.value;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           currentValue = !currentValue;
//           widget.onChanged(currentValue);
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: currentValue
//               ? AppTheme.primaryShades.shade100
//               : AppTheme.greyShades.shade200,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color:
//                 currentValue ? AppTheme.primary : AppTheme.greyShades.shade300,
//             width: currentValue ? 1.5 : 1,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               widget.icon,
//               color: currentValue
//                   ? AppTheme.primary
//                   : AppTheme.primaryShades.shade300,
//               size: widget.iconsSize ?? 18,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               widget.title,
//               style: AppTheme.bodyMedium.copyWith(
//                 color: currentValue
//                     ? AppTheme.primary
//                     : AppTheme.primaryShades.shade300,
//               ),
//             ),
//             const SizedBox(width: 8),
//             if (currentValue)
//               Icon(
//                 Icons.check,
//                 color: AppTheme.primary,
//               )
//             else
//               Icon(
//                 Icons.close,
//                 color: AppTheme.primaryShades.shade300,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
