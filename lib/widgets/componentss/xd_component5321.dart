import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class XDComponent5321 extends StatelessWidget {
  XDComponent5321({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Pinned.fromPins(
          Pin(start: 0.0, end: 0.0),
          Pin(size: 4.0, start: 0.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffd7ae7c),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
        Pinned.fromPins(
          Pin(start: 0.0, end: 0.0),
          Pin(size: 4.0, end: 0.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffd7ae7c),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
        Pinned.fromPins(
          Pin(start: 0.0, end: 0.0),
          Pin(size: 4.0, middle: 0.4737),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffd7ae7c),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
      ],
    );
  }
}
