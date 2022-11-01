import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class XDComponent5241 extends StatelessWidget {
  const XDComponent5241({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: Color(0xff173051),
            borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 0),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(6.1),
        //   child: SizedBox.expand(
        //       child: SvgPicture.string(
        //     _svg_jsg9bc,
        //     allowDrawingOutsideViewBox: true,
        //     fit: BoxFit.fill,
        //   )),
        // ),
        Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child:
                // Adobe XD layer: 'profile-user' (group)
                Stack(
              children: <Widget>[
                SizedBox.expand(
                    child: SvgPicture.string(
                  _svg_jxedwp,
                  allowDrawingOutsideViewBox: true,
                  fit: BoxFit.fill,
                )),
              ],
            ),
          ),
        ),
        SizedBox.expand(child: Image.asset('assets/images/dottedCircle.png')),
      ],
    );
  }
}

const String _svg_jxedwp =
    '<svg viewBox="0.0 0.0 20.3 20.3" ><path transform="translate(0.0, 0.0)" d="M 10.13706398010254 0.0009994092397391796 C 4.539103031158447 0.0009994092397391796 0 4.539211273193359 0 10.13761711120605 C 0 15.73602199554443 4.538657665252686 20.27423286437988 10.13706398010254 20.27423286437988 C 15.73591232299805 20.27423286437988 20.27412796020508 15.73602104187012 20.27412796020508 10.13761615753174 C 20.27412796020508 4.539211750030518 15.73591232299805 0.0009994092397391796 10.13706398010254 0.0009994092397391796 Z M 10.13706398010254 3.031966209411621 C 11.98939514160156 3.031966209411621 13.49040603637695 4.533422946929932 13.49040603637695 6.384864330291748 C 13.49040603637695 8.236751556396484 11.98939514160156 9.737762451171875 10.13706398010254 9.737762451171875 C 8.285622596740723 9.737762451171875 6.784610748291016 8.236751556396484 6.784610748291016 6.384863376617432 C 6.784610748291016 4.533422946929932 8.285621643066406 3.031966209411621 10.13706398010254 3.031966209411621 Z M 10.13483715057373 17.62397575378418 C 8.287402153015137 17.62397575378418 6.5953688621521 16.95116996765137 5.290276527404785 15.83754348754883 C 4.972352027893066 15.56637001037598 4.788899898529053 15.16874504089355 4.788899898529053 14.75152492523193 C 4.788899898529053 12.87381458282471 6.308613777160645 11.37102031707764 8.186771392822266 11.37102031707764 L 12.08824443817139 11.37102031707764 C 13.96684646606445 11.37102031707764 15.4807710647583 12.87381458282471 15.4807710647583 14.75152492523193 C 15.4807710647583 15.16919136047363 15.2982120513916 15.56592750549316 14.9798412322998 15.83709621429443 C 13.67519378662109 16.95116996765137 11.98271560668945 17.62397575378418 10.13483715057373 17.62397575378418 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
