class RadiosModel {
  int? status;
  Response? response;

  RadiosModel({this.status, this.response});

  RadiosModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    response = json['response'] != null
        ? new Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.response != null) {
      data['response'] = this.response!.toJson();
    }
    return data;
  }
}

class Response {
  List<Hits>? hits;
  int? total;

  Response({this.hits, this.total});

  Response.fromJson(Map<String, dynamic> json) {
    if (json['hits'] != null) {
      hits = <Hits>[];
      json['hits'].forEach((v) {
        hits!.add(new Hits.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.hits != null) {
      data['hits'] = this.hits!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class Hits {
  String? key;
  String? name;
  String? stream;
  String? website;
  String? genre;
  String? logo;
  String? language;
  String? country;
  String? city;
  String? description;

  Hits(
      {this.key,
        this.name,
        this.stream,
        this.website,
        this.genre,
        this.logo,
        this.language,
        this.country,
        this.city,
        this.description});

  Hits.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    stream = json['stream'];
    website = json['website'];
    genre = json['genre'];
    logo = json['logo'];
    language = json['language'];
    country = json['country'];
    city = json['city'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['stream'] = this.stream;
    data['website'] = this.website;
    data['genre'] = this.genre;
    data['logo'] = this.logo;
    data['language'] = this.language;
    data['country'] = this.country;
    data['city'] = this.city;
    data['description'] = this.description;
    return data;
  }
}
