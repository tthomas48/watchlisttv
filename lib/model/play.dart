class Play {
  late String uri;
  late String message;
  late String? data;
  late String? component;

  Play(Map<String, dynamic> map) {
    uri = map['uri'];
    message = map['message'];
    data = map['data'];
    component = map['component'];
  }
}