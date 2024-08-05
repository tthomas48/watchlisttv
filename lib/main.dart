import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watchlisttv/pages/home.page.dart';
import 'package:watchlisttv/pages/login.page.dart';
import 'package:watchlisttv/services/token_service.dart';
import 'package:watchlisttv/services/trakt_client.dart';
import 'package:watchlisttv/services/watchlist_client.dart';
import 'package:watchlisttv/theme/theme_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final cookieJar = CookieJar();
    final tokenService = TokenService();
    final traktClient = TraktClient(
        client: TraktClient.CreateDefaultClient(), tokenService: tokenService);
    final watchlistClient = WatchlistClient(
        client: WatchlistClient.CreateDefaultClient(cookieJar),
        tokenService: tokenService);

    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: MaterialApp(
            title: 'Watchlist TV',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // TRY THIS: Try running your application with "flutter run". You'll see
              // the application has a purple toolbar. Then, without quitting the app,
              // try changing the seedColor in the colorScheme below to Colors.green
              // and then invoke "hot reload" (save your changes or press the "hot
              // reload" button in a Flutter-supported IDE, or press "r" if you used
              // the command line to start the app).
              //
              // Notice that the counter didn't reset back to zero; the application
              // state is not lost during the reload. To reset the state, use hot
              // restart instead.
              //
              // This works for code too, not just values: Most code changes can be
              // tested with just a hot reload.
              colorScheme: ColorScheme.fromSeed(
                  seedColor: ThemeColors.primaryColor),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) =>
                  HomePage(title: 'Watchlist',
                      client: watchlistClient,
                      cookieJar: cookieJar),
              '/login': (context) =>
                  LoginPage(title: 'Login',
                      traktClient: traktClient,
                      tokenService: tokenService),
            }
          // home: const MyHomePage(title: 'Watchlist'),
        ));
  }
}

