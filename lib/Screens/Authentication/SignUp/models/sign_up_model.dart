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
        ? new UserData.fromJson(json['userData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['successTopMessage'] = this.successTopMessage;
    data['successMessage'] = this.successMessage;
    data['username'] = this.username;
    data['email'] = this.email;
    if (this.userData != null) {
      data['userData'] = this.userData!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['middleName'] = this.middleName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['yearGroup'] = this.yearGroup;
    data['about'] = this.about;
    data['createdTime'] = this.createdTime;
    return data;
  }
}
