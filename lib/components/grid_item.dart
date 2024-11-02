import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:watchlisttv/components/tv_focus.dart';

import '../env/env.dart';
import '../model/item.dart';
import '../model/watchlist_notification.dart';
import '../services/watchlist_client.dart';
import 'grid_flipcard.dart';

class GridItem extends StatefulWidget {
  final Item item;

  final List<WatchlistNotification>? notifications;

  final CookieJar cookieJar;

  final WatchlistClient watchlistClient;

  const GridItem({super.key,
    required this.item,
    required this.notifications,
    required this.cookieJar,
    required this.watchlistClient});

  @override
  State<StatefulWidget> createState() {
    return _GridItemState();
  }
}

class _GridItemState extends State<GridItem> with TickerProviderStateMixin {
  bool _isFocused = false;

  Future<String> _fetchCookies(String baseImgUrl) async {
    var cookies = await widget.cookieJar.loadForRequest(Uri.parse(baseImgUrl));
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  late final AnimationController _controller;
  late final Animation<double> _animation;

  late final FlipCardController _flipCardController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _flipCardController = FlipCardController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    _flipCardController.toggleCard();
  }

  void _focus() {
    _controller.forward();
    setState(() {
      _isFocused = true;
    });
  }

  void _blur() {
    _controller.reset();
    setState(() {
      _isFocused = false;
    });
  }

  void _play() async {
    var notifications = widget.notifications ?? [];
    for(var i = 0; i < notifications.length; i++) {
      await widget.watchlistClient.clearNotification(
          widget.item.traktListId, notifications[i].id.toString());
    }

    final play = await widget.watchlistClient.play(widget.item.id);
    // TODO: more platforms? can I do web? How would that change longpress?
    if (Platform.isAndroid) {
      String component = play.component ?? "/";
      var s = component.split("/");
      if (s[1][0] == '.') {
        s[1] = s[0] + s[1];
      }

      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: play.data,
        package: s[0],
        componentName: s[1],
        //flags: [0x10808000],
        arguments: {"source": "30"},
      );
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    var baseImgUrl = '${Env.watchlistBase}/api/img';
    var editUrl = '${Env.watchlistBase}/watchable';

    return FutureBuilder<String>(
        future: _fetchCookies(baseImgUrl),
        builder: (buildContext, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(snapshot.error?.toString() ?? "Unknown Error"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return TVFocus(
              onClick: _play,
              onLongPress: _flipCard,
              onFocus: _focus,
              onBlur: _blur,
              child: GridFlipCard(
                flipCardController: _flipCardController,
                animation: _animation,
                isFocused: _isFocused,
                baseImgUrl: baseImgUrl,
                editUrl: editUrl,
                item: widget.item,
                cookie: snapshot.data,
                notifications: widget.notifications,
              ));
        });
  }
}
