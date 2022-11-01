import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'onBoarding3.dart';

class XDWelcome2 extends StatelessWidget {
  XDWelcome2({
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
              Pin(start: 42.5, end: 42.5),
              Pin(size: 61.0, middle: 0.7166),
              child: const Text(
                'Exchange, send and receive\nCryptocurrencies in your wallet',
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
              Pin(start: 43.0, end: 42.0),
              Pin(size: 297.7, middle: 0.403),
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 310.0,
                    height: 310.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500.0),
                      color: const Color(0xFF173051).withOpacity(0.05),
                    ),
                    child: Center(
                      child: Container(
                        width: 229.0,
                        height: 229.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(500.0),
                          color: const Color(0xFF173051).withOpacity(0.05),
                        ),
                        child: Center(
                          child: Container(
                            width: 155,
                            height: 155,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(500.0),
                              color: const Color(0xFF173051).withOpacity(0.05),
                            ),
                            child: Center(
                              child: Align(
                                alignment: const Alignment(0.005, 0.033),
                                child: SizedBox(
                                  width: 50.0,
                                  height: 42.0,
                                  child: SvgPicture.string(
                                    svgSh7gg0,
                                    allowDrawingOutsideViewBox: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: const Alignment(-0.543, -1.0),
                      child: Image.asset('assets/images/bitcoin.png')),
                  Align(
                      alignment: const Alignment(-0.75, 0.5),
                      child: Image.asset('assets/images/dogecoin-1.png')),
                  Align(
                      alignment: const Alignment(0.82, 0.1),
                      child: Image.asset('assets/images/ethereum-eth.png')),
                  Pinned.fromPins(Pin(size: 39.0, start: 20.5),
                      Pin(size: 39.0, middle: 0.4187),
                      child: Image.asset('assets/images/boy2.png')),
                  Pinned.fromPins(Pin(size: 48.8, end: 55.2),
                      Pin(size: 48.8, middle: 0.1917),
                      child: Image.asset('assets/images/boy3.png')),
                  Pinned.fromPins(Pin(size: 54.0, middle: 0.6737),
                      Pin(size: 54.0, end: 19.0),
                      child: Image.asset('assets/images/girl2.png')),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: PageLink(
                links: [
                  PageLinkInfo(
                    transition: LinkTransition.Fade,
                    ease: Curves.easeOut,
                    duration: 0.3,
                    pageBuilder: () => XDWelcome3(),
                  ),
                ],
                child: Container(
                  width: 65.0,
                  height: 65.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD4AF36),
                  ),
                  child:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

const String svgSh7gg0 =
    '<svg viewBox="163.4 339.6 50.3 41.6" ><path transform="translate(163.63, 304.99)" d="M 5.527464866638184 34.71215438842773 C 2.76579737663269 35.3245735168457 0.663687527179718 37.34637069702148 -0.03106601350009441 40.05802917480469 C -0.3213112950325012 41.19109725952148 -0.3213112950325012 69.58246612548828 -0.03106601350009441 70.71556854248047 C 0.6117726564407349 73.22458648681641 2.451668977737427 75.13536834716797 4.987324237823486 75.92720031738281 L 5.723936080932617 76.15708923339844 L 24.92286109924316 76.15708923339844 L 44.12179183959961 76.15708923339844 L 44.8584098815918 75.92720031738281 C 47.39405822753906 75.13536834716797 49.23395156860352 73.22458648681641 49.87679290771484 70.71556854248047 C 50.04372406005859 70.06378936767578 50.06321334838867 69.60060119628906 50.06321334838867 66.27186584472656 L 50.06321334838867 62.55572509765625 L 42.86968612670898 62.55408096313477 C 34.18482208251953 62.55194854736328 34.1004753112793 62.54013824462891 32.11048889160156 61.03497314453125 C 27.89042854309082 57.84288787841797 28.65494728088379 51.23598098754883 33.51570892333984 48.8910026550293 C 34.91501998901367 48.21596908569336 34.83922576904297 48.22137832641602 42.86968612670898 48.21950912475586 L 50.06321334838867 48.21787261962891 L 50.06321334838867 44.5017204284668 C 50.06321334838867 41.17299652099609 50.04372406005859 40.70979690551758 49.87679290771484 40.05802917480469 C 49.2404899597168 37.57439041137695 47.45464324951172 35.70168304443359 44.90742874145508 34.8471565246582 L 44.2200927734375 34.61650466918945 L 25.16835784912109 34.59902572631836 C 9.622575759887695 34.58470153808594 6.008274078369141 34.60555648803711 5.527464866638184 34.71215438842773 M 35.72541427612305 51.07809829711914 C 31.66198539733887 51.73703002929688 30.85749244689941 57.50286865234375 34.57688140869141 59.30884170532227 C 35.55057144165039 59.7816047668457 35.95155334472656 59.80447006225586 43.26249313354492 59.80522537231445 L 50.06321334838867 59.80597305297852 L 50.06321334838867 55.38678359985352 L 50.06321334838867 50.96760177612305 L 43.16432571411133 50.97905349731445 C 39.37001037597656 50.98533630371094 36.0224494934082 51.02995300292969 35.72541427612305 51.07809829711914 M 39.13884735107422 54.20782852172852 C 40.06527709960938 54.77274322509766 40.06527709960938 56.00085067749023 39.13884735107422 56.56575775146484 C 38.2373161315918 57.11544799804688 35.77834320068359 56.78258514404297 35.33197784423828 56.05061721801758 C 34.95122146606445 55.42602157592773 35.17773818969727 54.61598968505859 35.84722518920898 54.20782852172852 C 36.32350921630859 53.91733169555664 38.66256713867188 53.91733169555664 39.13884735107422 54.20782852172852" fill="#173051" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
