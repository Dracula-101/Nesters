class Amenities {
  bool? hasDryer;
  bool? hasWashingMachine;
  bool? hasDishwasher;
  bool? hasParking;
  bool? hasGym;
  bool? hasPool;
  bool? hasBalcony;
  bool? hasPatio;
  bool? hasAC;
  bool? hasGas;
  bool? hasSemiFurnished;
  bool? hasHeater;
  bool? hasFurnished;
  List<String>? extraAmenities;

  Amenities({
    this.hasDryer,
    this.hasWashingMachine,
    this.hasDishwasher,
    this.hasParking,
    this.hasGym,
    this.hasPool,
    this.hasBalcony,
    this.hasPatio,
    this.hasGas,
    this.hasAC,
    this.hasHeater,
    this.hasFurnished,
    this.hasSemiFurnished,
    this.extraAmenities,
  });

  // nullsafe method
  bool hasAmenities() {
    return (hasDryer ?? false) ||
        (hasWashingMachine ?? false) ||
        (hasDishwasher ?? false) ||
        (hasParking ?? false) ||
        (hasGym ?? false) ||
        (hasPool ?? false) ||
        (hasBalcony ?? false) ||
        (hasPatio ?? false) ||
        (hasAC ?? false) ||
        (hasGas ?? false) ||
        (hasHeater ?? false) ||
        (hasFurnished ?? false) ||
        (hasSemiFurnished ?? false) ||
        (extraAmenities?.isNotEmpty ?? false);
  }

  bool hasAmenity(AmenitiesType type) {
    switch (type) {
      case AmenitiesType.Dryer:
        return hasDryer ?? false;
      case AmenitiesType.WashingMachine:
        return hasWashingMachine ?? false;
      case AmenitiesType.Dishwasher:
        return hasDishwasher ?? false;
      case AmenitiesType.Parking:
        return hasParking ?? false;
      case AmenitiesType.Gym:
        return hasGym ?? false;
      case AmenitiesType.Pool:
        return hasPool ?? false;
      case AmenitiesType.Balcony:
        return hasBalcony ?? false;
      case AmenitiesType.Patio:
        return hasPatio ?? false;
      case AmenitiesType.Gas:
        return hasGas ?? false;
      case AmenitiesType.AC:
        return hasAC ?? false;
      case AmenitiesType.Heater:
        return hasHeater ?? false;
      case AmenitiesType.Furnished:
        return hasFurnished ?? false;
      case AmenitiesType.SemiFurnished:
        return hasSemiFurnished ?? false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'has_dryer': hasDryer ?? false,
      'has_washing_machine': hasWashingMachine ?? false,
      'has_dishwasher': hasDishwasher ?? false,
      'has_parking': hasParking ?? false,
      'has_gym': hasGym ?? false,
      'has_pool': hasPool ?? false,
      'has_balcony': hasBalcony ?? false,
      'has_patio': hasPatio ?? false,
      'has_AC': hasAC ?? false,
      'has_gas': hasGas ?? false,
      'has_heater': hasHeater ?? false,
      'has_furnished': hasFurnished ?? false,
      'has_semi_furnished': hasSemiFurnished ?? false,
      'extra_amenities': extraAmenities ?? [],
    };
  }

  factory Amenities.fromMap(Map<String, dynamic> map) {
    return Amenities(
      hasDryer: map['has_dryer'] ?? false,
      hasWashingMachine: map['has_washing_machine'] ?? false,
      hasDishwasher: map['has_dishwasher'] ?? false,
      hasParking: map['has_parking'] ?? false,
      hasGym: map['has_gym'] ?? false,
      hasPool: map['has_pool'] ?? false,
      hasBalcony: map['has_balcony'] ?? false,
      hasPatio: map['has_patio'] ?? false,
      hasAC: map['has_AC'] ?? false,
      hasGas: map['has_gas'] ?? false,
      hasHeater: map['has_heater'] ?? false,
      hasFurnished: map['has_furnished'] ?? false,
      hasSemiFurnished: map['has_semi_furnished'] ?? false,
      extraAmenities: List<String>.from(map['extra_amenities'] ?? []),
    );
  }

  Amenities copyWith({
    bool? hasDryer,
    bool? hasWashingMachine,
    bool? hasDishwasher,
    bool? hasParking,
    bool? hasGym,
    bool? hasPool,
    bool? hasBalcony,
    bool? hasPatio,
    bool? hasAC,
    bool? hasGas,
    bool? hasHeater,
    bool? hasFurnished,
    bool? hasSemiFurnished,
    List<String>? extraAmenities,
  }) {
    return Amenities(
      hasDryer: hasDryer ?? this.hasDryer,
      hasWashingMachine: hasWashingMachine ?? this.hasWashingMachine,
      hasDishwasher: hasDishwasher ?? this.hasDishwasher,
      hasParking: hasParking ?? this.hasParking,
      hasGym: hasGym ?? this.hasGym,
      hasPool: hasPool ?? this.hasPool,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      hasPatio: hasPatio ?? this.hasPatio,
      hasAC: hasAC ?? this.hasAC,
      hasGas: hasGas ?? this.hasGas,
      hasHeater: hasHeater ?? this.hasHeater,
      hasFurnished: hasFurnished ?? this.hasFurnished,
      hasSemiFurnished: hasSemiFurnished ?? this.hasSemiFurnished,
      extraAmenities: extraAmenities ?? this.extraAmenities,
    );
  }

  Amenities copyObject(Amenities other) {
    return copyWith(
      hasDryer: other.hasDryer,
      hasWashingMachine: other.hasWashingMachine,
      hasDishwasher: other.hasDishwasher,
      hasParking: other.hasParking,
      hasGym: other.hasGym,
      hasPool: other.hasPool,
      hasBalcony: other.hasBalcony,
      hasPatio: other.hasPatio,
      hasAC: other.hasAC,
      hasGas: other.hasGas,
      hasHeater: other.hasHeater,
      hasFurnished: other.hasFurnished,
      hasSemiFurnished: other.hasSemiFurnished,
      extraAmenities: other.extraAmenities,
    );
  }

  Amenities mapAmenities(AmenitiesType type) {
    switch (type) {
      case AmenitiesType.Dryer:
        return copyWith(hasDryer: !(hasDryer ?? true));
      case AmenitiesType.WashingMachine:
        return copyWith(hasWashingMachine: !(hasWashingMachine ?? true));
      case AmenitiesType.Dishwasher:
        return copyWith(hasDishwasher: !(hasDishwasher ?? true));
      case AmenitiesType.Parking:
        return copyWith(hasParking: !(hasParking ?? true));
      case AmenitiesType.Gym:
        return copyWith(hasGym: !(hasGym ?? true));
      case AmenitiesType.Pool:
        return copyWith(hasPool: !(hasPool ?? true));
      case AmenitiesType.Balcony:
        return copyWith(hasBalcony: !(hasBalcony ?? true));
      case AmenitiesType.Patio:
        return copyWith(hasPatio: !(hasPatio ?? true));
      case AmenitiesType.AC:
        return copyWith(hasAC: !(hasAC ?? true));
      case AmenitiesType.Gas:
        return copyWith(hasGas: !(hasGas ?? true));
      case AmenitiesType.Heater:
        return copyWith(hasHeater: !(hasHeater ?? true));
      case AmenitiesType.SemiFurnished:
        return copyWith(hasSemiFurnished: !(hasSemiFurnished ?? true));
      case AmenitiesType.Furnished:
        return copyWith(hasFurnished: !(hasFurnished ?? true));
    }
  }

  static Amenities fromAmenitiesTypes(List<AmenitiesType> types) {
    return Amenities(
      hasDryer: types.contains(AmenitiesType.Dryer),
      hasWashingMachine: types.contains(AmenitiesType.WashingMachine),
      hasDishwasher: types.contains(AmenitiesType.Dishwasher),
      hasParking: types.contains(AmenitiesType.Parking),
      hasGym: types.contains(AmenitiesType.Gym),
      hasPool: types.contains(AmenitiesType.Pool),
      hasBalcony: types.contains(AmenitiesType.Balcony),
      hasGas: types.contains(AmenitiesType.Gas),
      hasPatio: types.contains(AmenitiesType.Patio),
      hasAC: types.contains(AmenitiesType.AC),
      hasHeater: types.contains(AmenitiesType.Heater),
      hasSemiFurnished: types.contains(AmenitiesType.SemiFurnished),
      hasFurnished: types.contains(AmenitiesType.Furnished),
    );
  }

  List<AmenitiesType> toAmenitiesTypes() {
    List<AmenitiesType> types = [];
    if (hasDryer ?? false) types.add(AmenitiesType.Dryer);
    if (hasWashingMachine ?? false) types.add(AmenitiesType.WashingMachine);
    if (hasDishwasher ?? false) types.add(AmenitiesType.Dishwasher);
    if (hasParking ?? false) types.add(AmenitiesType.Parking);
    if (hasGym ?? false) types.add(AmenitiesType.Gym);
    if (hasPool ?? false) types.add(AmenitiesType.Pool);
    if (hasGas ?? false) types.add(AmenitiesType.Gas);
    if (hasBalcony ?? false) types.add(AmenitiesType.Balcony);
    if (hasPatio ?? false) types.add(AmenitiesType.Patio);
    if (hasAC ?? false) types.add(AmenitiesType.AC);
    if (hasHeater ?? false) types.add(AmenitiesType.Heater);
    if (hasSemiFurnished ?? false) types.add(AmenitiesType.SemiFurnished);
    if (hasFurnished ?? false) types.add(AmenitiesType.Furnished);
    return types;
  }

  Map<AmenitiesType, bool> toMapAmenitiesTypes() {
    return {
      if (hasDryer ?? false) AmenitiesType.Dryer: true,
      if (hasWashingMachine ?? false) AmenitiesType.WashingMachine: true,
      if (hasDishwasher ?? false) AmenitiesType.Dishwasher: true,
      if (hasParking ?? false) AmenitiesType.Parking: true,
      if (hasGym ?? false) AmenitiesType.Gym: true,
      if (hasPool ?? false) AmenitiesType.Pool: true,
      if (hasGas ?? false) AmenitiesType.Gas: true,
      if (hasBalcony ?? false) AmenitiesType.Balcony: true,
      if (hasPatio ?? false) AmenitiesType.Patio: true,
      if (hasAC ?? false) AmenitiesType.AC: true,
      if (hasHeater ?? false) AmenitiesType.Heater: true,
      if (hasSemiFurnished ?? false) AmenitiesType.SemiFurnished: true,
      if (hasFurnished ?? false) AmenitiesType.Furnished: true,
    };
  }

  @override
  String toString() {
    return 'Amenities(hasDryer: $hasDryer, hasWashingMachine: $hasWashingMachine, hasDishwasher: $hasDishwasher, hasParking: $hasParking, hasGym: $hasGym, hasPool: $hasPool, hasBalcony: $hasBalcony, hasPatio: $hasPatio, hasGas: $hasGas, hasAC: $hasAC, hasHeater: $hasHeater, hasFurnished: $hasFurnished, extraAmenities: $extraAmenities, hasSemiFurnished: $hasSemiFurnished)';
  }
}

enum AmenitiesType {
  Dryer,
  WashingMachine,
  Dishwasher,
  Parking,
  Gym,
  Pool,
  Balcony,
  Patio,
  Gas,
  AC,
  Heater,
  SemiFurnished,
  Furnished;

  String toUi() {
    switch (this) {
      case AmenitiesType.Dryer:
        return 'Dryer';
      case AmenitiesType.WashingMachine:
        return 'Washing Machine';
      case AmenitiesType.Dishwasher:
        return 'Dishwasher';
      case AmenitiesType.Parking:
        return 'Parking';
      case AmenitiesType.Gym:
        return 'Gym';
      case AmenitiesType.Pool:
        return 'Pool';
      case AmenitiesType.Gas:
        return 'Gas';
      case AmenitiesType.Balcony:
        return 'Balcony';
      case AmenitiesType.Patio:
        return 'Patio';
      case AmenitiesType.AC:
        return 'AC';
      case AmenitiesType.Heater:
        return 'Heater';
      case AmenitiesType.SemiFurnished:
        return 'Semi-Furnished';
      case AmenitiesType.Furnished:
        return 'Furnished';
    }
  }
}
