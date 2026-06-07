import 'package:latlong2/latlong.dart';

class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    this.cep = '',
    this.street = '',
    this.number,
    this.complement,
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.latitude,
    this.longitude,
    this.legacyAddress,
  });

  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final String cep;
  final String street;
  final String? number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;
  final String? legacyAddress;

  bool get hasStructuredAddress =>
      cep.isNotEmpty &&
      street.isNotEmpty &&
      neighborhood.isNotEmpty &&
      city.isNotEmpty &&
      state.isNotEmpty;

  String get address =>
      hasStructuredAddress ? formattedAddress : (legacyAddress ?? '');

  String get formattedAddress {
    if (!hasStructuredAddress) return legacyAddress ?? '';
    final parts = <String>[
      street,
      if (number != null && number!.trim().isNotEmpty) number!.trim(),
      if (complement != null && complement!.trim().isNotEmpty)
        complement!.trim(),
      neighborhood,
      '$city - $state',
    ];
    return parts.join(', ');
  }

  String get profileLabel {
    if (hasStructuredAddress) return '$city, $state';
    return legacyAddress ?? '';
  }

  LatLng? get storedPosition {
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude!, longitude!);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'passwordHash': passwordHash,
        'cep': cep,
        'street': street,
        'number': number,
        'complement': complement,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        if (legacyAddress != null) 'address': legacyAddress,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    final legacy = json['address'] as String?;
    final neighborhood = json['neighborhood'] as String? ?? '';
    final hasStructured = (json['cep'] as String? ?? '').isNotEmpty &&
        neighborhood.isNotEmpty;

    return UserAccount(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      passwordHash: json['passwordHash'] as String,
      cep: json['cep'] as String? ?? '',
      street: json['street'] as String? ?? '',
      number: json['number'] as String?,
      complement: json['complement'] as String?,
      neighborhood: neighborhood,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      legacyAddress: hasStructured ? null : legacy,
    );
  }
}
