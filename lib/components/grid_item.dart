import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../env/env.dart';
import '../model/item.dart';
import '../services/watchlist_client.dart';
import 'grid_flipcard.dart';

class GridItem extends StatefulWidget {
  final Item item;

  final CookieJar cookieJar;

  final WatchlistClient watchlistClient;

  const GridItem({super.key, required this.item, required this.cookieJar, required this.watchlistClient});

  @override
  _GridItemState createState() => _GridItemState(item, cookieJar, watchlistClient);
}

class _GridItemState extends State<GridItem> with TickerProviderStateMixin {
  final Item item;

  final CookieJar cookieJar;

  final WatchlistClient watchlistClient;

  bool _isFocused = false;

  bool _isLongPress = false;

  Timer? _longPressTimer;

  _GridItemState(this.item, this.cookieJar, this.watchlistClient);

  Future<String> _fetchCookies(String baseImgUrl) async {
    var cookies = await cookieJar.loadForRequest(Uri.parse(baseImgUrl));
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

  void _play() async {
    final play = await watchlistClient.play(item.id);
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
          return Focus(
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event.logicalKey != LogicalKeyboardKey.select) {
                  return KeyEventResult.ignored;
                }
                if (event is KeyDownEvent) {
                  // Start timer when key is pressed down
                  _longPressTimer ??= Timer(const Duration(milliseconds: 500), () {
                      setState(() {
                        _isLongPress = true;
                      });
                      // Handle long press action here
                    });
                } else if (event is KeyUpEvent) {
                  if (_isLongPress) {
                    _flipCard();
                  } else {
                    _play();
                  }
                  // Cancel timer when key is released
                  if (_longPressTimer != null) {
                    _longPressTimer?.cancel();
                    _longPressTimer = null;
                  }
                  setState(() {
                    _isLongPress = false;
                  });
                }
                return KeyEventResult.handled;
              },
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                  if (hasFocus) {
                    _controller.forward();
                  } else {
                    _controller.reset();
                  }
                });
              },
              child: GestureDetector(
                  onTap: () {
                    // card tapped
                  },
                  onLongPress: () {
                    _flipCard();
                  },
                  child: GridFlipCard(
                    flipCardController: _flipCardController,
                    animation: _animation,
                    isFocused: _isFocused,
                    baseImgUrl: baseImgUrl,
                    editUrl: editUrl,
                    item: item,
                    cookie: snapshot.data,
                  )
          )
          );
        });
  }
}
