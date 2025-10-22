class AllArticlesModel {
  News? news;

  AllArticlesModel({this.news});

  AllArticlesModel.fromJson(Map<String, dynamic> json) {
    if (json['news'] != null) {
      // Handle both direct array and paginated response
      if (json['news'] is List) {
        // Direct array format: {"news": [...]}
        news = News(data: (json['news'] as List).map((v) => Data.fromJson(v)).toList());
      } else {
        // Paginated format: {"news": {"current_page": 1, "data": [...]}}
        news = News.fromJson(json['news']);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.news != null) {
      data['news'] = this.news!.toJson();
    }
    return data;
  }
}

class News {
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

  News(
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

  News.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? title;
  String? slug;
  String? content;
  String? summary;
  String? video;
  String? image;
  int? userId;
  int? yeargroup;
  String? yearmonth;
  String? admin;
  String? sticky;
  String? homePage;
  String? createdTime;

  Data(
      {this.id,
        this.title,
        this.slug,
        this.content,
        this.summary,
        this.video,
        this.image,
        this.userId,
        this.yeargroup,
        this.yearmonth,
        this.admin,
        this.sticky,
        this.homePage,
        this.createdTime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    summary = json['summary'];
    video = json['video'];
    image = json['image'];
    userId = json['userId'];
    yeargroup = json['yeargroup'];
    yearmonth = json['yearmonth'];
    admin = json['admin'];
    sticky = json['sticky'];
    homePage = json['homePage'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['content'] = this.content;
    data['summary'] = this.summary;
    data['video'] = this.video;
    data['image'] = this.image;
    data['userId'] = this.userId;
    data['yeargroup'] = this.yeargroup;
    data['yearmonth'] = this.yearmonth;
    data['admin'] = this.admin;
    data['sticky'] = this.sticky;
    data['homePage'] = this.homePage;
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
