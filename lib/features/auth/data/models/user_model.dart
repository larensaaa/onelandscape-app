// features/auth/data/models/user_model.dart

class UserLevel {
  final int? id;
  final String name;

  UserLevel({this.id, required this.name});

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class User {
  final int id;
  final String name;
  // --- PERBAIKAN DI SINI: Tambahkan tanda tanya (?) ---
  final String? email;
  final UserLevel? userLevel;

  User({
    required this.id,
    required this.name,
    this.email, // Hapus 'required'
    this.userLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    UserLevel? parsedUserLevel;
    final userLevelData = json['userLevel'];

    if (userLevelData is Map<String, dynamic>) {
      parsedUserLevel = UserLevel.fromJson(userLevelData);
    } else if (userLevelData is String) {
      parsedUserLevel = UserLevel(name: userLevelData);
    }
    
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'], // <-- Ini sekarang aman jika nilainya null
      userLevel: parsedUserLevel,
    );
  }
}