import 'dart:convert';

import 'package:wellkins/models/project_model.dart';

String favoriteToJson(GetFavorite data) => json.encode(data.toJson());
String addFavoriteToJson(FavoriteData data) => json.encode(data.toJson());
String removeFavoriteToJson(RemoveFavorite data) => json.encode(data.toJson());

List<TempFav> tempFavFromJson(dynamic data) {
  final favorites = data["getAllFavourites"]["rows"];
  return List<TempFav>.from(favorites.map((x) => TempFav.fromJson(x)));
}

class Favorite {
  int id;
  Project project;
  Favorite({required this.id, required this.project});
}

class TempFav {
  int favId;
  int propId;
  TempFav({required this.favId, required this.propId});
  factory TempFav.fromJson(Map<String, dynamic> json) => TempFav(
        favId: json["id"],
        propId: json["prop_id"],
      );
}

// tojson
class GetFavorite {
  String userId;
  GetFavorite({required this.userId});
  Map<String, dynamic> toJson() => {"user_id": userId};
}

class FavoriteData {
  AddFavourite addFavourite;
  FavoriteData({required this.addFavourite});
  Map<String, dynamic> toJson() => {"favourite": addFavourite.toJson()};
}

class AddFavourite {
  String userId;
  int propId;
  AddFavourite({required this.userId, required this.propId});
  Map<String, dynamic> toJson() => {"user_id": userId, "prop_id": propId};
}

class RemoveFavorite {
  int id;
  RemoveFavorite({required this.id});
  Map<String, dynamic> toJson() => {"id": id};
}
