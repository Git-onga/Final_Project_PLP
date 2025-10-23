class UserModel {
    final String id;
    final String name;
    final String email;
    final String? profileImage;
    final String university;

    UserModel({
        required this.id,
        required this.name,
        required this.email,
        this.profileImage,
        required this.university,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) {
        return UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profileImage: json['profileImage'],
        university: json['university'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
        'id': id,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'university': university,
        };
    }
}