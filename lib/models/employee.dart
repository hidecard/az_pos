class Employee {
  final int id;
  final String name;
  final String role;
  final String username;
  final String password;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.username,
    required this.password,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'username': username,
      'password': password,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      username: map['username'],
      password: map['password'],
      isActive: map['isActive'] == 1,
    );
  }
}
