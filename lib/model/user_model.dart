class UserDataModel {
  late String name;
  late String email;
  late String image;
  late String uId;
  late String about;

  UserDataModel({
    required this.name,
    required this.email,
    required this.image,
    required this.uId,
    required this.about,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    image = json['image'];
    uId = json['uId'];
    about = json['about'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'uId': uId,
      'about': about,
    };
  }
}
