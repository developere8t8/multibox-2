import 'package:fiberchat/Configs/app_constants.dart';
import 'package:flutter/material.dart';

import 'package:adobe_xd/pinned.dart';

class Splashscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IsSplashOnlySolidColor == true
        ? Scaffold(
            backgroundColor: SplashBackgroundSolidColor,
            body: Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(fiberchatLightGreen)),
            ))
        : Scaffold(
            backgroundColor: const Color(0xffffffff),
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/bg_gold.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.1), BlendMode.dstIn),
                    ),
                    border:
                        Border.all(width: 1.0, color: const Color(0x1a707070)),
                  ),
                ),
                Pinned.fromPins(
                  Pin(start: 77.0, end: 76.0),
                  Pin(size: 111.0, middle: 0.5007),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/multiapp.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
