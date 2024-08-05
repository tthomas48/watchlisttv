import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/grid.dart';
import '../model/item.dart';
import '../model/watchlist.dart';
import '../model/watchlist_sort.dart';
import '../services/watchlist_client.dart';
import '../theme/theme_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.title,
      required this.client,
      required this.cookieJar});

  final String title;

  final WatchlistClient client;

  final CookieJar cookieJar;

  @override
  _HomePageState createState() => _HomePageState(title, cookieJar, client);
}

class _HomePageState extends State<HomePage> {
  final String title;

  final WatchlistClient client;

  final CookieJar cookieJar;

  String? _selectedList;

  WatchlistSort? _watchlistSort;

  _HomePageState(this.title, this.cookieJar, this.client);

  Future<List<Item>?> fetchItems(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var selectedList = prefs.getString('trakt.list');
    if (selectedList != _selectedList) {
      setState(() {
        _selectedList = selectedList;
      });
      // will this trigger an update?
      return [];
    }
    WatchlistSort? selectedWatchList;
    final watchlistSort = prefs.getString("watchlist.sort");
    if (watchlistSort != null) {
      selectedWatchList =
          EnumToString.fromString(WatchlistSort.values, watchlistSort);
    } else {
      selectedWatchList = WatchlistSort.WatchedAsc;
    }
    if (_watchlistSort != selectedWatchList) {
      setState(() {
        _watchlistSort = selectedWatchList;
      });
    }

    final authorized = await client.authorize();
    if (!authorized) {
      // redirect
      Navigator.pushNamed(context, '/login');
      return null;
    }
    if (_selectedList == null) {
      return [];
    }
    print('get list');
    final items = await client.getList(_selectedList, username: 'me', sort: _watchlistSort);
    print(items[0].title);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.accentColor,
        title: Text(title),
        actions: <Widget>[
          _getListComponent(context),
          _getSortComponent(context),
          IconButton(
            icon: const Icon(
              Icons.check,
              // color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              // color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          )
        ],
      ),
      body: FutureBuilder<List<Item>?>(
          future: fetchItems(context),
          builder: (buildContext, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text(snapshot.error?.toString() ?? "Unknown Error"));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Grid(
                  items: snapshot.data ?? [],
                  cookieJar: cookieJar,
                  watchlistClient: client),
            );
          }),
    );
  }

  Future<List<Watchlist>?> _fetchWatchlists(BuildContext context) async {
    final authorized = await client.authorize();
    if (!authorized) {
      // redirect
      Navigator.pushNamed(context, '/login');
      return null;
    }
    stdout.writeln('get lists');
    final watchlists = await client.getLists();
    return watchlists;
  }

  void toggleNextSort() async {
    WatchlistSort newSort;
    switch(_watchlistSort) {
      case WatchlistSort.AlphaAsc:
        newSort = WatchlistSort.AlphaDesc;
        break;
      case WatchlistSort.AlphaDesc:
        newSort = WatchlistSort.WatchedAsc;
        break;
      case WatchlistSort.WatchedDesc:
        newSort = WatchlistSort.AlphaAsc;
        break;
      case WatchlistSort.WatchedAsc:
        newSort = WatchlistSort.WatchedDesc;
        break;
      default:
        newSort = WatchlistSort.WatchedDesc;
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('watchlist.sort', EnumToString.convertToString(newSort));
    setState(() {
      _watchlistSort = newSort;
    });
  }

  Widget _getSortComponent(BuildContext context) {
    IconData mainIcon;
    IconData subIcon;
    switch(_watchlistSort) {

      case WatchlistSort.AlphaAsc:
        mainIcon = Icons.abc;
        subIcon = Icons.arrow_upward;
        break;
      case WatchlistSort.AlphaDesc:
        mainIcon = Icons.abc;
        subIcon = Icons.arrow_downward;
        break;
      case WatchlistSort.WatchedDesc:
        mainIcon = Icons.visibility;
        subIcon = Icons.arrow_downward;
        break;
      case WatchlistSort.WatchedAsc:
        mainIcon = Icons.visibility;
        subIcon = Icons.arrow_upward;
        break;
      default:
        mainIcon = Icons.visibility;
        subIcon = Icons.arrow_upward;
        break;
    }

    return Focus(
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event.logicalKey != LogicalKeyboardKey.select) {
            return KeyEventResult.ignored;
          }
          if (event is KeyDownEvent) {
            toggleNextSort();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        onFocusChange: (hasFocus) {
          print("Focused");
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(
          icon: Icon(mainIcon),
          isSelected: true,
          onPressed: () {
            toggleNextSort();
          },
        ),
          Icon(subIcon, size: 10),
        ]));
  }

  Widget _getListComponent(BuildContext context) {
    return FutureBuilder<List<Watchlist>?>(
        future: _fetchWatchlists(context),
        builder: (buildContext, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(snapshot.error?.toString() ?? "Unknown Error"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Row(children: [
            DropdownButton<String>(
              hint: const Text('Pick a list'),
              value: _selectedList,
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('trakt.list', newValue);
                }
                setState(() {
                  _selectedList = newValue;
                });
              },
              items: (snapshot.data ?? [])
                  .map<DropdownMenuItem<String>>((Watchlist watchlist) {
                return DropdownMenuItem<String>(
                  value: watchlist.id,
                  child: Text(watchlist.name),
                );
              }).toList(),
            ),
          ]);
        });
  }
}
