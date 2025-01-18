class BullTamer {
  final int id;
  final String name;
  final String displayName;
  final String aadharNumber;
  final String addressLine;
  final int age;
  final String bloodGroup;
  final String city;
  final String dateOfBirth;
  final String createDate;
  final String lastUpdate;
  final String writeDate;
  final List<dynamic> createUid;
  final List<dynamic> writeUid;
  final int docCount;
  final String entryStatus;
  final bool hasMessage;
  final int messageAttachmentCount;
  final List<int> messageFollowerIds;
  final bool messageHasError;
  final int messageHasErrorCounter;
  final bool messageHasSmsError;
  final List<int> messageIds;
  final bool messageIsFollower;
  final dynamic messageMainAttachmentId;
  final bool messageNeedaction;
  final int messageNeedactionCounter;
  final List<int> messagePartnerIds;
  final String mobileOne;
  final dynamic mobileTwo;
  final String registrationStatus;
  final dynamic remarks;
  final int sequence;
  final String uuid;

  BullTamer({
    required this.id,
    required this.name,
    required this.displayName,
    required this.aadharNumber,
    required this.addressLine,
    required this.age,
    required this.bloodGroup,
    required this.city,
    required this.dateOfBirth,
    required this.createDate,
    required this.lastUpdate,
    required this.writeDate,
    required this.createUid,
    required this.writeUid,
    required this.docCount,
    required this.entryStatus,
    required this.hasMessage,
    required this.messageAttachmentCount,
    required this.messageFollowerIds,
    required this.messageHasError,
    required this.messageHasErrorCounter,
    required this.messageHasSmsError,
    required this.messageIds,
    required this.messageIsFollower,
    required this.messageMainAttachmentId,
    required this.messageNeedaction,
    required this.messageNeedactionCounter,
    required this.messagePartnerIds,
    required this.mobileOne,
    required this.mobileTwo,
    required this.registrationStatus,
    required this.remarks,
    required this.sequence,
    required this.uuid,
  });

  factory BullTamer.fromJson(Map<String, dynamic> json) {
    return BullTamer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      aadharNumber: json['aadhar_number'] ?? '',
      addressLine: json['address_line'] ?? '',
      age: json['age'] ?? 0,
      bloodGroup: json['blood_group'] ?? '',
      city: json['city'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      createDate: json['create_date'] ?? '',
      lastUpdate: json['__last_update'] ?? '',
      writeDate: json['write_date'] ?? '',
      createUid: json['create_uid'] ?? [],
      writeUid: json['write_uid'] ?? [],
      docCount: json['doc_count'] ?? 0,
      entryStatus: json['entry_status'] ?? '',
      hasMessage: json['has_message'] ?? false,
      messageAttachmentCount: json['message_attachment_count'] ?? 0,
      messageFollowerIds: List<int>.from(json['message_follower_ids'] ?? []),
      messageHasError: json['message_has_error'] ?? false,
      messageHasErrorCounter: json['message_has_error_counter'] ?? 0,
      messageHasSmsError: json['message_has_sms_error'] ?? false,
      messageIds: List<int>.from(json['message_ids'] ?? []),
      messageIsFollower: json['message_is_follower'] ?? false,
      messageMainAttachmentId: json['message_main_attachment_id'],
      messageNeedaction: json['message_needaction'] ?? false,
      messageNeedactionCounter: json['message_needaction_counter'] ?? 0,
      messagePartnerIds: List<int>.from(json['message_partner_ids'] ?? []),
      mobileOne: json['mobile_one'] ?? '',
      mobileTwo: json['mobile_two'],
      registrationStatus: json['registration_status'] ?? '',
      remarks: json['remarks'],
      sequence: json['sequence'] ?? 0,
      uuid: json['uuid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'aadhar_number': aadharNumber,
      'address_line': addressLine,
      'age': age,
      'blood_group': bloodGroup,
      'city': city,
      'date_of_birth': dateOfBirth,
      'create_date': createDate,
      '__last_update': lastUpdate,
      'write_date': writeDate,
      'create_uid': createUid,
      'write_uid': writeUid,
      'doc_count': docCount,
      'entry_status': entryStatus,
      'has_message': hasMessage,
      'message_attachment_count': messageAttachmentCount,
      'message_follower_ids': messageFollowerIds,
      'message_has_error': messageHasError,
      'message_has_error_counter': messageHasErrorCounter,
      'message_has_sms_error': messageHasSmsError,
      'message_ids': messageIds,
      'message_is_follower': messageIsFollower,
      'message_main_attachment_id': messageMainAttachmentId,
      'message_needaction': messageNeedaction,
      'message_needaction_counter': messageNeedactionCounter,
      'message_partner_ids': messagePartnerIds,
      'mobile_one': mobileOne,
      'mobile_two': mobileTwo,
      'registration_status': registrationStatus,
      'remarks': remarks,
      'sequence': sequence,
      'uuid': uuid,
    };
  }
}
