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
    this.hasAC,
    this.hasHeater,
    this.hasFurnished,
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
        (hasHeater ?? false) ||
        (hasFurnished ?? false) ||
        (extraAmenities?.isNotEmpty ?? false);
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
      'has_heater': hasHeater ?? false,
      'has_furnished': hasFurnished ?? false,
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
      hasHeater: map['has_heater'] ?? false,
      hasFurnished: map['has_furnished'] ?? false,
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
    bool? hasHeater,
    bool? hasFurnished,
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
      hasHeater: hasHeater ?? this.hasHeater,
      hasFurnished: hasFurnished ?? this.hasFurnished,
      extraAmenities: extraAmenities ?? this.extraAmenities,
    );
  }
}
