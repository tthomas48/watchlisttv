class Watchlist {
  late String name;
  late String id;
  // late String? data;
  // late String? component;

  Watchlist(Map<String, dynamic> map) {
    name = map['name'];
    id = map['ids']['trakt'].toString();
  }
}