import 'package:flutter/material.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';
import 'package:nesters/features/home/view/pages/user_list_view_page.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/features/home/view/components/filter_tile.dart';
import 'package:nesters/features/home/view/components/filter_tab.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';

class UserFilterPage extends StatefulWidget {
  final UserFilter? initialFilter;
  final List<University> universities;
  final Function(UserFilter) onApply;
  final Function() onReset;

  const UserFilterPage({
    super.key,
    this.initialFilter,
    required this.universities,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<UserFilterPage> createState() => _UserFilterPageState();
}

class _UserFilterPageState extends State<UserFilterPage> {
  late UserFilter userFilter;
  UserFilterTypes userFilterTypeSelected = UserFilterTypes.University;
  List<University> filterUniversities = [];
  final TextEditingController intakeYearController = TextEditingController();
  DateTime selectedYearDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    userFilter = widget.initialFilter ?? UserFilter();
    filterUniversities = widget.universities;
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
                      backgroundColor: AppTheme.error,
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
                      widget.onApply(userFilter);
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
          ...UserFilterTypes.values.map(
            (e) => FilterTab(
              title: e.toString(),
              isSelected: userFilterTypeSelected == e,
              onTap: () => setState(() {
                userFilterTypeSelected = e;
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
          child: switch (userFilterTypeSelected) {
            UserFilterTypes.University => Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search University',
                      hintStyle: AppTheme.bodySmall,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.greyShades.shade800,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(8),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (value == "") {
                        setState(() {
                          filterUniversities = widget.universities;
                        });
                      } else {
                        setState(() {
                          filterUniversities = widget.universities
                              .where((item) =>
                                  item.title
                                      ?.toLowerCase()
                                      .contains(value.toLowerCase()) ??
                                  false)
                              .toList();
                        });
                      }
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filterUniversities.length,
                      itemBuilder: (context, index) {
                        return UniversityFilterTile(
                          isSelected: userFilter.university?.id ==
                              filterUniversities[index].id,
                          isDense: true,
                          onTap: () {
                            setState(() {
                              if (userFilter.university?.id ==
                                  filterUniversities[index].id) {
                                userFilter =
                                    userFilter.copyWith(university: null);
                              } else {
                                userFilter = userFilter.copyWith(
                                  university: filterUniversities[index],
                                );
                              }
                            });
                          },
                          university: filterUniversities[index],
                        );
                      },
                    ),
                  )
                ],
              ),
            UserFilterTypes.Branch => DegreesLoader(
                builder: (context, degrees) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: degrees.length,
                    itemBuilder: (context, index) {
                      return DegreeFilterTile(
                        isSelected:
                            userFilter.branchName == degrees[index].name,
                        isDense: true,
                        onTap: () {
                          setState(() {
                            if (userFilter.branchName == degrees[index].name) {
                              // Unselect if already selected
                              userFilter =
                                  userFilter.copyWith(branchName: null);
                            } else {
                              userFilter = userFilter.copyWith(
                                branchName: degrees[index].name,
                              );
                            }
                          });
                        },
                        degree: degrees[index],
                      );
                    },
                  );
                },
              ),
            UserFilterTypes.IntakePeriod => ListView.builder(
                shrinkWrap: true,
                itemCount: UserIntake.safeValues.length,
                itemBuilder: (context, index) {
                  return FilterTile(
                    title: UserIntake.values[index].toString(),
                    isSelected:
                        userFilter.intakePeriod == UserIntake.values[index],
                    onTap: () {
                      setState(() {
                        if (userFilter.intakePeriod ==
                            UserIntake.values[index]) {
                          userFilter = userFilter.copyWith(intakePeriod: null);
                        } else {
                          userFilter = userFilter.copyWith(
                            intakePeriod: UserIntake.values[index],
                          );
                        }
                      });
                    },
                  );
                },
              ),
            UserFilterTypes.IntakeYear => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextField(
                      isDense: true,
                      controller: intakeYearController,
                      hintText: 'Intake Year',
                      labelText: 'Intake Year',
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Intake Year';
                        }
                        return null;
                      },
                      enabled: false,
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
                                  firstDate:
                                      DateTime(DateTime.now().year - 100, 1),
                                  lastDate:
                                      DateTime(DateTime.now().year + 100, 1),
                                  selectedDate: selectedYearDateTime,
                                  onChanged: (DateTime dateTime) {
                                    Navigator.pop(context);
                                    intakeYearController.text =
                                        dateTime.year.toString();
                                    selectedYearDateTime = dateTime;
                                    setState(() {
                                      userFilter = userFilter.copyWith(
                                          intakeYear: dateTime.year);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (intakeYearController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomFlatButton(
                        onPressed: () {
                          setState(() {
                            intakeYearController.clear();
                            selectedYearDateTime = DateTime.now();
                            userFilter = userFilter.copyWith(intakeYear: null);
                          });
                        },
                        text: 'Reset',
                      ),
                    ),
                ],
              ),
            UserFilterTypes.Gender => ListView(
                children: [
                  FilterTile(
                    title: 'Male',
                    isSelected: userFilter.flatmateGenderPref == 'Male',
                    onTap: () {
                      setState(() {
                        if (userFilter.flatmateGenderPref == 'Male') {
                          userFilter =
                              userFilter.copyWith(flatmateGenderPref: null);
                        } else {
                          userFilter = userFilter.copyWith(
                            flatmateGenderPref: 'Male',
                          );
                        }
                      });
                    },
                  ),
                  FilterTile(
                    title: 'Female',
                    isSelected: userFilter.flatmateGenderPref == 'Female',
                    onTap: () {
                      setState(() {
                        if (userFilter.flatmateGenderPref == 'Female') {
                          userFilter =
                              userFilter.copyWith(flatmateGenderPref: null);
                        } else {
                          userFilter = userFilter.copyWith(
                            flatmateGenderPref: 'Female',
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
            UserFilterTypes.EatingHabits => ListView(
                children: [
                  ...UserFoodHabit.toList().map(
                    (e) => FilterTile(
                      title: e.toUserFriendlyString().capitalize,
                      isSelected: userFilter.foodHabit == e,
                      onTap: () {
                        setState(() {
                          if (userFilter.foodHabit == e) {
                            userFilter = userFilter.copyWith(
                                foodHabit: UserFoodHabit.UNKNOWN);
                          } else {
                            userFilter = userFilter.copyWith(foodHabit: e);
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
            UserFilterTypes.SmokingHabits => ListView(
                children: [
                  ...UserHabit.toList().map(
                    (e) => FilterTile(
                      title: e.toString().capitalize,
                      isSelected: userFilter.smokingHabit == e,
                      onTap: () {
                        setState(() {
                          if (userFilter.smokingHabit == e) {
                            userFilter =
                                userFilter.copyWith(smokingHabit: null);
                          } else {
                            userFilter = userFilter.copyWith(smokingHabit: e);
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
            UserFilterTypes.DrinkingHabits => ListView(
                children: [
                  ...UserHabit.toList().map(
                    (e) => FilterTile(
                      title: e.toString().capitalize,
                      isSelected: userFilter.drinkingHabit == e,
                      onTap: () {
                        setState(() {
                          if (userFilter.drinkingHabit == e) {
                            userFilter =
                                userFilter.copyWith(drinkingHabit: null);
                          } else {
                            userFilter = userFilter.copyWith(drinkingHabit: e);
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
            UserFilterTypes.RoomType => ListView(
                children: [
                  ...UserRoomType.toList().map(
                    (e) => FilterTile(
                      title: e.toString(),
                      isSelected: userFilter.roomType == e,
                      onTap: () {
                        setState(() {
                          if (userFilter.roomType == e) {
                            userFilter = userFilter.copyWith(roomType: null);
                          } else {
                            userFilter = userFilter.copyWith(roomType: e);
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
          },
        ),
      ),
    );
  }
}
