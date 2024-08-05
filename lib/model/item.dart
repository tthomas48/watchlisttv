class Item {
  late int id;
  late String title;
  late String? sortableTitle;
  late String? traktId;
  late String? traktListId;
  late String? mediaType;
  late bool? hidden;
  late bool? local;
  late String? webUrl;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late String? comment;
  late String? image;

  Item(Map<String, dynamic> map) {
    id = map["id"];
    title = map["title"];
    sortableTitle = map['sortable_title'];
    traktId = map['trakt_id'];
    traktListId = map['trakt_list_id'];
    mediaType = map['media_type'];
    comment = map['comment'];
    image = map['image'];
    hidden = map['hidden'];
    local = map['local'];
    webUrl = map['web_url'];
    createdAt = DateTime.parse(map['createdAt']);
    updatedAt = DateTime.parse(map['createdAt']);
  }
}