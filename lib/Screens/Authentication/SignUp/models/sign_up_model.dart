class SignUpModel {
  String? successTopMessage;
  String? successMessage;
  String? username;
  String? email;
  UserData? userData;

  SignUpModel({this.successTopMessage, this.successMessage,this.username, this.email, this.userData});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    successTopMessage = json['successTopMessage'];
    successMessage = json['successMessage'];

    username = json['username'];
    email = json['email'];
    userData = json['userData'] != null
        ? UserData.fromJson(json['userData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['successTopMessage'] = successTopMessage;
    data['successMessage'] = successMessage;
    data['username'] = username;
    data['email'] = email;
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }
}

class UserData {
  String? firstName;
  String? middleName;
  String? lastName;
  String? email;
  String? yearGroup;
  String? about;
  String? createdTime;

  UserData(
      {this.firstName,
        this.middleName,
        this.lastName,
        this.email,
        this.yearGroup,
        this.about,
        this.createdTime});

  UserData.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    email = json['email'];
    yearGroup = json['yearGroup'];
    about = json['about'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['middleName'] = middleName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['yearGroup'] = yearGroup;
    data['about'] = about;
    data['createdTime'] = createdTime;
    return data;
  }
}
