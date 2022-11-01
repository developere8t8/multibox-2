import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class XDComponent5451 extends StatelessWidget {
  XDComponent5451({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffd4af36),
            borderRadius: BorderRadius.circular(22.0),
          ),
        ),
        Align(
          alignment: Alignment(0.0, 0.048),
          child: SizedBox(
            width: 181.0,
            height: 26.0,
            child: Stack(
              children: <Widget>[
                Pinned.fromPins(
                  Pin(size: 86.0, start: 0.0),
                  Pin(start: 0.0, end: 0.0),
                  child: Text(
                    'confirm',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 19,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 4.0, middle: 0.548),
                  Pin(size: 19.0, start: 3.0),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 70.0, end: 0.0),
                  Pin(size: 19.0, start: 3.0),
                  child: Text(
                    '(Fee \$1,35)',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
