import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/domain/models/apartment/apartment_filter.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/features/apartment/list/bloc/apartment_bloc.dart';
import 'package:nesters/features/apartment/list/view/apartment_list_page.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentFilterDialogPage extends StatefulWidget {
  final ApartmentFilter? filter;
  const ApartmentFilterDialogPage({super.key, this.filter});

  @override
  State<ApartmentFilterDialogPage> createState() =>
      _ApartmentFilterDialogPageState();
}

class _ApartmentFilterDialogPageState extends State<ApartmentFilterDialogPage> {
  ApartmentFilterTypes apartmentFilterTypeSelected = ApartmentFilterTypes.Rent;
  double? rentStart;
  double? rentEnd;
  LeasePeriod? selectedLeasePeriod;
  Map<AmenitiesType, bool> selectedAmenities = {};
  ApartmentSize? selectedApartmentSize;

  @override
  void initState() {
    super.initState();
    if (widget.filter != null) {
      rentStart = widget.filter!.startRent;
      rentEnd = widget.filter!.endRent;
      selectedLeasePeriod = widget.filter!.leasePeriod;
      selectedApartmentSize = widget.filter!.apartmentSize;
      selectedAmenities =
          widget.filter!.amenitiesAvailable?.toMapAmenitiesTypes() ?? {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...ApartmentFilterTypes.values.map(
                        (e) => FilterTab(
                          title: e.toString(),
                          isSelected: e == apartmentFilterTypeSelected,
                          onTap: () {
                            setState(() {
                              apartmentFilterTypeSelected = e;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.greyShades.shade300,
                        ),
                      ),
                    ),
                    child: _buildFilterContent(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<ApartmentBloc>().add(
                          const ApartmentEvent.removeFilterEvent(),
                        );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: Text(
                    'Reset All',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.onError,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final apartmentFilter = ApartmentFilter(
                      startRent: rentStart,
                      endRent: rentEnd,
                      leasePeriod: selectedLeasePeriod,
                      apartmentSize: selectedApartmentSize,
                      amenitiesAvailable: Amenities.fromAmenitiesTypes(
                        selectedAmenities.keys.toList(),
                      ),
                    );
                    context
                        .read<ApartmentBloc>()
                        .add(ApartmentEvent.addFilterEvent(apartmentFilter));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Apply',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColor.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (apartmentFilterTypeSelected) {
      case ApartmentFilterTypes.Rent:
        return _buildRentFilter();
      case ApartmentFilterTypes.ApartmentSize:
        return _buildApartmentSizeFilter();
      case ApartmentFilterTypes.LeasePeriods:
        return _buildLeasePeriodFilter();
      case ApartmentFilterTypes.Ameneties:
        return _buildAmenitiesFilter();
    }
  }

  Widget _buildRentFilter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                "Start Rent",
                style: AppTheme.titleSmall,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return CustomValuePicker(
                        values: List.generate(
                          100,
                          (index) => (100 + (index * 100)).toInt().toString(),
                        ),
                        title: "Select Start Rent",
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        rentStart = double.parse(value);
                      });
                    } else {
                      setState(() {
                        rentStart = null; // Unselect start rent
                      });
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.greyShades.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (rentStart == null) ? "Select" : "\$$rentStart",
                    style: AppTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                "End Rent",
                style: AppTheme.titleSmall.copyWith(
                  color: rentStart == null
                      ? AppTheme.greyShades.shade400
                      : AppTheme.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (rentStart == null) {
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return CustomValuePicker(
                        values: List.generate(
                          rentStart != null ? rentStart!.toInt() : 100,
                          (index) => ((rentStart ?? 100) + (index * 100))
                              .toInt()
                              .toString(),
                        ),
                        title: "Select End Rent",
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        rentEnd = double.parse(value);
                      });
                    } else {
                      setState(() {
                        rentEnd = null; // Unselect end rent
                      });
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.greyShades.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (rentEnd != null) ? "\$$rentEnd" : "Select",
                    style: AppTheme.bodySmall.copyWith(
                      color: rentStart == null
                          ? AppTheme.greyShades.shade400
                          : AppTheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // reset button
        if (rentStart != null || rentEnd != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  rentStart = null;
                  rentEnd = null;
                });
              },
              text: 'Reset',
            ),
          ),
      ],
    );
  }

  Widget _buildApartmentSizeFilter() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "No of Beds: ${selectedApartmentSize?.beds ?? "1"}",
            style: AppTheme.titleMedium,
          ),
        ),
        Slider(
          value: selectedApartmentSize?.beds?.toDouble() ?? 1,
          onChanged: (value) {
            setState(() {
              selectedApartmentSize = ApartmentSize(
                beds: value.toInt(),
                baths: selectedApartmentSize?.baths ?? 1,
              );
            });
          },
          min: 1,
          max: 5,
          divisions: 100,
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            "No of Baths: ${selectedApartmentSize?.baths ?? "1"}",
            style: AppTheme.titleMedium,
          ),
        ),
        Slider(
          value: selectedApartmentSize?.baths?.toDouble() ?? 1,
          onChanged: (value) {
            setState(() {
              selectedApartmentSize = ApartmentSize(
                baths: value.toInt(),
                beds: selectedApartmentSize?.beds ?? 1,
              );
            });
          },
          min: 1,
          max: 5,
          divisions: 100,
        ),
        if (selectedApartmentSize != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  selectedApartmentSize = null; // Unselect apartment size
                  log("Selected apartment size: $selectedApartmentSize");
                });
              },
              text: 'Reset',
            ),
          ),
      ],
    );
  }

  Widget _buildLeasePeriodFilter() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Start Date",
                style: AppTheme.titleSmall,
              ),
              GestureDetector(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    lastDate: selectedLeasePeriod?.endDate ??
                        DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        selectedLeasePeriod = LeasePeriod(
                          startDate: value,
                          endDate: selectedLeasePeriod?.endDate,
                        );
                      });
                    } else {
                      setState(() {
                        selectedLeasePeriod = null; // Unselect start date
                      });
                    }
                  });
                },
                child: selectedLeasePeriod?.startDate != null
                    ? Text(
                        "${selectedLeasePeriod?.startDate!.day}, ${selectedLeasePeriod?.startDate!.monthName(true)}, ${selectedLeasePeriod?.startDate!.year}",
                        style: AppTheme.bodySmall,
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.greyShades.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Select",
                          style: AppTheme.bodySmall,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (selectedLeasePeriod != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  selectedLeasePeriod = null; // Unselect lease period
                });
              },
              text: 'Reset',
            ),
          ),
      ],
    );
  }

  Widget _buildAmenitiesFilter() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ...AmenitiesType.values.map(
                (e) => FilterTile(
                  title: e.toString(),
                  isSelected: selectedAmenities.containsKey(e),
                  onTap: () {
                    setState(() {
                      if (selectedAmenities.containsKey(e)) {
                        selectedAmenities.remove(e); // Unselect amenity
                      } else {
                        selectedAmenities[e] = true;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        if (selectedAmenities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  selectedAmenities.clear();
                });
              },
              text: 'Reset',
            ),
          )
      ],
    );
  }
}
