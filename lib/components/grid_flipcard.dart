import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

import '../model/item.dart';
import '../model/watchlist_notification.dart';
import 'flipcard_back.dart';
import 'flipcard_front.dart';

class GridFlipCard extends StatefulWidget {
  final FlipCardController flipCardController;
  final String baseImgUrl;
  final String editUrl;
  final String? cookie;
  final Item item;
  final Animation<double> animation;
  final bool isFocused;
  final List<WatchlistNotification>? notifications;

  const GridFlipCard(
      {super.key, required this.flipCardController, required this.animation, required this.isFocused, required this.baseImgUrl, required this.editUrl, required this.item, required this.notifications, this.cookie});

  @override
  State<StatefulWidget> createState() {
    return _GridFlipCardState();
  }
}
class _GridFlipCardState extends State<GridFlipCard> {

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      controller: widget.flipCardController,
      flipOnTouch: false,
      fill: Fill.fillBack,
      // Fill the back side of the card to make in the same size as the front.
      direction: FlipDirection.HORIZONTAL,
      // default
      side: CardSide.FRONT,
      // The side to initially display.
      front: FlipCardFront(
          animation: widget.animation,
          isFocused: widget.isFocused,
          baseImgUrl: widget.baseImgUrl,
          item: widget.item,
          cookie: widget.cookie,
          notifications: widget.notifications,
        ),
      back: FlipCardBack(
          animation: widget.animation,
          isFocused: widget.isFocused,
          editUrl: widget.editUrl,
          item: widget.item,
          cookie: widget.cookie,
        ),
    );
  }
}
