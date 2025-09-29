class Traveller {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final List<dynamic>? bookings;
  final String? joinDate;
  final String? subscriptionStatus;

  Traveller({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.bookings,
    this.joinDate,
    this.subscriptionStatus,
  });

  factory Traveller.fromFirestore(String id, Map<String, dynamic> data) {
    final phoneRaw = data['phoneNumber'];
    return Traveller(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: phoneRaw is String ? phoneRaw : (phoneRaw?.toString() ?? ''),
      profileImage: data['profileImage'],
      bookings:
          data.containsKey('bookings')
              ? data['bookings'] as List<dynamic>?
              : null,
      joinDate: data['joinDate'],
      subscriptionStatus: data['subscriptionStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (profileImage != null) 'profileImage': profileImage,
      if (bookings != null) 'bookings': bookings,
      if (joinDate != null) 'joinDate': joinDate,
      if (subscriptionStatus != null) 'subscriptionStatus': subscriptionStatus,
    };
  }

  Traveller copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImage,
    List<dynamic>? bookings,
    String? joinDate,
    String? subscriptionStatus,
  }) {
    return Traveller(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      bookings: bookings ?? this.bookings,
      joinDate: joinDate ?? this.joinDate,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}
