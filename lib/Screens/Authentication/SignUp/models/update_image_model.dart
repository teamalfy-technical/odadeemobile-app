class UpdateImageModel {
  String? message;
  UserData? userData;

  UpdateImageModel({this.message, this.userData});

  UpdateImageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    userData = json['userData'] != null
        ? UserData.fromJson(json['userData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }
}

class UserData {
  String? firstName;
  String? lastName;
  String? email;
  String? yearGroup;
  String? image;
  bool? isVerified;
  bool? hasImage;
  bool? hasBio;

  UserData(
      {this.firstName,
        this.lastName,
        this.email,
        this.yearGroup,
        this.image,
        this.isVerified,
        this.hasImage,
        this.hasBio});

  UserData.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    yearGroup = json['yearGroup'];
    image = json['image'];
    isVerified = json['is_verified'];
    hasImage = json['has_image'];
    hasBio = json['has_bio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['yearGroup'] = yearGroup;
    data['image'] = image;
    data['is_verified'] = isVerified;
    data['has_image'] = hasImage;
    data['has_bio'] = hasBio;
    return data;
  }
}
