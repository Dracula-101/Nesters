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
    required this.hasDryer,
    required this.hasWashingMachine,
    required this.hasDishwasher,
    required this.hasParking,
    required this.hasGym,
    required this.hasPool,
    required this.hasBalcony,
    required this.hasPatio,
    required this.hasAC,
    required this.hasHeater,
    required this.hasFurnished,
    required this.extraAmenities,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasDryer': hasDryer ?? false,
      'hasWashingMachine': hasWashingMachine ?? false,
      'hasDishwasher': hasDishwasher ?? false,
      'hasParking': hasParking ?? false,
      'hasGym': hasGym ?? false,
      'hasPool': hasPool ?? false,
      'hasBalcony': hasBalcony ?? false,
      'hasPatio': hasPatio ?? false,
      'hasAC': hasAC ?? false,
      'hasHeater': hasHeater ?? false,
      'hasFurnished': hasFurnished ?? false,
      'extraAmenities': extraAmenities ?? [],
    };
  }

  factory Amenities.fromMap(Map<String, dynamic> map) {
    return Amenities(
      hasDryer: map['hasDryer'] ?? false,
      hasWashingMachine: map['hasWashingMachine'] ?? false,
      hasDishwasher: map['hasDishwasher'] ?? false,
      hasParking: map['hasParking'] ?? false,
      hasGym: map['hasGym'] ?? false,
      hasPool: map['hasPool'] ?? false,
      hasBalcony: map['hasBalcony'] ?? false,
      hasPatio: map['hasPatio'] ?? false,
      hasAC: map['hasAC'] ?? false,
      hasHeater: map['hasHeater'] ?? false,
      hasFurnished: map['hasFurnished'] ?? false,
      extraAmenities: map['extraAmenities'] ?? [],
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
