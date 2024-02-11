class User {
  String? _userId;
  String? _name;
  String? _email;
  String? _password;

  User({String? userId, String? name, String? email, String? password}) {
    if (userId != null) {
      _userId = userId;
    }
    if (name != null) {
      _name = name;
    }
    if (email != null) {
      _email = email;
    }
    if (password != null) {
      _password = password;
    }
  }

  String? get userId => _userId;
  set userId(String? userId) => _userId = userId;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get password => _password;
  set password(String? password) => _password = password;

  User.fromJson(Map<String, dynamic> json) {
    _userId = json['userId'];
    _name = json['name'];
    _email = json['email'];
    _password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = _userId;
    data['name'] = _name;
    data['email'] = _email;
    data['password'] = _password;
    return data;
  }
}
