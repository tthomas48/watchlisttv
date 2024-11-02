import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVFocus extends StatefulWidget {
  final Function() onClick;
  final Function() onLongPress;

  final Function() onFocus;
  final Function() onBlur;

  final Widget child;

  const TVFocus({super.key, required this.onClick, required this.onLongPress, required this.onFocus, required this.onBlur,required this.child});

  @override
  State<StatefulWidget> createState() => _TVFocusState();
}

class _TVFocusState extends State<TVFocus> {
  bool _isLongPress = false;

  Timer? _longPressTimer;

  @override
  Widget build(BuildContext context) {
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
              widget.onLongPress();
            } else {
              widget.onClick();
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
            if (hasFocus) {
              widget.onFocus();
            } else {
              widget.onBlur();
            }
          });
        },
        child: GestureDetector(
            onTap: () {
              widget.onClick();
            },
            onLongPress: () {
              widget.onLongPress();
            },
            child: widget.child
        )
    );
  }

}
