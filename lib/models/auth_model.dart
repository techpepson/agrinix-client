class AuthModel {
  AuthModel({required this.email, this.name, required this.password});
  String? name;
  String email;
  String password;

  AuthModel copyWith({String? name, String? email, String? password}) {
    return AuthModel(
      email: email?.trim() ?? this.email.trim(),
      name: name?.trim() ?? this.name?.trim(),
      password: password?.trim() ?? this.password.trim(),
    );
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password.trim(),
      'name': name?.trim(),
    };
  }
}
