import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';

class XDWelcome3 extends StatelessWidget {
  const XDWelcome3({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: Stack(
          children: <Widget>[
            Container(),
            Pinned.fromPins(
              Pin(size: 106.0, middle: 0.5019),
              Pin(size: 24.0, start: 45.0),
              child: const Text(
                'Welcome to',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 18,
                  color: Color(0xff173051),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                softWrap: false,
              ),
            ),
            Pinned.fromPins(
              Pin(size: 122.0, middle: 0.502),
              Pin(size: 33.0, start: 74.0),
              child: const Text(
                'MULTI APP',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 24,
                  color: Color(0x80173051),
                ),
                textAlign: TextAlign.center,
                softWrap: false,
              ),
            ),
            Pinned.fromPins(
              Pin(start: 56.0, end: 55.0),
              Pin(size: 61.0, middle: 0.7232),
              child: const Text(
                'Navigate to your destination\nwithout saving the history.',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 20,
                  color: Color(0xff173051),
                  height: 1.7,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
                softWrap: false,
              ),
            ),
            Pinned.fromPins(
              Pin(start: 34.0, end: 33.0),
              Pin(size: 27.0, middle: 0.794),
              child: const Text(
                'Keep your privacy using our VPN.',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 20,
                  color: Color(0xff173051),
                  height: 1.7,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.center,
                softWrap: false,
              ),
            ),
            Align(
              alignment: const Alignment(-0.25, -0.25),
              child: SizedBox(
                  height: 309,
                  width: 318,
                  child: Image.asset('assets/images/maap.png')),
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: Container(
                width: 65.0,
                height: 65.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF36),
                ),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
