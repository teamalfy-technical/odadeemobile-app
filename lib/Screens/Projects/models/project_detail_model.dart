class ProjectDetailModel {
  Projects? projects;

  ProjectDetailModel({this.projects});

  ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    projects = json['projects'] != null
        ? Projects.fromJson(json['projects'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (projects != null) {
      data['projects'] = projects!.toJson();
    }
    return data;
  }
}

class Projects {
  int? id;
  String? title;
  String? slug;
  int? categoryId;
  String? content;
  String? status;
  String? startDate;
  String? endDate;
  int? userId;
  int? yeargroup;
  String? image;
  int? fundingTarget;
  double? fundingTargetDollar;
  String? currentFunding;
  String? progress;
  String? homePage;
  int? forumId;
  String? createdTime;

  Projects(
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
        this.homePage,
        this.forumId,
        this.createdTime});

  Projects.fromJson(Map<String, dynamic> json) {
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
    homePage = json['homePage'];
    forumId = json['forumId'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['categoryId'] = categoryId;
    data['content'] = content;
    data['status'] = status;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['userId'] = userId;
    data['yeargroup'] = yeargroup;
    data['image'] = image;
    data['fundingTarget'] = fundingTarget;
    data['fundingTargetDollar'] = fundingTargetDollar;
    data['currentFunding'] = currentFunding;
    data['progress'] = progress;
    data['homePage'] = homePage;
    data['forumId'] = forumId;
    data['createdTime'] = createdTime;
    return data;
  }
}
