import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:trakt_dart/trakt_dart.dart';
import 'package:watchlisttv/services/token_service.dart';

import '../env/env.dart';
import 'cancellation_token.dart';

class TraktClient {
  final TraktManager client;
  final TokenService tokenService;

  static TraktManager CreateDefaultClient(String clientId, String clientSecret) {
    final traktManager = new TraktManager(
      clientId: Env.traktClientId,
      clientSecret: Env.traktClientSecret,
      redirectURI: 'urn:ietf:wg:oauth:2.0:oob',
    );
    return traktManager;
  }

  TraktClient({required this.client, required this.tokenService});

  Future<DeviceCodeResponse> getDeviceCodes() async {
    final res = await client.authentication.generateDeviceCodes();
    return res;
  }

  Future<AccessTokenResponse> pollDevice(CancellationToken cancellationToken, String code, int interval) {
    final Completer<AccessTokenResponse> completer = Completer<AccessTokenResponse>();
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (cancellationToken.isCancelled) {
        timer.cancel();
        completer.completeError("manually cancelled by owner");
        return;
      }

      try {
        client.authentication.getDeviceAccessToken(code).then((res) {
          timer.cancel();
          completer.complete(res);
        });
      } on TraktManagerAPIError catch (e) {
        if (e.statusCode == 400) {
          // pending, just return
          return;
        }
        String errMsg = "unknown error";
        switch(e.statusCode) {
          case 404:
            errMsg = "code not found";
            break;
          case 409:
            errMsg = "code already approved";
            break;
          case 410:
            // TODO: this needs special handling
            errMsg = "code expired";
            break;
          case 418:
            errMsg = "user declined authorization";
            break;
        }
        timer.cancel();
        completer.completeError(errMsg);
      }
    });
    return completer.future;
  }

}