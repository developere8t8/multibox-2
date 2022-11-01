import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class XDComponent5521 extends StatelessWidget {
  XDComponent5521({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(width: 1.0, color: const Color(0xff173051)),
          ),
        ),
        Pinned.fromPins(
          Pin(start: 34.0, end: 34.0),
          Pin(size: 22.0, middle: 0.52),
          child: const Text(
            'Generate new address code',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 16,
              color: const Color(0xff173051),
            ),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
