class UpdateBioModel {
  String? message;
  String? error;
  UserData? userData;

  UpdateBioModel({this.message, this.error, this.userData});

  UpdateBioModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    userData = json['userData'] != null
        ? new UserData.fromJson(json['userData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    if (this.userData != null) {
      data['userData'] = this.userData!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['yearGroup'] = this.yearGroup;
    data['image'] = this.image;
    data['is_verified'] = this.isVerified;
    data['has_image'] = this.hasImage;
    data['has_bio'] = this.hasBio;
    return data;
  }
}
