class RadiosModel {
  int? status;
  Response? response;

  RadiosModel({this.status, this.response});

  RadiosModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    response = json['response'] != null
        ? Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (response != null) {
      data['response'] = response!.toJson();
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
        hits!.add(Hits.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (hits != null) {
      data['hits'] = hits!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['name'] = name;
    data['stream'] = stream;
    data['website'] = website;
    data['genre'] = genre;
    data['logo'] = logo;
    data['language'] = language;
    data['country'] = country;
    data['city'] = city;
    data['description'] = description;
    return data;
  }
}
