class CityInfoResponse {
  List<Cities>? cities;
  Meta? meta;

  CityInfoResponse({this.cities, this.meta});

  CityInfoResponse.fromJson(Map<String, dynamic> json) {
    if (json['cities'] != null) {
      cities = <Cities>[];
      json['cities'].forEach((v) {
        cities!.add(Cities.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Cities {
  String? code;
  Continent? continent;
  Continent? country;
  County? county;
  String? latitude;
  String? longitude;
  String? name;
  String? postcode;
  County? state;

  Cities(
      {this.code,
      this.continent,
      this.country,
      this.county,
      this.latitude,
      this.longitude,
      this.name,
      this.postcode,
      this.state});

  Cities.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    continent = json['continent'] != null
        ? Continent.fromJson(json['continent'])
        : null;
    country =
        json['country'] != null ? Continent.fromJson(json['country']) : null;
    county = json['county'] != null ? County.fromJson(json['county']) : null;
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    postcode = json['postcode'];
    state = json['state'] != null ? County.fromJson(json['state']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (continent != null) {
      data['continent'] = continent!.toJson();
    }
    if (country != null) {
      data['country'] = country!.toJson();
    }
    if (county != null) {
      data['county'] = county!.toJson();
    }
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['name'] = name;
    data['postcode'] = postcode;
    if (state != null) {
      data['state'] = state!.toJson();
    }
    return data;
  }
}

class Continent {
  String? code;
  String? latitude;
  String? longitude;
  String? name;
  String? nameEs;
  String? nameFr;

  Continent(
      {this.code,
      this.latitude,
      this.longitude,
      this.name,
      this.nameEs,
      this.nameFr});

  Continent.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    nameEs = json['nameEs'];
    nameFr = json['nameFr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['name'] = name;
    data['nameEs'] = nameEs;
    data['nameFr'] = nameFr;
    return data;
  }
}

class County {
  String? code;
  String? latitude;
  String? longitude;
  String? name;

  County({this.code, this.latitude, this.longitude, this.name});

  County.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['name'] = name;
    return data;
  }
}

class Meta {
  int? currentPage;
  int? firstPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta(
      {this.currentPage,
      this.firstPage,
      this.lastPage,
      this.perPage,
      this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    firstPage = json['firstPage'];
    lastPage = json['lastPage'];
    perPage = json['perPage'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPage'] = currentPage;
    data['firstPage'] = firstPage;
    data['lastPage'] = lastPage;
    data['perPage'] = perPage;
    data['total'] = total;
    return data;
  }
}
