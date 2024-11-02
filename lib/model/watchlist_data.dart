import 'package:watchlisttv/model/watchlist_notification.dart';

import 'item.dart';

class WatchlistData {
  final List<Item> items;
  final Map<int, List<WatchlistNotification>> notifications;

  const WatchlistData(this.items, this.notifications);
}