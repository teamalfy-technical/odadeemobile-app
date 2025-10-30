class AllProjectsModel {
  Projects? projects;

  AllProjectsModel({this.projects});

  AllProjectsModel.fromJson(Map<String, dynamic> json) {
    if (json['projects'] != null) {
      // Handle both direct array and paginated response
      if (json['projects'] is List) {
        // Direct array format: {"projects": [...]}
        projects = Projects(data: (json['projects'] as List).map((v) => Data.fromJson(v)).toList());
      } else {
        // Paginated format: {"projects": {"current_page": 1, "data": [...]}}
        projects = Projects.fromJson(json['projects']);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.projects != null) {
      data['projects'] = this.projects!.toJson();
    }
    return data;
  }
}

class Projects {
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

  Projects(
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

  Projects.fromJson(Map<String, dynamic> json) {
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
  String? title;
  String? slug;
  String? categoryId;
  String? content;
  String? status;
  String? startDate;
  String? endDate;
  String? userId;
  int? yeargroup;
  String? image;
  String? fundingTarget;
  String? fundingTargetDollar;
  String? currentFunding;
  String? progress;
  String? currency;
  String? homePage;
  String? forumId;
  String? createdTime;

  Data(
      {this.id,
        this.title,
        this.slug,
        this.categoryId,
        this.content,
        this.status,
        this.startDate,
        this.endDate,
        this.userId,
        this.yeargroup,
        this.image,
        this.fundingTarget,
        this.fundingTargetDollar,
        this.currentFunding,
        this.progress,
        this.currency,
        this.homePage,
        this.forumId,
        this.createdTime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    categoryId = json['categoryId'];
    content = json['content'];
    status = json['status'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    userId = json['userId'];
    yeargroup = json['yeargroup'];
    image = json['image'];
    fundingTarget = json['fundingTarget'];
    fundingTargetDollar = json['fundingTargetDollar'];
    currentFunding = json['currentFunding'];
    progress = json['progress'];
    currency = json['currency'];
    homePage = json['homePage'];
    forumId = json['forumId'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['categoryId'] = this.categoryId;
    data['content'] = this.content;
    data['status'] = this.status;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['userId'] = this.userId;
    data['yeargroup'] = this.yeargroup;
    data['image'] = this.image;
    data['fundingTarget'] = this.fundingTarget;
    data['fundingTargetDollar'] = this.fundingTargetDollar;
    data['currentFunding'] = this.currentFunding;
    data['progress'] = this.progress;
    data['currency'] = this.currency;
    data['homePage'] = this.homePage;
    data['forumId'] = this.forumId;
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
