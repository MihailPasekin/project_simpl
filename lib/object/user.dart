class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final double monthlyLimit;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.monthlyLimit = 0.0,
    this.avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final map = {
      "name": name,
      "email": email,
      "password": password,
      "monthlyLimit": monthlyLimit,
      "avatar": avatar,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
    if (id != null) map["id"] = id;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"] as int?,
      name: map["name"] as String,
      email: map["email"] as String,
      password: map["password"] as String,
      monthlyLimit: (map["monthlyLimit"] as num).toDouble(),
      avatar: map["avatar"] as String?,
      createdAt: DateTime.parse(map["createdAt"] as String),
      updatedAt: DateTime.parse(map["updatedAt"] as String),
    );
  }
}
