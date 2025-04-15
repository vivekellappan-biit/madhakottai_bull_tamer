class CompanyModel {
  final int id;
  final String logo;
  final String name;
  final String street;
  final String street2;

  CompanyModel({
    required this.id,
    required this.logo,
    required this.name,
    required this.street,
    required this.street2,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      logo: json['logo'] ?? '',
      name: json['name'] ?? '',
      street: json['street'] ?? '',
      street2: json['street2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logo': logo,
      'name': name,
      'street': street,
      'street2': street2,
    };
  }
}
