import 'package:envied/envied.dart';

part "env.g.dart";

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'TRAKT_CLIENT_ID',obfuscate: true)
  static final String traktClientId = _Env.traktClientId;

  @EnviedField(varName: 'TRAKT_CLIENT_SECRET',obfuscate: true)
  static final String traktClientSecret = _Env.traktClientSecret;

  @EnviedField(varName: 'WATCHLIST_API',obfuscate: true)
  static final String watchlistApi = _Env.watchlistApi;
}