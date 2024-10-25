class AppUser {
  String? id;
  final String name;
  final String email;
  final String gender;
  final String dob;
  final String? profilePicture;
  final List<String> favouriteGenres;
  final String? quote;
  final String joinedDate;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.dob,
    required this.favouriteGenres,
    this.profilePicture,
    this.quote,
    required this.joinedDate,
  });

  factory AppUser.fromMap(Map<String, dynamic> user) {
    return AppUser(
        id: user['id'] as String?,
        name: user['name'] as String,
        email: user['email'] as String,
        gender: user['gender'] as String,
        dob: user['dob'] as String,
        favouriteGenres: List<String>.from(user['favouriteGenres'] as List),
        profilePicture: user['profilePicture'] as String?,
        quote: user['quote'] as String?,
        joinedDate: user['joinedDate'] as String);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'dob': dob,
      'favouriteGenres': favouriteGenres,
      'profilePicture': profilePicture,
      'quote': quote,
      'joinedDate': joinedDate,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    String? dob,
    List<String>? favouriteGenres,
    String? profilePicture,
    String? quote,
    String? joinedDate,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      favouriteGenres: favouriteGenres ?? this.favouriteGenres,
      profilePicture: profilePicture ?? this.profilePicture,
      quote: quote ?? this.quote,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  @override
  String toString() {
    return 'AppUser{id: $id, name: $name, email: $email, gender: $gender, dob: $dob, '
        'favouriteGenres: $favouriteGenres, profilePicture: $profilePicture, '
        'quote: $quote, joinedDate: $joinedDate}';
  }
}
