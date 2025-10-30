class AllUsersModel {
  Users? users;

  AllUsersModel({this.users});

  AllUsersModel.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      // Handle both direct array and paginated response
      if (json['users'] is List) {
        // Direct array format: {"users": [...]}
        users = Users(data: (json['users'] as List).map((v) => Data.fromJson(v)).toList());
      } else {
        // Paginated format: {"users": {"current_page": 1, "data": [...]}}
        users = Users.fromJson(json['users']);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users!.toJson();
    }
    return data;
  }
}

class Users {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Users(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  Users.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Data {
  String? id;
  String? username;
  String? odadeeId;
  String? firstName;
  String? middleName;
  String? lastName;
  String? nickName;
  String? email;
  String? mailSubscribed;
  String? birthDate;
  String? birthMonth;
  String? token;
  String? status;
  String? phone;
  String? pin;
  String? gender;
  String? image;
  String? city;
  String? house;
  String? latitude;
  String? longitude;
  String? zip;
  String? website;
  String? workPlace;
  String? position;
  String? jobTitle;
  String? yearGroup;
  String? about;
  String? userRole;
  String? country;
  String? googleId;
  String? linkedinId;
  String? facebookId;
  String? twitterUrl;
  String? facebookUrl;
  String? googleUrl;
  String? githubUrl;
  String? linkedinUrl;
  String? skypeUrl;
  String? homePage;
  String? isGlobalSecretariat;
  int? loginAttempts;
  String? secondLastLoginIp;
  String? secondLastLogin;
  String? lastLogin;
  String? lastLoginIp;
  String? createdTime;
  List<String>? userInterests;
  List<UserStatus>? userStatus;

  Data(
      {this.id,
        this.username,
        this.odadeeId,
        this.firstName,
        this.middleName,
        this.lastName,
        this.nickName,
        this.email,
        this.mailSubscribed,
        this.birthDate,
        this.birthMonth,
        this.token,
        this.status,
        this.phone,
        this.pin,
        this.gender,
        this.image,
        this.city,
        this.house,
        this.latitude,
        this.longitude,
        this.zip,
        this.website,
        this.workPlace,
        this.position,
        this.jobTitle,
        this.yearGroup,
        this.about,
        this.userRole,
        this.country,
        this.googleId,
        this.linkedinId,
        this.facebookId,
        this.twitterUrl,
        this.facebookUrl,
        this.googleUrl,
        this.githubUrl,
        this.linkedinUrl,
        this.skypeUrl,
        this.homePage,
        this.isGlobalSecretariat,
        this.loginAttempts,
        this.secondLastLoginIp,
        this.secondLastLogin,
        this.lastLogin,
        this.lastLoginIp,
        this.createdTime,
        this.userInterests,
        this.userStatus});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    odadeeId = json['odadeeId'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    nickName = json['nickName'];
    email = json['email'];
    mailSubscribed = json['mailSubscribed'];
    birthDate = json['birthDate'];
    birthMonth = json['birthMonth'];
    token = json['token'];
    status = json['status'];
    phone = json['phone'];
    pin = json['pin'];
    gender = json['gender'];
    image = json['image'];
    city = json['city'];
    house = json['house'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zip = json['zip'];
    website = json['website'];
    workPlace = json['workPlace'];
    position = json['position'];
    jobTitle = json['jobTitle'];
    yearGroup = json['yearGroup'];
    about = json['about'];
    userRole = json['userRole'];
    country = json['country'];
    googleId = json['googleId'];
    linkedinId = json['linkedinId'];
    facebookId = json['facebookId'];
    twitterUrl = json['twitterUrl'];
    facebookUrl = json['facebookUrl'];
    googleUrl = json['googleUrl'];
    githubUrl = json['githubUrl'];
    linkedinUrl = json['linkedinUrl'];
    skypeUrl = json['skypeUrl'];
    homePage = json['homePage'];
    isGlobalSecretariat = json['isGlobalSecretariat'];
    loginAttempts = json['loginAttempts'];
    secondLastLoginIp = json['secondLastLoginIp'];
    secondLastLogin = json['secondLastLogin'];
    lastLogin = json['lastLogin'];
    lastLoginIp = json['lastLoginIp'];
    createdTime = json['createdTime'];
    userInterests = (json['user_interests'] as List<dynamic>?)?.map((dynamic item) => item.toString()).toList();
    if (json['user_status'] != null) {
      userStatus = <UserStatus>[];
      json['user_status'].forEach((v) {
        userStatus!.add(new UserStatus.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['odadeeId'] = this.odadeeId;
    data['firstName'] = this.firstName;
    data['middleName'] = this.middleName;
    data['lastName'] = this.lastName;
    data['nickName'] = this.nickName;
    data['email'] = this.email;
    data['mailSubscribed'] = this.mailSubscribed;
    data['birthDate'] = this.birthDate;
    data['birthMonth'] = this.birthMonth;
    data['token'] = this.token;
    data['status'] = this.status;
    data['phone'] = this.phone;
    data['pin'] = this.pin;
    data['gender'] = this.gender;
    data['image'] = this.image;
    data['city'] = this.city;
    data['house'] = this.house;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['zip'] = this.zip;
    data['website'] = this.website;
    data['workPlace'] = this.workPlace;
    data['position'] = this.position;
    data['jobTitle'] = this.jobTitle;
    data['yearGroup'] = this.yearGroup;
    data['about'] = this.about;
    data['userRole'] = this.userRole;
    data['country'] = this.country;
    data['googleId'] = this.googleId;
    data['linkedinId'] = this.linkedinId;
    data['facebookId'] = this.facebookId;
    data['twitterUrl'] = this.twitterUrl;
    data['facebookUrl'] = this.facebookUrl;
    data['googleUrl'] = this.googleUrl;
    data['githubUrl'] = this.githubUrl;
    data['linkedinUrl'] = this.linkedinUrl;
    data['skypeUrl'] = this.skypeUrl;
    data['homePage'] = this.homePage;
    data['isGlobalSecretariat'] = this.isGlobalSecretariat;
    data['loginAttempts'] = this.loginAttempts;
    data['secondLastLoginIp'] = this.secondLastLoginIp;
    data['secondLastLogin'] = this.secondLastLogin;
    data['lastLogin'] = this.lastLogin;
    data['lastLoginIp'] = this.lastLoginIp;
    data['createdTime'] = this.createdTime;
    data['user_interests'] = this.userInterests;
    if (this.userStatus != null) {
      data['user_status'] = this.userStatus!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserStatus {
  String? id;
  String? status;
  String? attachment;
  String? userId;
  String? createdTime;

  UserStatus(
      {this.id, this.status, this.attachment, this.userId, this.createdTime});

  UserStatus.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    attachment = json['attachment'];
    userId = json['userId'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['attachment'] = this.attachment;
    data['userId'] = this.userId;
    data['createdTime'] = this.createdTime;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
