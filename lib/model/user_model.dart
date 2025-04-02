class User {
  final String? nickname;
  final String? email;
  final String? password;
  final String? gender;
  final String? preferSports;
  final String? birth;
  final String? region;

  User(
    this.gender,
    this.preferSports,
    this.birth,
    this.region, {
    required this.email,
    required this.nickname,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['gender'],
      json['preferSports'],
      json['birth'],
      json['region'],
      email: json['email'],
      nickname: json['nickname'],
      password: json['password'],
    );
  }
  Map<String, dynamic> toJson() => {
    'email' : email,
    'password' : password,
    'nickname' : nickname,
    'gender' : gender,
    'preferSports' : preferSports,
    'birth' : birth,
    'region' : region
  };
}
