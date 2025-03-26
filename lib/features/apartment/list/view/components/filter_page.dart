import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_places_sdk/google_places_sdk.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/apartment_filter.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/apartment/list/bloc/apartment_bloc.dart';
import 'package:nesters/features/apartment/list/view/apartment_list_page.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/debouncer.dart';
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
  ApartmentFilterTypes apartmentFilterTypeSelected =
      ApartmentFilterTypes.Location;
  ApartmentFilter apartmentFilter = ApartmentFilter();
  List<AutocompletePrediction> places = [];
  BlocState searchingState = const BlocState(isLoading: false);

  final GooglePlaces googlePlaces = GetIt.I<GooglePlaces>();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.filter != null) {
      apartmentFilter = widget.filter!;
    }
  }

  void _onLocationChanged(String value) async {
    _debouncer.run(() async {
      if (value.isEmpty) {
        setState(() {
          places = [];
        });
        return;
      }
      setState(() {
        searchingState = const BlocState(isLoading: true);
      });
      try {
        final response = await googlePlaces.getAutoCompletePredictions(value);
        places = response;
      } on AppException catch (e) {
        searchingState = searchingState.copyWith(exception: e);
      } finally {
        setState(() {
          searchingState = searchingState.copyWith(isLoading: false);
        });
      }
    });
  }

  Future<void> _getLocationDetails(String placeId) async {
    try {
      final response = await googlePlaces.fetchPlaceDetails(placeId);
      final location = response.latLng;
      if (location != null) {
        apartmentFilter = apartmentFilter.copyWith(
          location: Location(
            latitude: location.lat,
            longitude: location.lng,
          ),
          address: response.address,
        );
        places = [];
      }
      _locationController.clear();
    } on AppException catch (e) {
      searchingState = searchingState.copyWith(exception: e);
    } finally {
      setState(() {
        searchingState = searchingState.copyWith(isLoading: false);
      });
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
      case ApartmentFilterTypes.Location:
        return _buildLocationFilter();
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

  Widget _buildLocationFilter() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CustomTextField(
            hintText: "Enter Location",
            onChanged: (value) {
              _onLocationChanged(value);
            },
            controller: _locationController,
          ),
        ),
        if (apartmentFilter.address != null) ...[
          ListTile(
            title: Text(
              "Selected Location",
              style: AppTheme.titleSmall.copyWith(color: AppTheme.primary),
            ),
            dense: true,
            subtitle: Text(apartmentFilter.address ?? '',
                style: AppTheme.labelMedium),
            trailing: IconButton(
              icon: const Icon(Icons.close_outlined),
              iconSize: 20,
              onPressed: () {
                _locationController.clear();
                places = [];
                apartmentFilter = apartmentFilter.resetLocation();
                setState(() {});
              },
            ),
            contentPadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ],
        if (searchingState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (searchingState.exception != null)
          ShowErrorWidget(
            error: searchingState.exception!,
          )
        else
          ...places.map(
            (e) => ListTile(
              title: Text(e.primaryText ?? ''),
              subtitle: Text(e.secondaryText ?? ''),
              dense: true,
              onTap: () {
                if (e.placeId == null) return;
                _getLocationDetails(e.placeId!);
              },
            ),
          ),
      ],
    );
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
                        apartmentFilter = apartmentFilter.copyWith(
                          startRent: double.parse(value),
                        );
                      });
                    } else {
                      setState(() {
                        apartmentFilter = apartmentFilter.resetStartRent();
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
                    (apartmentFilter.startRent == null)
                        ? "Select"
                        : "\$${apartmentFilter.startRent}",
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
                  color: apartmentFilter.startRent == null
                      ? AppTheme.greyShades.shade400
                      : AppTheme.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (apartmentFilter.startRent == null) {
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return CustomValuePicker(
                        values: List.generate(
                          apartmentFilter.startRent != null
                              ? apartmentFilter.startRent!.toInt()
                              : 100,
                          (index) => ((apartmentFilter.startRent ?? 100) +
                                  (index * 100))
                              .toInt()
                              .toString(),
                        ),
                        title: "Select End Rent",
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        apartmentFilter = apartmentFilter.copyWith(
                          endRent: double.parse(value),
                        );
                      });
                    } else {
                      setState(() {
                        apartmentFilter = apartmentFilter.resetEndRent();
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
                    (apartmentFilter.endRent != null)
                        ? "\$${apartmentFilter.endRent}"
                        : "Select",
                    style: AppTheme.bodySmall.copyWith(
                      color: apartmentFilter.startRent == null
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
        if (apartmentFilter.startRent != null ||
            apartmentFilter.endRent != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  apartmentFilter = apartmentFilter.resetRent();
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
            "No of Beds: ${apartmentFilter.apartmentSize?.beds ?? "1"}",
            style: AppTheme.titleMedium,
          ),
        ),
        Slider(
          value: apartmentFilter.apartmentSize?.beds?.toDouble() ?? 1,
          onChanged: (value) {
            setState(() {
              apartmentFilter = apartmentFilter.copyWith(
                apartmentSize: ApartmentSize(
                  beds: value.toInt(),
                  baths: apartmentFilter.apartmentSize?.baths ?? 1,
                ),
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
            "No of Baths: ${apartmentFilter.apartmentSize?.baths ?? "1"}",
            style: AppTheme.titleMedium,
          ),
        ),
        Slider(
          value: apartmentFilter.apartmentSize?.baths?.toDouble() ?? 1,
          onChanged: (value) {
            setState(() {
              apartmentFilter = apartmentFilter.copyWith(
                apartmentSize: ApartmentSize(
                  beds: apartmentFilter.apartmentSize?.beds ?? 1,
                  baths: value.toInt(),
                ),
              );
            });
          },
          min: 1,
          max: 5,
          divisions: 100,
        ),
        if (apartmentFilter.apartmentSize != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  apartmentFilter = apartmentFilter.resetApartmentSize();
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
                    lastDate: apartmentFilter.leasePeriod?.endDate ??
                        DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        apartmentFilter = apartmentFilter.copyWith(
                          leasePeriod: LeasePeriod(
                            startDate: value,
                            endDate: apartmentFilter.leasePeriod?.endDate,
                          ),
                        );
                      });
                    } else {
                      setState(() {
                        apartmentFilter = apartmentFilter.resetLeasePeriod();
                      });
                    }
                  });
                },
                child: apartmentFilter.leasePeriod?.startDate != null
                    ? Text(
                        "${apartmentFilter.leasePeriod?.startDate!.day}, ${apartmentFilter.leasePeriod?.startDate!.monthName(true)}, ${apartmentFilter.leasePeriod?.startDate!.year}",
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
        if (apartmentFilter.leasePeriod != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  apartmentFilter = apartmentFilter.resetLeasePeriod();
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
                  isSelected: apartmentFilter.amenitiesAvailable
                          ?.toAmenitiesTypes()
                          .contains(e) ??
                      false,
                  onTap: () {
                    final amenities = apartmentFilter.amenitiesAvailable
                            ?.toAmenitiesTypes() ??
                        [];
                    if (amenities.contains(e)) {
                      amenities.remove(e);
                    } else {
                      amenities.add(e);
                    }
                    setState(() {
                      apartmentFilter = apartmentFilter.copyWith(
                        amenitiesAvailable:
                            Amenities.fromAmenitiesTypes(amenities),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        if (apartmentFilter.amenitiesAvailable != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomFlatButton(
              onPressed: () {
                setState(() {
                  apartmentFilter = apartmentFilter.resetAmenities();
                });
              },
              text: 'Reset',
            ),
          )
      ],
    );
  }
}
