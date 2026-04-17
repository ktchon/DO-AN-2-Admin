class AddressModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isSelected;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.isSelected,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      name: map['Name'] ?? '',
      phoneNumber: map['PhoneNumber'] ?? '',
      street: map['Street'] ?? '',
      city: map['City'] ?? '',
      state: map['State'] ?? '',
      country: map['Country'] ?? '',
      postalCode: map['PostalCode'] ?? '',
      isSelected: map['SelectedAddress'] ?? false,
    );
  }
}