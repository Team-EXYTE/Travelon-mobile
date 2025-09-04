class Traveller {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<dynamic>? bookings;

  Traveller({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.bookings,
  });

  factory Traveller.fromFirestore(String id, Map<String, dynamic> data) {
    return Traveller(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
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
      if (bookings != null) 'bookings': bookings,
    };
  }
}
