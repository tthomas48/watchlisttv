import 'package:flutter/material.dart';

import '../model/item.dart';
import '../theme/theme_colors.dart';

class FlipCardFront extends StatelessWidget {

  const FlipCardFront({super.key, required this.animation, required this.isFocused, required this.baseImgUrl, required this.item, this.cookie});
  final String baseImgUrl;
  final String? cookie;
  final Item item;
  final Animation<double> animation;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
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
          scale: animation,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              border: isFocused ? Border.all(color: ThemeColors.primaryColor, width: 1) : Border.all(color: Colors.transparent, width: 1),
              boxShadow: isFocused ? [ BoxShadow(color: ThemeColors.accentColor.withOpacity(0.5), spreadRadius: 2, blurRadius: 10) ] : [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
            ),
            child: Stack(
              children: [
                // Background Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage('$baseImgUrl/${item.id}',
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
                    color: isFocused ? ThemeColors.accentColor : Colors.black54,
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: isFocused ? Colors.black54 : Colors.white,
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
}