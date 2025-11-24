import 'dart:convert';

User userFromJson(dynamic str, String exp) => User.fromJson(str, exp);
String updateUserToJson(UpdatedUser data) => json.encode(data.toJson());
String updateImageToJson(UpdatedImage data) => json.encode(data.toJson());
String changeUserPassToJson(ChangedUserPass data) => json.encode(data.toJson());

class User {
  final String id;
  final String clientId;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String contactNo;
  final String type;
  final bool isDelete;
  final String accessToken;
  final String tokenExpiry;

  User({
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNo,
    required this.type,
    required this.isDelete,
    required this.accessToken,
    this.tokenExpiry = '',
    this.id = '',
    this.image = '',
  });

  factory User.fromJson(Map<String, dynamic> json, String tokenExp) {
    final user = json["user"] ?? json["createUser"] ?? ["userdetails"];

    final fullName = user["full_name"];
    List<String> nameParts = fullName.split(" ");
    final firstName = nameParts[0];
    final lastName = nameParts.sublist(1).join(" ");
    final exp = tokenExp;

    return User(
      id: '${user["id"]}',
      clientId: '${user["client_id"]}',
      firstName: firstName,
      lastName: lastName,
      email: user["client_email"],
      image: user["client_image"] ?? '',
      contactNo: user["contact_no"],
      type: '${user["client_type"]}',
      isDelete: user["isDelete"],
      accessToken: json["accessToken"],
      tokenExpiry: exp,
    );
  }
}

//UpdateUser
class UpdatedUser {
  UpdatedClient updatedClient;

  UpdatedUser({required this.updatedClient});

  Map<String, dynamic> toJson() => {"client": updatedClient.toJson()};

  UpdatedUser copyWith({UpdatedClient? updatedClient}) {
    return UpdatedUser(updatedClient: updatedClient ?? this.updatedClient);
  }
}

class UpdatedClient {
  final String id;
  final String fullName;
  final String image;
  final String imageName;
  final String imgType;

  UpdatedClient({
    required this.id,
    required this.fullName,
    this.image = '',
    this.imageName = '',
    this.imgType = '',
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    if (fullName.isNotEmpty) "full_name": fullName,
    if (imageName.isNotEmpty) "client_image": imageName,
  };

  UpdatedClient copyWith({
    String? id,
    String? fullName,
    String? image,
    String? imageName,
    String? imgType,
  }) {
    return UpdatedClient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      image: image ?? this.image,
      imageName: imageName ?? this.imageName,
      imgType: imgType ?? this.imgType,
    );
  }

  @override
  String toString() {
    return 'UpdatedClient(id: $id, fullName: $fullName, image: $image, imageName: $imageName, imgType: $imgType)';
  }
}

class UpdatedImage {
  final String clientId;
  final String image;
  final String imageName;
  UpdatedImage({
    required this.clientId,
    required this.image,
    required this.imageName,
  });
  Map<String, dynamic> toJson() => {"id": clientId};
}

//ChangeUserPass
class ChangedUserPass {
  UpdatedPass updatedPass;
  ChangedUserPass({required this.updatedPass});
  Map<String, dynamic> toJson() => {"client": updatedPass.toJson()};
}

class UpdatedPass {
  String email;
  String oldPassword;
  String newPassword;

  UpdatedPass({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "old_password": oldPassword,
    "new_password": newPassword,
  };
}
