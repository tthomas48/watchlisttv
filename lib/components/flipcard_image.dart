import 'package:flutter/material.dart';

import '../model/watchlist_notification.dart';
import '../theme/theme_colors.dart';

class FlipCardImage extends StatelessWidget {
  final bool showCross; // Boolean to control the display of the "X"
  final ImageProvider<Object> imageProvider;
  final List<WatchlistNotification>? notifications;

  FlipCardImage({required this.showCross, required this.imageProvider, required this.notifications});

  @override
  Widget build(BuildContext context) {
    var n = notifications ?? [];
    return Stack(
      alignment: Alignment.center,
      children: [
        // Container for the main image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(12), // Optional: match the border radius
          ),
          width: 200, // Set desired width
          height: 200, // Set desired height
        ),
        // Overlay the "X" icon if showCross is true
        if (showCross)
          Positioned(
            top: 10, // Adjust position as needed
            right: 10, // Adjust position as needed
            child: Icon(
              Icons.cancel, // Use the cancel icon for "X"
              color: ThemeColors.accentColor, // Set color for the "X"
              size: 50, // Set size for the "X"
            ),
          ),
        if (n != null && n.length > 0)
          Positioned(
            top: 10, // Adjust position as needed
            right: 10, // Adjust position as needed
            child: Container(
              padding: EdgeInsets.all(4), // 4px padding around the text
              decoration: BoxDecoration(
              color: ThemeColors.accentColor, // Background color
              borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child:
                Text(
                  n[0].message,
                  style: TextStyle(
                    backgroundColor: ThemeColors.accentColor,
                    color: Colors.black54,
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
    );
  }
}