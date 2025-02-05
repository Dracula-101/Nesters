import 'city_info_response.dart';

class CityInfo {
  final String cityName;
  final String stateName;
  final String countryName;

  CityInfo({
    required this.cityName,
    required this.stateName,
    required this.countryName,
  });

  static List<CityInfo> fromResponse(CityInfoResponse response) {
    return response.cities?.map(
          (cityInfo) {
            return CityInfo(
              cityName: cityInfo.name ?? '',
              stateName: cityInfo.state?.name ?? '',
              countryName: cityInfo.country?.name ?? '',
            );
          },
        ).toList() ??
        [];
  }
}
