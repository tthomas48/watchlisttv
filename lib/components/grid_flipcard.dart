import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

import '../model/item.dart';
import 'flipcard_back.dart';
import 'flipcard_front.dart';

class GridFlipCard extends StatelessWidget {
  const GridFlipCard(
      {super.key, required this.flipCardController, required this.animation, required this.isFocused, required this.baseImgUrl, required this.editUrl, required this.item, this.cookie});

  final FlipCardController flipCardController;
  final String baseImgUrl;
  final String editUrl;
  final String? cookie;
  final Item item;
  final Animation<double> animation;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      controller: flipCardController,
      flipOnTouch: false,
      fill: Fill.fillBack,
      // Fill the back side of the card to make in the same size as the front.
      direction: FlipDirection.HORIZONTAL,
      // default
      side: CardSide.FRONT,
      // The side to initially display.
      front: FlipCardFront(
          animation: animation,
          isFocused: isFocused,
          baseImgUrl: baseImgUrl,
          item: item,
          cookie: cookie,
        ),
      back: FlipCardBack(
          animation: animation,
          isFocused: isFocused,
          editUrl: editUrl,
          item: item,
          cookie: cookie,
        ),
    );
  }
}
