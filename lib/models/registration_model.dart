class RegistrationModel {
  final String name;
  final String address_line;
  final String district; // Added field
  final String onlineRegNo;
  final String bloodGroup;
  final String mobileNo;
  final String? dateOfBirth;
  final String aadharImage;
  final String profileImage;
  final String? aadharCardNo;

  RegistrationModel({
    required this.name,
    required this.address_line,
    required this.district, // Added parameter
    required this.onlineRegNo,
    required this.bloodGroup,
    required this.mobileNo,
    required this.aadharImage,
    required this.aadharCardNo,
    required this.profileImage,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address_line': address_line,
      'city': district,
      'blood_group': bloodGroup,
      'mobile_one': mobileNo,
      'mobile_two': onlineRegNo,
      'aadhar_number': aadharCardNo,
      'date_of_birth': dateOfBirth,
      'aadhar_image': aadharImage,
      'profile_image': profileImage,
    };
  }
}
