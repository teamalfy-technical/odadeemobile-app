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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (news != null) {
      data['news'] = news!.toJson();
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
        data!.add(Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Data {
  String? id;
  String? title;
  String? slug;
  String? content;
  String? summary;
  String? video;
  String? image;
  String? userId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['content'] = content;
    data['summary'] = summary;
    data['video'] = video;
    data['image'] = image;
    data['userId'] = userId;
    data['yeargroup'] = yeargroup;
    data['yearmonth'] = yearmonth;
    data['admin'] = admin;
    data['sticky'] = sticky;
    data['homePage'] = homePage;
    data['createdTime'] = createdTime;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}
