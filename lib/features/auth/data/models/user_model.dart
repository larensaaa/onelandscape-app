// features/auth/data/models/user_model.dart

class UserLevel {
  final int? id;
  final String name;
  final String? description;

  UserLevel({
    this.id, 
    required this.name,
    this.description,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    print('DEBUG UserLevel.fromJson: JSON -> $json');
    
    final userLevel = UserLevel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
    
    print('DEBUG UserLevel.fromJson: Created -> id=${userLevel.id}, name=${userLevel.name}');
    return userLevel;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'UserLevel{id: $id, name: $name, description: $description}';
  }
}

class User {
  final int id;
  final String name;
  final String? email;
  final String? emailVerifiedAt;
  final int? userLevelId;
  final UserLevel? userLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    this.email,
    this.emailVerifiedAt,
    this.userLevelId,
    this.userLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('DEBUG User.fromJson: Full JSON -> $json');
    
    UserLevel? parsedUserLevel;
    
    // Parse user_level dari response API
    final userLevelData = json['user_level']; // Sesuai dengan response API
    print('DEBUG User.fromJson: user_level data -> $userLevelData');

    if (userLevelData != null && userLevelData is Map<String, dynamic>) {
      try {
        parsedUserLevel = UserLevel.fromJson(userLevelData);
        print('DEBUG User.fromJson: Successfully parsed UserLevel -> ${parsedUserLevel.name}');
      } catch (e) {
        print('ERROR User.fromJson: Failed to parse UserLevel -> $e');
      }
    } else {
      print('DEBUG User.fromJson: user_level is null or not a Map');
    }
    
    final user = User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      userLevelId: json['user_level_id'],
      userLevel: parsedUserLevel,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
    
    print('DEBUG User.fromJson: Final User -> id=${user.id}, name=${user.name}, userLevel=${user.userLevel}');
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'user_level_id': userLevelId,
      'user_level': userLevel?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getter untuk mendapatkan role dengan mudah
  String get role => userLevel?.name.toLowerCase() ?? '';
  
  // Getter untuk mengecek apakah user adalah admin
  bool get isAdmin => role == 'admin';
  
  // Getter untuk mengecek apakah user adalah supervisor  
  bool get isSupervisor => role == 'supervisor';
  
  // Getter untuk mengecek apakah user adalah user biasa
  bool get isUser => role == 'user';

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, userLevel: $userLevel}';
  }
}