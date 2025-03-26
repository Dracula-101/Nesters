import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_places_sdk/google_places_sdk.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/sublet/list/view/sublet_list_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/domain/models/sublet/sublet_filter.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/debouncer.dart';
import 'package:nesters/utils/widgets/widgets.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class SubletFilterPage extends StatefulWidget {
  final SubletFilter? initialFilter;
  final Function(SubletFilter) onApply;
  final Function() onReset;

  const SubletFilterPage({
    super.key,
    this.initialFilter,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<SubletFilterPage> createState() => _SubletFilterPageState();
}

class _SubletFilterPageState extends State<SubletFilterPage> {
  late SubletFilter subletFilter;
  SubletFilterTypes subletFilterTypeSelected = SubletFilterTypes.Location;
  List<AutocompletePrediction> places = [];
  final GooglePlaces googlePlaces = GetIt.I<GooglePlaces>();
  BlocState searchingState = const BlocState(isLoading: false);
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subletFilter = widget.initialFilter ?? SubletFilter();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
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
        subletFilter = subletFilter.copyWith(
          address: response.address,
          location: Location(
            latitude: location.lat,
            longitude: location.lng,
          ),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Material(
        color: AppTheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterTabs(),
                    _buildFilterTabValues(),
                  ],
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onReset();
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
                      widget.onApply(subletFilter);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Apply',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColor.white,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35,
      child: ListView(
        shrinkWrap: true,
        children: [
          ...SubletFilterTypes.values.map(
            (e) => FilterTab(
              title: e.toString(),
              isSelected: subletFilterTypeSelected == e,
              onTap: () => setState(() {
                subletFilterTypeSelected = e;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabValues() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppTheme.greyShades.shade300,
            ),
          ),
        ),
        child: SizedBox(
          child: switch (subletFilterTypeSelected) {
            SubletFilterTypes.Location => ListView(
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
                  if (subletFilter.address != null) ...[
                    ListTile(
                      title: Text(
                        "Selected Location",
                        style: AppTheme.titleSmall
                            .copyWith(color: AppTheme.primary),
                      ),
                      dense: true,
                      subtitle: Text(subletFilter.address ?? '',
                          style: AppTheme.labelMedium),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_outlined),
                        iconSize: 20,
                        onPressed: () {
                          _locationController.clear();
                          places = [];
                          subletFilter = subletFilter.resetLocation();
                          setState(() {});
                        },
                      ),
                      contentPadding:
                          const EdgeInsets.only(left: 12, top: 4, bottom: 4),
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
              ),
            SubletFilterTypes.RoomateGenderPref => ListView(
                children: [
                  FilterTile(
                    title: "Male",
                    isSelected: subletFilter.roommateGenderPref == 'Male',
                    onTap: () {
                      setState(() {
                        if (subletFilter.roommateGenderPref == "Male") {
                          subletFilter = subletFilter.resetRoommateGenderPref();
                        } else {
                          subletFilter = subletFilter.copyWith(
                            roommateGenderPref: 'Male',
                          );
                        }
                      });
                    },
                  ),
                  FilterTile(
                    title: "Female",
                    isSelected: subletFilter.roommateGenderPref == 'Female',
                    onTap: () {
                      setState(() {
                        if (subletFilter.roommateGenderPref == "Female") {
                          subletFilter = subletFilter.resetRoommateGenderPref();
                        } else {
                          subletFilter = subletFilter.copyWith(
                            roommateGenderPref: 'Female',
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
            SubletFilterTypes.Rent => Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                                      (index) => (100 + (index * 100))
                                          .toInt()
                                          .toString()),
                                  title: "Select Start Rent",
                                );
                              },
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  subletFilter = subletFilter.copyWith(
                                    startRent: double.parse(value),
                                  );
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
                              subletFilter.startRent != null
                                  ? "\$${subletFilter.startRent}"
                                  : "Select",
                              style: AppTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "End Rent",
                          style: AppTheme.titleSmall.copyWith(
                            color: subletFilter.startRent == null
                                ? AppTheme.greyShades.shade400
                                : AppTheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (subletFilter.startRent == null) return;
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return CustomValuePicker(
                                  values: List.generate(
                                      subletFilter.startRent!.toInt(),
                                      (index) =>
                                          ((subletFilter.startRent ?? 100) +
                                                  (index * 100))
                                              .toInt()
                                              .toString()),
                                  title: "Select End Rent",
                                );
                              },
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  subletFilter = subletFilter.copyWith(
                                    endRent: double.parse(value),
                                  );
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
                              subletFilter.endRent != null
                                  ? "\$${subletFilter.endRent}"
                                  : "Select",
                              style: AppTheme.bodySmall.copyWith(
                                color: subletFilter.startRent == null
                                    ? AppTheme.greyShades.shade400
                                    : AppTheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subletFilter.startRent != null ||
                      subletFilter.endRent != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomFlatButton(
                        text: "Reset",
                        onPressed: () {
                          setState(() {
                            subletFilter = subletFilter.resetRent();
                          });
                        },
                      ),
                    )
                ],
              ),
            SubletFilterTypes.ApartmentSize => ListView(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "No of Beds: ${subletFilter.apartmentSize?.beds ?? "1"}",
                      style: AppTheme.titleMedium,
                    ),
                  ),
                  Slider(
                    value: subletFilter.apartmentSize?.beds?.toDouble() ?? 1,
                    onChanged: (value) {
                      setState(() {
                        subletFilter = subletFilter.copyWith(
                          apartmentSize: ApartmentSize(
                            beds: value.toInt(),
                            baths: subletFilter.apartmentSize?.baths ?? 1,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "No of Baths: ${subletFilter.apartmentSize?.baths ?? "1"}",
                      style: AppTheme.titleMedium,
                    ),
                  ),
                  Slider(
                    value: subletFilter.apartmentSize?.baths?.toDouble() ?? 1,
                    onChanged: (value) {
                      setState(() {
                        subletFilter = subletFilter.copyWith(
                          apartmentSize: ApartmentSize(
                            baths: value.toInt(),
                            beds: subletFilter.apartmentSize?.beds ?? 1,
                          ),
                        );
                      });
                    },
                    min: 1,
                    max: 5,
                    divisions: 100,
                  ),
                  if (subletFilter.apartmentSize != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomFlatButton(
                        text: "Reset",
                        onPressed: () {
                          setState(() {
                            subletFilter = subletFilter.resetApartmentSize();
                          });
                        },
                      ),
                    )
                ],
              ),
            SubletFilterTypes.RoomType => ListView(
                children: [
                  ...UserRoomType.safeValues.map(
                    (e) => FilterTile(
                      title: e.toString(),
                      isSelected: subletFilter.roomType == e,
                      onTap: () {
                        setState(() {
                          if (subletFilter.roomType == e) {
                            subletFilter = subletFilter.resetRoomType();
                          } else {
                            subletFilter = subletFilter.copyWith(roomType: e);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            SubletFilterTypes.LeasePeriods => ListView(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                              lastDate: subletFilter.leasePeriod?.endDate ??
                                  DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now(),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  subletFilter = subletFilter.copyWith(
                                    leasePeriod: LeasePeriod(
                                      startDate: value,
                                      endDate:
                                          subletFilter.leasePeriod?.endDate,
                                    ),
                                  );
                                });
                              }
                            });
                          },
                          child: subletFilter.leasePeriod?.startDate != null
                              ? Text(
                                  "${subletFilter.leasePeriod?.startDate!.day}, ${subletFilter.leasePeriod?.startDate!.monthName(true)}, ${subletFilter.leasePeriod?.startDate!.year}",
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
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "End Date",
                          style: AppTheme.titleSmall,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate:
                                  subletFilter.leasePeriod?.startDate ??
                                      DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              firstDate: subletFilter.leasePeriod?.startDate ??
                                  DateTime.now(),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  subletFilter = subletFilter.copyWith(
                                    leasePeriod: LeasePeriod(
                                      startDate:
                                          subletFilter.leasePeriod?.startDate,
                                      endDate: value,
                                    ),
                                  );
                                });
                              }
                            });
                          },
                          child: subletFilter.leasePeriod?.endDate != null
                              ? Text(
                                  "${subletFilter.leasePeriod?.endDate!.day}, ${subletFilter.leasePeriod?.endDate!.monthName(true)}, ${subletFilter.leasePeriod?.endDate!.year}",
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
                  if (subletFilter.leasePeriod?.startDate != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomFlatButton(
                        text: "Reset",
                        onPressed: () {
                          setState(() {
                            subletFilter = subletFilter.resetLeasePeriod();
                          });
                        },
                      ),
                    )
                ],
              ),
            SubletFilterTypes.Ameneties => ListView(
                children: [
                  ...AmenitiesType.values.map(
                    (e) => FilterTile(
                      title: e.toString(),
                      isSelected: subletFilter.amenitiesAvailable
                              ?.toMapAmenitiesTypes()
                              .containsKey(e) ??
                          false,
                      onTap: () {
                        setState(() {
                          final amenities = subletFilter.amenitiesAvailable
                                  ?.toMapAmenitiesTypes() ??
                              {};
                          if (amenities.containsKey(e)) {
                            amenities.remove(e);
                          } else {
                            amenities[e] = true;
                          }
                          subletFilter = subletFilter.copyWith(
                            amenitiesAvailable: Amenities.fromAmenitiesTypes(
                                amenities.keys.toList()),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
          },
        ),
      ),
    );
  }
}
