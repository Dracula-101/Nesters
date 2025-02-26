import 'package:google_places_sdk/google_places_sdk.dart';

class SearchAddress {
  final String placeId;
  final String primaryText;
  final String secondaryText;

  SearchAddress({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  static SearchAddress fromPrediction(AutocompletePrediction prediction) {
    return SearchAddress(
      placeId: prediction.placeId ?? '',
      primaryText: prediction.primaryText ?? '',
      secondaryText: prediction.secondaryText ?? '',
    );
  }
}
