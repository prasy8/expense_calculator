class AuthUserModel {
  final int id;
  final String name;
  final String email;

  AuthUserModel({required this.id, required this.name, required this.email}); 
  
  //converting:JSON → AuthUserModel
  factory AuthUserModel.fromJson(Map<String, dynamic> json){
    return AuthUserModel(id: int.tryParse(json['id'].toString()) ?? 0, name: json['name']?.toString() ?? '', email: json['email']?.toString() ?? '');
  }

  //converts: AuthUserModel → JSON-compatible Map
  //it is useful when we want to send the user data back to an API.
  Map<String, dynamic> toJson(){
    return {'id': id, 'name': name, 'email': email,};
  }
}