class WatchlistNotification {
  late int id;
  late String message;
  late String traktListId;
  late int watchableId;

  WatchlistNotification(Map<String, dynamic> map) {
    id = map["id"];
    message = map["message"];
    traktListId = map['trakt_list_id'];
    watchableId = map['watchable_id'];
  }
}