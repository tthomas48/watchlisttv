import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../env/env.dart';
import '../model/item.dart';
import '../services/watchlist_client.dart';
import '../theme/theme_colors.dart';

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

  final bool _isFront = true;

  bool _isFocused = false;

  bool _isKeyPressed = false;

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
                  _isKeyPressed = true;
                  _longPressTimer ??= Timer(const Duration(milliseconds: 500), () {
                      setState(() {
                        _isLongPress = true;
                      });
                      // Handle long press action here
                    });
                } else if (event is KeyUpEvent) {
                  if (_isLongPress) {
                    print('Long press detected');
                    _flipCard();
                  } else {
                    print('Normal press"');
                    _play();
                  }
                  // Cancel timer when key is released
                  _isKeyPressed = false;
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
                print("Focused ${item.title}");
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
                    print('Card tapped!');
                  },
                  onLongPress: () {
                    _flipCard();
                  },
                  child: _createFlipper(baseImgUrl, editUrl, snapshot.data)));
        });
  }

  Widget _createFlipper(String baseImgUrl, String editUrl, String? cookie) {
    return FlipCard(
      controller: _flipCardController,
      flipOnTouch: false,
      fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
      direction: FlipDirection.HORIZONTAL, // default
      side: CardSide.FRONT, // The side to initially display.
      front: Container(
        child: _createCardFront(baseImgUrl, cookie),
      ),
      back: Container(
        child: _createCardBack(editUrl),
      ),
    );
  }

  Widget _createCardFront(String baseImgUrl, String? cookie) {
    return Card(
      color: ThemeColors.backgroundColor,
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: ScaleTransition(
          scale: _animation,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              border: _isFocused
                  ? Border.all(color: ThemeColors.primaryColor, width: 1)
                  : Border.all(color: Colors.transparent, width: 1),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                          color: ThemeColors.accentColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 10)
                    ]
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5)
                    ],
            ),
            child: Stack(
              children: [
                // Background Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage('$baseImgUrl/${item.id ?? ''}',
                          headers: {
                            'Cookie': cookie ?? '',
                          }),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Text Title at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color:
                        _isFocused ? ThemeColors.accentColor : Colors.black54,
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: _isFocused ? Colors.black54 : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _createCardBack(String editUrl) {
    return Card(
      color: ThemeColors.backgroundColor,
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: ScaleTransition(
          scale: _animation,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              border: _isFocused
                  ? Border.all(color: ThemeColors.primaryColor, width: 1)
                  : Border.all(color: Colors.transparent, width: 1),
              boxShadow: _isFocused
                  ? [
                BoxShadow(
                    color: ThemeColors.accentColor.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10)
              ]
                  : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5)
              ],
            ),
            child: Stack(
              children: [
                // Background Image
                QrImageView(
                  data: '$editUrl/${item.id ?? ''}',
                  version: QrVersions.auto,
                  size: 300.0,
                ),
                // Text Title at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color:
                    _isFocused ? ThemeColors.accentColor : Colors.black54,
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: _isFocused ? Colors.black54 : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
