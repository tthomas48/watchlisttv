import 'package:flutter/material.dart';

import '../model/item.dart';
import '../model/watchlist_notification.dart';
import '../theme/theme_colors.dart';
import 'flipcard_image.dart';

class FlipCardFront extends StatefulWidget {
  const FlipCardFront({super.key, required this.animation, required this.isFocused, required this.baseImgUrl, required this.item, required this.notifications, this.cookie});
  final List<WatchlistNotification>? notifications;
  final String baseImgUrl;
  final String? cookie;
  final Item item;
  final Animation<double> animation;
  final bool isFocused;

  @override
  State<StatefulWidget> createState() {
    return _FlipCardFrontState();
  }
}
class _FlipCardFrontState extends State<FlipCardFront> {

@override
Widget build(BuildContext context) {
    bool validUrl = widget.item.webUrl?.isNotEmpty ?? false;
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
          scale: widget.animation,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              border: widget.isFocused ? Border.all(color: ThemeColors.primaryColor, width: 1) : Border.all(color: Colors.transparent, width: 1),
              boxShadow: widget.isFocused ? [ BoxShadow(color: ThemeColors.accentColor.withOpacity(0.5), spreadRadius: 2, blurRadius: 10) ] : [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
            ),
            child: Stack(
              children: [
                // Background Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FlipCardImage(
                    imageProvider: NetworkImage('${widget.baseImgUrl}/${widget.item.id}',
                        headers: {
                          'Cookie': widget.cookie ?? '',
                        }),
                    showCross: !validUrl,
                    notifications: widget.notifications
                ),
                // Text Title at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: widget.isFocused ? ThemeColors.accentColor : Colors.black54,
                    child: Text(
                      widget.item.title,
                      style: TextStyle(
                        color: widget.isFocused ? Colors.black54 : Colors.white,
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