class RegistrationModel {
  final String name;
  final String address;
  final String district; // Added field
  final String onlineRegNo;
  final String bloodGroup;
  final DateTime? dateOfBirth;
  final int? age;

  RegistrationModel({
    required this.name,
    required this.address,
    required this.district, // Added parameter
    required this.onlineRegNo,
    required this.bloodGroup,
    this.dateOfBirth,
    this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'district': district, // Added field
      'online_reg_no': onlineRegNo,
      'blood_group': bloodGroup,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'age': age,
    };
  }
}
