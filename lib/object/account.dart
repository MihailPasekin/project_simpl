class Account {
  final int? id; // id может быть null при создании нового счета
  final int userId;
  final String name;
  final double balance;
  final String createdAt;
  final String updatedAt;

  Account({
    this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  // Создание Account из Map (SQLite)
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  // Преобразование Account в Map для SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'name': name,
      'balance': balance,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Метод для копирования объекта с обновлёнными полями
  Account copyWith({
    int? id,
    int? userId,
    String? name,
    double? balance,
    String? createdAt,
    String? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
