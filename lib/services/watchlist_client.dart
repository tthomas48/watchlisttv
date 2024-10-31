import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:watchlisttv/services/token_service.dart';

import '../env/env.dart';
import '../model/item.dart';
import '../model/play.dart';
import '../model/watchlist.dart';
import '../model/watchlist_sort.dart';

class WatchlistClient {
  final Dio client;
  final TokenService tokenService;

  static Dio CreateDefaultClient(cookieJar) {
    // TODO: You can put this baseUrl in the clients
    final c = Dio(BaseOptions(
      baseUrl: "${Env.watchlistBase}/api",
    ));
    c.interceptors.add(CookieManager(cookieJar));
    return c;
  }

  WatchlistClient({required this.client, required this.tokenService});

  Future<bool> authorize() async {
    final accessToken = await tokenService.getAccessToken();
    if (accessToken?.isEmpty ?? true) {
      return false;
    }
    // final formData = FormData.fromMap({
    //   'token': accessToken,
    // });
    final response = await client.post('/auth/device',
        data: "token=$accessToken",
        options: Options(
          validateStatus: (int? statusCode) => true,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
          },
        ));
    if (response.statusCode == 401) {
      return false;
    }
    if (response.statusCode != 200) {
      throw Exception(
          'cannot authorize device with watchlist api ${response.statusCode}');
    }
    return true;
  }

  Future<List<Item>> getList(String? listId,
  {String username = "me", WatchlistSort? sort, bool showHidden = false}) async {
    List<Item> items = [];
    if (listId == null) {
      return items;
    }
    Map<String, dynamic> queryParams = Map<String, dynamic>();
    String sortParam = "least-watched";
    if (sort != null) {
      switch(sort) {
        case WatchlistSort.AlphaAsc:
          sortParam = 'alpha-asc';
          break;
        case WatchlistSort.AlphaDesc:
          sortParam = 'alpha-desc';
          break;
        case WatchlistSort.WatchedDesc:
          sortParam = 'most-watched';
          break;
        case WatchlistSort.WatchedAsc:
          sortParam = 'least-watched';
          break;
      }
    }
    queryParams["sort"] = sortParam;
    if (showHidden) {
      queryParams["hidden"] = "true";
    }
    print('/watchlist/$username/$listId/');
    final response = await client.get('/watchlist/$username/$listId/', queryParameters: queryParams);
    print(response.data.length);
    print(items.length);
    response.data.forEach((value) => {
      items.add(Item(value))
    });
    return items;
  }

  Future<List<Watchlist>> getLists() async {
    final response = await client.get('/lists/');

    List<Watchlist> lists = [];

    response.data.forEach((value) => {
      lists.add(Watchlist(value))
    });
    return lists;
  }

  Future<List<Item>> refresh(String? listId,
      {String username = "me"}) async {
    final response = await client.get('/watchlist/$username/$listId');

    List<Item> lists = [];

    response.data.forEach((value) => {
      lists.add(Item(value))
    });
    return lists;
  }


  Future<Play> play(int itemId) async {
    final response = await client.post('/play/device-googletv/$itemId/');
    return Play(response.data);
  }
}
