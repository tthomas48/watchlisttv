import 'package:envied/envied.dart';

part "env.g.dart";

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'TRAKT_CLIENT_ID',obfuscate: true)
  static final String traktClientId = _Env.traktClientId;

  @EnviedField(varName: 'TRAKT_CLIENT_SECRET',obfuscate: true)
  static final String traktClientSecret = _Env.traktClientSecret;

  @EnviedField(varName: 'WATCHLIST_BASE',obfuscate: true)
  static final String watchlistBase = _Env.watchlistBase;

  @EnviedField(varName: 'SENTRY_DSN',obfuscate: true)
  static final String sentryDsn = _Env.sentryDsn;
}