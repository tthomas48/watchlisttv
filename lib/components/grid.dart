import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';

import '../model/item.dart';
import '../services/watchlist_client.dart';
import 'grid_item.dart';

class Grid extends StatelessWidget {
  final List<Item> items;

  final CookieJar cookieJar;

  final WatchlistClient watchlistClient;

  const Grid({super.key, required this.items, required this.cookieJar, required this.watchlistClient});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: (3 / 4),
        crossAxisCount: 6, // Number of columns
        mainAxisSpacing: 6.0, // Vertical space between items
        crossAxisSpacing: 6.0, // Horizontal space between items
      ),
      itemCount: items.length ?? 0,
      itemBuilder: (context, index) {
        return GridItem(item: items[index], cookieJar: cookieJar, watchlistClient: watchlistClient, key: Key('wl-${items[index].id}'));
      },
    );
  }
}