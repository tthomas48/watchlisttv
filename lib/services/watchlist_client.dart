import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:watchlisttv/services/token_service.dart';

import '../env/env.dart';


class WatchlistClient {
  final Dio client;
  final TokenService tokenService;

  static Dio CreateDefaultClient() {
    // TODO: You can put this baseUrl in the clients
    final c = new Dio(BaseOptions(
      baseUrl: Env.watchlistApi,
    ));
    c.interceptors.add(CookieManager(CookieJar()));
    return c;
  }

  WatchlistClient({required this.client, required this.tokenService});

  Future<bool> authorize() async {
    final accessToken = await tokenService.getAccessToken();
    if (accessToken?.isEmpty ?? false) {
      return false;
    }
    final formData = FormData.fromMap({
      'token': accessToken,
    });
    final response = await client.post(
        '/auth/device',
        data: formData
    );
    if (response.statusCode == 401) {
      return false;
    }
    if (response.statusCode != 200) {
      throw new Exception('cannot authorize device with watchlist api ${response.statusCode}');
    }
    return true;
  }


  Future<Map<String, dynamic>> getList([String username = "me", String listId = "25462957"]) async {
    final response = await client.get('/watchlist/${username}/${listId}/');

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
