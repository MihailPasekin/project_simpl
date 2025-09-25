class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final map = {
      "name": name,
      "email": email,
      "password": password,
      "avatar": avatar,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
    if (id != null) map["id"] = id as String?;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      password: map["password"],
      avatar: map["avatar"],
      createdAt: DateTime.parse(map["createdAt"]),
      updatedAt: DateTime.parse(map["updatedAt"]),
    );
  }
  User copyWithUpdatedAt(DateTime newUpdatedAt) {
    return User(
      id: id,
      name: name,
      email: email,
      password: password,
      avatar: avatar,
      createdAt: createdAt,
      updatedAt: newUpdatedAt,
    );
  }
}
