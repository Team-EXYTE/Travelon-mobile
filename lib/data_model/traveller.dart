class Traveller {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImage;
  final List<dynamic>? bookings;

  Traveller({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImage,
    this.bookings,
  });

  factory Traveller.fromFirestore(String id, Map<String, dynamic> data) {
    return Traveller(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      bookings:
          data.containsKey('bookings')
              ? data['bookings'] as List<dynamic>?
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
      if (bookings != null) 'bookings': bookings,
    };
  }

  Traveller copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    List<dynamic>? bookings,
  }) {
    return Traveller(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      bookings: bookings ?? this.bookings,
    );
  }
}
