class LocationLabel {
  const LocationLabel({
    required this.name,
    required this.country,
    this.admin1,
  });

  final String name;
  final String country;
  final String? admin1;

  factory LocationLabel.fromJson(Map<String, dynamic> json) {
    return LocationLabel(
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        if (admin1 != null) 'admin1': admin1,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationLabel &&
          name == other.name &&
          country == other.country &&
          admin1 == other.admin1;

  @override
  int get hashCode => Object.hash(name, country, admin1);
}

class SelectedLocation {
  const SelectedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.timezone,
    this.labels,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;
  final String? timezone;
  final Map<String, LocationLabel>? labels;

  factory SelectedLocation.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    Map<String, LocationLabel>? labels;
    if (rawLabels is Map) {
      labels = rawLabels.map(
        (key, value) => MapEntry(
          key.toString(),
          LocationLabel.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      );
    }

    return SelectedLocation(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
      labels: labels,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        if (admin1 != null) 'admin1': admin1,
        if (timezone != null) 'timezone': timezone,
        if (labels != null)
          'labels': labels!.map((key, value) => MapEntry(key, value.toJson())),
      };

  SelectedLocation copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? admin1,
    String? timezone,
    Map<String, LocationLabel>? labels,
  }) {
    return SelectedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      admin1: admin1 ?? this.admin1,
      timezone: timezone ?? this.timezone,
      labels: labels ?? this.labels,
    );
  }

  SelectedLocation withLabel(String locale, LocationLabel label) {
    return copyWith(
      labels: {
        ...?labels,
        locale: label,
      },
    );
  }
}

class GeocodeData {
  const GeocodeData({required this.results});

  final List<SelectedLocation> results;

  factory GeocodeData.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? const [];
    return GeocodeData(
      results: list
          .map((item) => SelectedLocation.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}
