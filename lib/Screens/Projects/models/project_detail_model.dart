import '../../../utils/image_url_helper.dart';

class ProjectDetailModel {
  Projects? projects;

  ProjectDetailModel({this.projects});

  ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    projects = json['projects'] != null
        ? new Projects.fromJson(json['projects'])
        : null;
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
    image = ImageUrlHelper.normalizeImageUrl(json['image']);
    fundingTarget = json['fundingTarget'];
    fundingTargetDollar = json['fundingTargetDollar'];
    currentFunding = json['currentFunding'];
    progress = json['progress'];
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
    data['homePage'] = this.homePage;
    data['forumId'] = this.forumId;
    data['createdTime'] = this.createdTime;
    return data;
  }
}
