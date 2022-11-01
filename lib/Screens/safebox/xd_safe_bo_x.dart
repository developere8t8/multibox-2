import 'package:adobe_xd/page_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:math_expressions/math_expressions.dart';

import './xd_safe_box_open.dart';

class XDSafeBOX extends StatefulWidget {
  const XDSafeBOX({
    Key? key,
  }) : super(key: key);

  @override
  State<XDSafeBOX> createState() => _XDSafeBOXState();
}

class _XDSafeBOXState extends State<XDSafeBOX> {
  String equation = "0";
  String result = "";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;

  buttonPressed(String buttonText) async {
    setState(() {
      if (buttonText == "C") {
        equation = "0";
        result = "0";
        equationFontSize = 38.0;
        resultFontSize = 48.0;
      } else if (buttonText == "⌫") {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == "=") {
        equationFontSize = 38.0;
        resultFontSize = 48.0;

        expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';

          if (result == '54.0') {
            Navigator.push(
                context, MaterialPageRoute(builder: (ctx) => XDSafeBoxOpen()));
          }
        } catch (e) {
          result = "Error";
        }
      } else {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  Widget buildButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: BorderSide(
                      color: Colors.white, width: 1, style: BorderStyle.solid)),
            ),
          ),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff173051),
        body: SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: Column(
                children: [
                  Container(
                    height: 100,
                    width: width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(34.0),
                        topRight: Radius.circular(34.0),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: SvgPicture.string(
                                '<svg viewBox="26.0 72.0 35.34 35.34" ><path transform="translate(-6634.0, 21996.0)" d="M 6677.66650390625 -21888.66015625 C 6672.94921875 -21888.66015625 6668.51318359375 -21890.5 6665.17626953125 -21893.837890625 C 6661.83740234375 -21897.171875 6659.99853515625 -21901.609375 6659.99853515625 -21906.33203125 C 6659.99853515625 -21911.052734375 6661.83740234375 -21915.48828125 6665.17626953125 -21918.822265625 C 6668.50927734375 -21922.16015625 6672.9453125 -21924 6677.66650390625 -21924 C 6682.39111328125 -21924 6686.8291015625 -21922.16015625 6690.16162109375 -21918.822265625 C 6693.50048828125 -21915.48828125 6695.33935546875 -21911.052734375 6695.33935546875 -21906.33203125 C 6695.33935546875 -21901.609375 6693.50048828125 -21897.171875 6690.16162109375 -21893.837890625 C 6686.8251953125 -21890.5 6682.38720703125 -21888.66015625 6677.66650390625 -21888.66015625 Z M 6677.15625 -21914 C 6676.94580078125 -21914 6676.74609375 -21913.921875 6676.59326171875 -21913.77734375 L 6669.47900390625 -21906.998046875 C 6669.17041015625 -21906.689453125 6669.00048828125 -21906.279296875 6669.00048828125 -21905.84375 C 6669.00048828125 -21905.40625 6669.17431640625 -21904.9921875 6669.490234375 -21904.67578125 L 6676.59326171875 -21897.9140625 C 6676.7451171875 -21897.767578125 6676.93896484375 -21897.689453125 6677.15478515625 -21897.689453125 C 6677.380859375 -21897.689453125 6677.59765625 -21897.78125 6677.7490234375 -21897.94140625 C 6677.8984375 -21898.099609375 6677.97802734375 -21898.306640625 6677.97265625 -21898.5234375 C 6677.9677734375 -21898.740234375 6677.8779296875 -21898.94140625 6677.72119140625 -21899.091796875 L 6671.4599609375 -21905.029296875 L 6685.0390625 -21905.029296875 C 6685.48828125 -21905.029296875 6685.853515625 -21905.39453125 6685.853515625 -21905.84375 C 6685.853515625 -21906.294921875 6685.48828125 -21906.662109375 6685.0390625 -21906.662109375 L 6671.4873046875 -21906.662109375 L 6677.7158203125 -21912.59375 C 6677.87353515625 -21912.7421875 6677.9638671875 -21912.943359375 6677.97119140625 -21913.16015625 C 6677.978515625 -21913.37890625 6677.8994140625 -21913.58984375 6677.7490234375 -21913.75 C 6677.591796875 -21913.912109375 6677.38134765625 -21914 6677.15625 -21914 Z" fill="#d4af36" stroke="none" stroke-width="0.1333329975605011" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                width: 35.34,
                                height: 35.34,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Safe box',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            const SizedBox(
                              width: 35.0,
                              height: 35.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(34.0),
                        topRight: Radius.circular(34.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Group: Group 9280
                              PageLink(
                                links: [
                                  PageLinkInfo(
                                    transition: LinkTransition.Fade,
                                    ease: Curves.easeOut,
                                    duration: 0.3,
                                    pageBuilder: () => XDSafeBoxOpen(),
                                  ),
                                ],
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 67.0,
                                  height: 67.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18.0),
                                    color: const Color(0xFFD4AF36)
                                        .withOpacity(0.3),
                                  ),
                                  child: SvgPicture.string(
                                    // Union 48
                                    '<svg viewBox="64.0 193.0 36.59 34.47" ><path transform="translate(64.0, 193.0)" d="M 4.7388014793396 29.79416084289551 L 4.484513282775879 29.51113891601562 L 4.484513282775879 26.12762069702148 C 4.484513282775879 23.45083999633789 4.50308084487915 22.75113868713379 4.573850631713867 22.77738189697266 C 4.623094081878662 22.79551124572754 6.668428421020508 23.48141288757324 9.119277954101562 24.3015251159668 L 13.57563781738281 25.79211235046387 L 14.2628870010376 25.76424026489258 C 15.61612701416016 25.70850372314453 16.1475772857666 25.30318450927734 17.46987342834473 23.31853103637695 C 17.96445465087891 22.57661819458008 18.38961410522461 21.96945381164551 18.41463851928711 21.96945381164551 C 18.4399299621582 21.96945381164551 18.86508941650391 22.57661819458008 19.35940551757812 23.31853103637695 C 20.67793273925781 25.2975025177002 21.21799087524414 25.71012878417969 22.56073760986328 25.76424026489258 L 23.25363922119141 25.79211235046387 L 27.70999717712402 24.3015251159668 C 30.16084861755371 23.48141288757324 32.20644760131836 22.79551124572754 32.25542449951172 22.77738189697266 C 32.32619094848633 22.75113868713379 32.34475708007812 23.45083999633789 32.34475708007812 26.12762069702148 L 32.34475708007812 29.51113891601562 L 32.09046936035156 29.79416084289551 C 31.78882598876953 30.12994194030762 19.09543228149414 34.4677734375 18.41463851928711 34.4677734375 C 17.73384666442871 34.4677734375 5.040448665618896 30.12994194030762 4.7388014793396 29.79416084289551 Z M 20.02647018432617 20.77703285217285 C 19.09946441650391 19.37844276428223 18.31911277770996 18.23418998718262 18.29247283935547 18.23418998718262 C 18.26609992980957 18.23418998718262 17.48574829101562 19.37844276428223 16.55873870849609 20.77703285217285 C 14.72786998748779 23.53850555419922 14.59467124938965 23.69327354431152 14.04707813262939 23.69327354431152 C 13.68515491485596 23.69327354431152 0.678539514541626 19.41253280639648 0.4035321176052094 19.20284271240234 C 0.1293318867683411 18.99395561218262 0.005820722319185734 18.71391487121582 0.005282547790557146 18.30047798156738 L 0.005013460293412209 17.89975738525391 L 2.016711711883545 14.92453670501709 C 3.123199462890625 13.28810977935791 4.028409957885742 11.90060997009277 4.028409957885742 11.84135437011719 C 4.028141021728516 11.7820987701416 3.122930765151978 10.3951416015625 2.016443014144897 8.759526252746582 L 0.005013460293412209 5.785384654998779 L 0.005013460293412209 5.362748622894287 C 0.005013460293412209 4.49826717376709 -0.4408645927906036 4.698220729827881 7.077171802520752 2.187301158905029 C 14.22601890563965 -0.2005077004432678 14.16090106964111 -0.1831910014152527 14.62938404083252 0.1761302947998047 C 14.77630519866943 0.2886886894702911 15.54212760925293 1.372334837913513 16.55873870849609 2.905672788619995 C 17.48574829101562 4.303995609283447 18.26609992980957 5.448250293731689 18.29247283935547 5.448250293731689 C 18.31911277770996 5.448250293731689 19.09946441650391 4.303995609283447 20.02647018432617 2.905672788619995 C 21.0430850982666 1.372334837913513 21.80890846252441 0.2886886894702911 21.95582962036133 0.1761302947998047 C 22.40978240966797 -0.1720974892377853 22.32609367370605 -0.1945550590753555 29.46121788024902 2.179995775222778 C 37.03334045410156 4.699573516845703 36.5802001953125 4.497185230255127 36.5802001953125 5.362748622894287 L 36.5802001953125 5.785384654998779 L 34.56876373291016 8.759526252746582 C 33.46228408813477 10.3951416015625 32.55707168579102 11.7820987701416 32.55680465698242 11.84135437011719 C 32.55680465698242 11.90060997009277 33.46174240112305 13.28810977935791 34.56823348999023 14.92453670501709 L 36.5802001953125 17.89975738525391 L 36.57992935180664 18.30047798156738 C 36.57939529418945 18.71391487121582 36.45561599731445 18.99395561218262 36.18167877197266 19.20284271240234 C 35.90667343139648 19.41253280639648 22.90006065368652 23.69327354431152 22.53813362121582 23.69327354431152 C 21.99054145812988 23.69327354431152 21.85734176635742 23.53850555419922 20.02647018432617 20.77703285217285 Z M 18.25641441345215 8.758172988891602 C 18.08150672912598 8.76547908782959 9.077301025390625 11.78994560241699 9.077301025390625 11.84135437011719 C 9.077301025390625 11.86191749572754 11.15088844299316 12.57271385192871 13.68488597869873 13.4215030670166 L 18.29247283935547 14.96458053588867 L 22.90032577514648 13.4215030670166 C 25.43432426452637 12.57271385192871 27.50791358947754 11.86191749572754 27.50791358947754 11.84135437011719 C 27.50791358947754 11.8210620880127 25.45827293395996 11.11784172058105 22.95333862304688 10.27852344512939 C 20.45348358154297 9.440998077392578 18.34349060058594 8.758118629455566 18.25695037841797 8.758163452148438 C 18.25676536560059 8.758163452148438 18.2565803527832 8.758166313171387 18.25641441345215 8.758172988891602 Z" fill="#d4af36" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                    width: 36.59,
                                    height: 34.47,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              SizedBox(
                                width: 189.0,
                                height: 49.0,
                                child: Text(
                                  'Type the code to access\nyour saved contents',
                                  style: TextStyle(
                                    fontFamily: "OpenSans",
                                    fontSize: 17.0,
                                    color: const Color(0xFFD4AF36),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          height: 1.0,
                          color: Color(0xffEDEEF2),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      fontFamily: "OpenSans",
                                      fontSize: 37.0,
                                      color: const Color(0xFF60C255),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: equation,
                                        style: TextStyle(
                                          fontFamily: "OpenSans",
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                            Text(
                              result,
                              style: TextStyle(
                                fontFamily: "OpenSans",
                                fontSize: 37.0,
                                color: Colors.black.withOpacity(0.4),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            color: Color(0xffEDEEF2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: width * 0.7,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          digitsWidget(buttonText: '7'),
                                          digitsWidget(buttonText: '8'),
                                          digitsWidget(buttonText: '9'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          digitsWidget(buttonText: '4'),
                                          digitsWidget(buttonText: '5'),
                                          digitsWidget(buttonText: '6'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          digitsWidget(buttonText: '1'),
                                          digitsWidget(buttonText: '2'),
                                          digitsWidget(buttonText: '3'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          digitsWidget(buttonText: '0'),
                                          digitsWidget(buttonText: ','),
                                          digitsWidget(buttonText: '='),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: width * 0.3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(16.0),
                                    ),
                                    color: const Color(0xFF173051)
                                        .withOpacity(0.1),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: width * 0.15,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              left: Radius.circular(16.0),
                                            ),
                                            color: const Color(0xFF173051),
                                          ),
                                          child: Center(
                                            child: // Group: back
                                                SvgPicture.string(
                                              // Group 3959
                                              '<svg viewBox="0.0 0.0 8.97 15.28" ><path transform="translate(0.0, 0.0)" d="M 3.015544414520264 7.640819072723389 L 8.729958534240723 1.926162958145142 C 8.887299537658691 1.769188761711121 8.973862648010254 1.55931031703949 8.973862648010254 1.335522770881653 C 8.973862648010254 1.111611008644104 8.887299537658691 0.9018566012382507 8.729958534240723 0.7446339726448059 L 8.229227066040039 0.2441544979810715 C 8.07213306427002 0.08668358623981476 7.862133026123047 4.248164842124424e-08 7.638339519500732 4.248164842124424e-08 C 7.41455602645874 4.248164842124424e-08 7.204803466796875 0.08668358623981476 7.047580718994141 0.2441545575857162 L 0.2436674386262894 7.047943115234375 C 0.08582077175378799 7.205662727355957 -0.0006131731206551194 7.416409969329834 7.465335443157528e-07 7.640446662902832 C -0.0006131731206551194 7.865476131439209 0.08569204807281494 8.075976371765137 0.2436674386262894 8.233819007873535 L 7.041243553161621 15.03102397918701 C 7.198466300964355 15.18849468231201 7.408218860626221 15.27518081665039 7.632131099700928 15.27518081665039 C 7.855915069580078 15.27518081665039 8.065667152404785 15.18849563598633 8.223018646240234 15.03102397918701 L 8.723630905151367 14.53054523468018 C 9.049374580383301 14.20479869842529 9.049374580383301 13.67451477050781 8.723630905151367 13.34889316558838 L 3.015544414520264 7.640819072723389 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                              width: 8.97,
                                              height: 15.28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        top: 0,
                                        left: 18,
                                        child: Column(
                                          // crossAxisAlignment:
                                          //     CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            operationsWidget(
                                                svgName: 'multiply',
                                                buttonText: "⌫"),
                                            operationsWidget(
                                                svgName: 'divide',
                                                buttonText: '÷'),
                                            operationsWidget(
                                                svgName: 'cross',
                                                buttonText: '×'),
                                            operationsWidget(
                                                svgName: 'minus',
                                                buttonText: "-"),
                                            operationsWidget(
                                                svgName: 'plus',
                                                buttonText: "+"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  InkWell operationsWidget({String? svgName, String? buttonText}) {
    return InkWell(
      onTap: () => buttonPressed(buttonText!),
      child: SvgPicture.asset('assets/svgs/$svgName.svg'),
    );
  }

  InkWell digitsWidget({
    String? buttonText,
  }) {
    return InkWell(
        onTap: () => buttonPressed(buttonText!),
        child: Container(
          width: 68.0,
          height: 68.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                offset: Offset(0, 0),
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Center(
              child: Text(
            buttonText!,
            style: TextStyle(
              fontFamily: "OpenSans",
              fontSize: 24.0,
              color: Color(0xff3F3D56),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )),
        ));
  }
}
