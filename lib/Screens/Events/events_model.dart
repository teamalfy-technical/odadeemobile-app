class AllEventsModel {
  Events? events;

  AllEventsModel({this.events});

  AllEventsModel.fromJson(Map<String, dynamic> json) {
    events =
    json['events'] != null ? Events.fromJson(json['events']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (events != null) {
      data['events'] = events!.toJson();
    }
    return data;
  }
}

class Events {
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
  Null prevPageUrl;
  int? to;
  int? total;

  Events(
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

  Events.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? userId;
  String? invite;
  int? yeargroup;
  String? title;
  String? slug;
  String? content;
  String? startDate;
  String? endDate;
  String? allDay;
  int? categoryId;
  String? homePage;
  String? createdTime;

  Data(
      {this.id,
        this.userId,
        this.invite,
        this.yeargroup,
        this.title,
        this.slug,
        this.content,
        this.startDate,
        this.endDate,
        this.allDay,
        this.categoryId,
        this.homePage,
        this.createdTime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    invite = json['invite'];
    yeargroup = json['yeargroup'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    allDay = json['allDay'];
    categoryId = json['categoryId'];
    homePage = json['homePage'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['invite'] = invite;
    data['yeargroup'] = yeargroup;
    data['title'] = title;
    data['slug'] = slug;
    data['content'] = content;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['allDay'] = allDay;
    data['categoryId'] = categoryId;
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
