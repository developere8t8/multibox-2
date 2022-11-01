import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Screens/wallet/xd_exchange.dart';
import 'package:fiberchat/Screens/wallet/xd_send.dart';
import 'package:fiberchat/Screens/wallet/xd_wallet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../Configs/Dbkeys.dart';
import '../../Configs/Dbpaths.dart';
import '../../Utils/utils.dart';
import '../../main.dart';
import '../../widgets/componentss/xd_component5291.dart';
import '../../widgets/componentss/xd_component5301.dart';
import '../../widgets/componentss/xd_component5304.dart';
import '../../widgets/componentss/xd_component5311.dart';
import '../../widgets/componentss/xd_component5314.dart';
import '../../widgets/componentss/xd_component5321.dart';
import '../../widgets/componentss/xd_svgg.dart';

import 'dart:core';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';

import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/main.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/DataModel.dart';

import '../Groups/AddContactsToGroup.dart';

import '../homepage/homepage.dart';
import '../search_chats/SearchRecentChat.dart';
import '../settings/settings.dart';
import '../vpn/xd_mainpage_location.dart';

class XDMainpageCrypto extends StatefulWidget {
  XDMainpageCrypto(
      {required this.currentUserNo,
      required this.isSecuritySetupDone,
      required this.prefs,
      key})
      : super(key: key);
  final String? currentUserNo;
  final bool isSecuritySetupDone;
  final SharedPreferences prefs;

  @override
  State<XDMainpageCrypto> createState() => _XDMainpageCryptoState();
}

class _XDMainpageCryptoState extends State<XDMainpageCrypto> {
  String? currentUserNo;
  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);

    Map<String, double> dataMap = {
      "Flutter": 5,
      "React": 3,
      "Xamarin": 2,
      "Ionic": 2,
    };
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
                          child: Row(
                            children: [
                              const Spacer(),
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/app_icon.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(
                                flex: 2,
                              ),
                              PageLink(
                                links: [
                                  PageLinkInfo(
                                    transition: LinkTransition.Fade,
                                    ease: Curves.easeOut,
                                    duration: 0.3,
                                    pageBuilder: () => Homepage(
                                        prefs: widget.prefs,
                                        currentUserNo: widget.currentUserNo,
                                        isSecuritySetupDone:
                                            widget.isSecuritySetupDone),
                                  ),
                                ],
                                child: SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: XDComponent5301(
                                      color: Color(0xff748397),
                                    )),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 28,
                                width: 28,
                                child: SvgPicture.string(
                                  '<svg viewBox="0.0 0.0 28.17 28.21" ><path transform="translate(-0.39, 0.43)" d="M 12.76949405670166 -0.3323599696159363 C 5.693131923675537 0.4664138555526733 0.3910000026226044 6.459858417510986 0.3910000026226044 13.66001987457275 C 0.3910000026226044 17.75064659118652 1.766795039176941 21.03017616271973 4.661126613616943 23.83880805969238 C 12.04628086090088 31.00509834289551 24.55033683776855 27.97330474853516 27.80867004394531 18.22633361816406 C 31.10221290588379 8.374085426330566 23.10179710388184 -1.498655796051025 12.76949405670166 -0.3323599696159363 M 14.94258403778076 5.096950531005859 C 15.20623683929443 5.292788505554199 15.28623294830322 5.51263952255249 15.32193660736084 6.139729499816895 C 15.35348415374756 6.694146156311035 15.36228656768799 6.727665901184082 15.49277496337891 6.789635181427002 C 16.75392913818359 7.389050483703613 16.71822547912598 7.366867542266846 17.20010948181152 7.851287364959717 C 18.58900260925293 9.247433662414551 18.7857551574707 11.4306640625 17.52270317077637 11.43172073364258 C 17.00863647460938 11.43214321136475 16.7418155670166 11.11222457885742 16.65118598937988 10.3868989944458 C 16.37260437011719 8.157684326171875 13.41890716552734 7.637070178985596 12.43598556518555 9.643898963928223 C 12.05219554901123 10.42760276794434 12.24690818786621 11.5487585067749 12.8761100769043 12.17803192138672 C 13.30567073822021 12.60752296447754 13.66227912902832 12.74906826019287 14.53414916992188 12.83617687225342 C 18.11282348632812 13.19377040863037 19.65325927734375 17.05792427062988 17.20010948181152 19.5238208770752 C 16.71801376342773 20.00838279724121 16.75576019287109 19.98493385314941 15.49277496337891 20.58547401428223 C 15.36249923706055 20.6474437713623 15.35327434539795 20.68216133117676 15.31855583190918 21.24122428894043 C 15.26539039611816 22.0965461730957 15.01842594146729 22.43505477905273 14.44746112823486 22.43505477905273 C 13.87494659423828 22.43505477905273 13.62150478363037 22.08739280700684 13.5729866027832 21.23538208007812 C 13.54143905639648 20.68096351623535 13.53263473510742 20.6474437713623 13.40214824676514 20.58547401428223 C 12.14099597930908 19.98605918884277 12.17669868469238 20.00824165344238 11.69481468200684 19.5238208770752 C 10.30592250823975 18.12767601013184 10.10916709899902 15.94444465637207 11.37222099304199 15.94338798522949 C 11.88304805755615 15.94296646118164 12.15317821502686 16.26337623596191 12.24204921722412 16.97490119934082 C 12.5219669342041 19.21510124206543 15.4729175567627 19.7443790435791 16.45893859863281 17.73121070861816 C 16.70040893554688 17.23812866210938 16.70040893554688 16.29872703552246 16.45893859863281 15.8056468963623 C 16.06845855712891 15.00842189788818 15.47517013549805 14.65026664733887 14.36077404022217 14.53893184661865 C 10.78210067749023 14.1813383102417 9.241663932800293 10.31718444824219 11.69481468200684 7.851287364959717 C 12.17691040039062 7.366727352142334 12.13916492462158 7.390177249908447 13.40214824676514 6.789635181427002 C 13.5324239730835 6.727665901184082 13.54164886474609 6.692948818206787 13.57636737823486 6.133884906768799 C 13.64270305633545 5.066529273986816 14.26535511016846 4.593940258026123 14.94258403778076 5.096950531005859" fill="#748397" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              PageLink(
                                links: [
                                  PageLinkInfo(
                                    transition: LinkTransition.Fade,
                                    ease: Curves.easeOut,
                                    duration: 0.3,
                                    pageBuilder: () => XDMainpageLocation(
                                      currentUserNo: widget.currentUserNo,
                                      isSecuritySetupDone:
                                          widget.isSecuritySetupDone,
                                      prefs: widget.prefs,
                                    ),
                                  ),
                                ],
                                child: SizedBox(
                                    height: 28.9, width: 25.6, child: XDSvgg()),
                              ),
                              const Spacer(),
                              PageLink(
                                links: [
                                  PageLinkInfo(
                                    transition: LinkTransition.Fade,
                                    ease: Curves.easeOut,
                                    duration: 0.3,
                                    pageBuilder: () => SearchChats(
                                        prefs: widget.prefs,
                                        currentUserNo: widget.currentUserNo,
                                        isSecuritySetupDone:
                                            widget.isSecuritySetupDone),
                                  ),
                                ],
                                child: SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: XDComponent5311()),
                              ),
                              const Spacer(
                                flex: 2,
                              ),
                              PopupMenuButton(
                                  onSelected: (value) {
                                    // selectedValue(value);
                                  },
                                  elevation: 3.2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: SizedBox(
                                      height: 23,
                                      width: 26,
                                      child: XDComponent5321()),
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (observer
                                                      .isAllowCreatingGroups ==
                                                  false) {
                                                Fiberchat.showRationale(
                                                    getTranslated(this.context,
                                                        'disabled'));
                                              } else {
                                                final AvailableContactsProvider
                                                    dbcontactsProvider =
                                                    Provider.of<
                                                            AvailableContactsProvider>(
                                                        context,
                                                        listen: false);
                                                dbcontactsProvider
                                                    .fetchContacts(
                                                        context,
                                                        _cachedModel,
                                                        widget.currentUserNo!,
                                                        widget.prefs);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddContactsToGroup(
                                                              currentUserNo: widget
                                                                  .currentUserNo,
                                                              model:
                                                                  _cachedModel,
                                                              biometricEnabled:
                                                                  false,
                                                              prefs:
                                                                  widget.prefs,
                                                              isAddingWhileCreatingGroup:
                                                                  true,
                                                            )));
                                              }
                                            },
                                            child: Text(
                                              "New Group",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          value: 1,
                                        ),
                                        PopupMenuItem(
                                          child: Text(
                                            "New Broadcast",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          value: 2,
                                        ),
                                        PopupMenuItem(
                                          child: Text(
                                            "Send Crypto",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          value: 3,
                                        ),
                                        PopupMenuItem(
                                          child: Text(
                                            "VPN",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          value: 4,
                                        ),
                                        PopupMenuItem(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Online Status",
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              // Padding(
                                              //   padding:
                                              //       const EdgeInsets.symmetric(horizontal: 5),
                                              //   child:
                                              //       CustomSwitch(
                                              //     activeColor: Color(0xff52cc56),
                                              //     value: true,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          value: 5,
                                        ),
                                        PopupMenuItem(
                                          child: InkWell(
                                            onTap: () {
                                              Fiberchat.invite(context);
                                            },
                                            child: Text(
                                              "Invite Friends",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          value: 6,
                                        ),
                                        PopupMenuItem(
                                          child: PageLink(
                                            links: [
                                              PageLinkInfo(
                                                transition: LinkTransition.Fade,
                                                ease: Curves.easeOut,
                                                duration: 0.3,
                                                pageBuilder: () => XDSettings(
                                                  currentUserNo:
                                                      widget.currentUserNo,
                                                  prefs: widget.prefs,
                                                ),
                                              ),
                                            ],
                                            child: Text(
                                              "Settings",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          value: 7,
                                        ),
                                        PopupMenuItem(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  // width: 210.0,
                                                  height: 1.0,
                                                  color:
                                                      const Color(0xFFE1E1E5),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    await logout(context);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    child: Text(
                                                      "Logout",
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                          value: 8,
                                        ),
                                      ]),
                              const Spacer(),
                            ],
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
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: ListView(children: [
                                PieChart(
                                  dataMap: dataMap,
                                  animationDuration:
                                      Duration(milliseconds: 800),
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 2,
                                  colorList: [
                                    Color(0xffF7931A),
                                    Color(0xffBA9F33),
                                    Color(0XFF627EEA),
                                  ],
                                  initialAngleInDegree: 0,
                                  chartType: ChartType.ring,
                                  ringStrokeWidth: 5,
                                  centerText: "My Wallet \n \$27.932.55",
                                  centerTextStyle: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 16.0,
                                    color: Color(0xff3F3D56),
                                    fontWeight: FontWeight.w600,
                                  ),

                                  legendOptions: LegendOptions(
                                    showLegendsInRow: false,
                                    showLegends: false,
                                  ),
                                  chartValuesOptions: ChartValuesOptions(
                                    showChartValueBackground: false,
                                    showChartValues: false,
                                    showChartValuesInPercentage: false,
                                    showChartValuesOutside: false,
                                    decimalPlaces: 1,
                                  ),
                                  // gradientList: ---To add gradient colors---
                                  // emptyColorGradient: ---Empty Color gradient---
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                coinWidget(),
                                coinWidget(),
                                coinWidget()
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 56.0, end: 17.0),
                  Pin(size: 56.0, end: 98.0),
                  child: PageLink(
                    links: [
                      PageLinkInfo(
                        transition: LinkTransition.Fade,
                        ease: Curves.easeOut,
                        duration: 0.3,
                        pageBuilder: () => XDExchange(),
                      ),
                    ],
                    child: XDComponent5304(),
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 56.0, end: 17.0),
                  Pin(size: 56.0, middle: 0.7712),
                  child: PageLink(
                    links: [
                      PageLinkInfo(
                        transition: LinkTransition.Fade,
                        ease: Curves.easeOut,
                        duration: 0.3,
                        pageBuilder: () => XDSend(),
                      ),
                    ],
                    child: XDComponent5291(),
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 56.0, end: 17.0),
                  Pin(size: 56.0, end: 24.0),
                  child: PageLink(
                    links: [
                      PageLinkInfo(
                        transition: LinkTransition.Fade,
                        ease: Curves.easeOut,
                        duration: 0.3,
                        pageBuilder: () => XDWallet(),
                      ),
                    ],
                    child: XDComponent5314(),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Padding coinWidget() {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: SizedBox(
        height: 100.0,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color(0xFFEFEFF2),
                ),
                child: SvgPicture.string(
                  // Path 14875
                  '<svg viewBox="63.64 434.74 289.08 54.26" ><path transform="translate(13889.0, -12449.0)" d="M -13825.361328125 12938 L -13808.5908203125 12931.5400390625 L -13801.978515625 12934.5458984375 C -13801.978515625 12934.5458984375 -13791.759765625 12932.7421875 -13786.9501953125 12931.5400390625 C -13782.140625 12930.337890625 -13777.33203125 12926.73046875 -13777.33203125 12926.73046875 C -13777.33203125 12926.73046875 -13762.9052734375 12926.12890625 -13761.1015625 12926.73046875 C -13759.2978515625 12927.33203125 -13755.0908203125 12925.52734375 -13753.287109375 12926.73046875 C -13751.4833984375 12927.93359375 -13733.44921875 12918.916015625 -13731.044921875 12920.1181640625 C -13728.640625 12921.3203125 -13723.8310546875 12922.5234375 -13723.8310546875 12922.5234375 C -13723.8310546875 12922.5234375 -13719.021484375 12927.3310546875 -13714.212890625 12920.1181640625 C -13709.404296875 12912.9052734375 -13703.994140625 12911.1015625 -13703.994140625 12911.1015625 L -13697.982421875 12911.1015625 C -13697.982421875 12911.1015625 -13697.9814453125 12910.5 -13694.9765625 12911.1015625 C -13691.9716796875 12911.703125 -13696.78125 12914.7080078125 -13687.763671875 12908.095703125 C -13678.74609375 12901.4833984375 -13675.138671875 12895.47265625 -13673.3359375 12891.2646484375 C -13671.533203125 12887.056640625 -13672.1337890625 12884.6513671875 -13669.7294921875 12884.6513671875 C -13667.3251953125 12884.6513671875 -13661.3134765625 12888.2587890625 -13661.3134765625 12888.2587890625 C -13661.3134765625 12888.2587890625 -13666.72265625 12897.8779296875 -13658.3076171875 12891.2646484375 C -13649.892578125 12884.6513671875 -13646.28515625 12882.24609375 -13643.880859375 12884.6513671875 C -13641.4765625 12887.056640625 -13635.46484375 12891.2646484375 -13635.46484375 12891.2646484375 L -13631.2568359375 12891.2646484375 L -13622.240234375 12891.2646484375 C -13622.240234375 12891.2646484375 -13621.0380859375 12886.4560546875 -13616.830078125 12891.2646484375 C -13612.6220703125 12896.0732421875 -13618.0322265625 12899.6796875 -13605.408203125 12897.275390625 C -13592.7841796875 12894.87109375 -13591.58203125 12899.6796875 -13587.3740234375 12897.275390625 C -13583.166015625 12894.87109375 -13575.3525390625 12896.673828125 -13573.548828125 12897.275390625 C -13571.7451171875 12897.876953125 -13564.53125 12900.8818359375 -13560.3232421875 12897.275390625 C -13556.115234375 12893.6689453125 -13562.728515625 12891.8662109375 -13554.3125 12891.2646484375 C -13545.896484375 12890.6630859375 -13541.0869140625 12891.2646484375 -13541.0869140625 12891.2646484375 L -13536.2783203125 12884.6513671875 L -13536.2783203125 12924.90625 C -13536.2783203125 12924.90625 -13536.2900390625 12930.32421875 -13538.98046875 12933.59765625 C -13541.6708984375 12936.87109375 -13547.0380859375 12938 -13547.0380859375 12938 L -13825.361328125 12938 Z" fill="#173051" fill-opacity="0.05" stroke="none" stroke-width="1" stroke-opacity="0.05" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    SvgPicture.string(
                      // bitcoin
                      '<svg viewBox="0.0 0.0 45.67 45.68" ><path  d="M 44.99117279052734 28.36197280883789 C 41.94092559814453 40.59649276733398 29.54867935180664 48.04154968261719 17.31272888183594 44.99129867553711 C 5.082486629486084 41.94105911254883 -2.363280296325684 29.54881286621094 0.6876786947250366 17.31500053405762 C 3.736496686935425 5.079050540924072 16.12802886962891 -2.367429733276367 28.36040878295898 0.6828154325485229 C 40.59564590454102 3.733060598373413 48.04070281982422 16.12673377990723 44.99045944213867 28.36197280883789 Z" fill="#f7931a" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-4.46, -3.19)" d="M 37.3670539855957 22.7764720916748 C 37.82094955444336 19.73764610290527 35.50722122192383 18.10404396057129 32.34349822998047 17.01426315307617 L 33.3697624206543 12.89778900146484 L 30.86333274841309 12.27332496643066 L 29.86418724060059 16.28132057189941 C 29.20617866516113 16.11717414855957 28.52961540222168 15.96230697631836 27.85733413696289 15.80886650085449 L 28.86361503601074 11.77446556091309 L 26.35933113098145 11.14999961853027 L 25.33235549926758 15.26504707336426 C 24.78710746765137 15.140869140625 24.25185203552246 15.01811408996582 23.73229598999023 14.88894081115723 L 23.73514938354492 14.87609481811523 L 20.27953720092773 14.01326179504395 L 19.61296463012695 16.68954086303711 C 19.61296463012695 16.68954086303711 21.47208595275879 17.1156063079834 21.43283462524414 17.14201164245605 C 22.44768142700195 17.39536666870117 22.63180732727051 18.06693267822266 22.60040664672852 18.59933471679688 L 21.4314079284668 23.28888893127441 C 21.50134658813477 23.30673217773438 21.59198379516602 23.33242416381836 21.69189834594727 23.37238883972168 L 21.42783737182617 23.30673217773438 L 19.78852653503418 29.87610626220703 C 19.66434669494629 30.18441390991211 19.34961700439453 30.64687728881836 18.64022445678711 30.47130966186523 C 18.66520309448242 30.50770568847656 16.81892776489258 30.01669883728027 16.81892776489258 30.01669883728027 L 15.57499313354492 32.88566970825195 L 18.83648490905762 33.69854736328125 C 19.44310760498047 33.85055923461914 20.03759956359863 34.00970840454102 20.62209892272949 34.15958023071289 L 19.58513259887695 38.32387161254883 L 22.08798789978027 38.94833755493164 L 23.11568069458008 34.82900619506836 C 23.79866790771484 35.01456451416016 24.46238327026367 35.18584442138672 25.11182975769043 35.34713745117188 L 24.08842277526855 39.44719696044922 L 26.5941333770752 40.07166290283203 L 27.63110160827637 35.91593551635742 C 31.90387153625488 36.72452545166016 35.11754989624023 36.39837646484375 36.46853637695312 32.53454208374023 C 37.55831527709961 29.42292022705078 36.41500854492188 27.62802886962891 34.16693496704102 26.4568920135498 C 35.80410385131836 26.07793045043945 37.03733062744141 25.0009937286377 37.36634063720703 22.7764720916748 Z M 31.6412410736084 30.80459594726562 C 30.8661937713623 33.91621780395508 25.6278190612793 32.23480224609375 23.92856025695801 31.81230163574219 L 25.30452537536621 26.29631233215332 C 27.00307083129883 26.72023582458496 32.44912338256836 27.55951690673828 31.64195442199707 30.80459594726562 Z M 32.41558074951172 22.73150825500488 C 31.70903968811035 25.56194305419922 27.34848976135254 24.12388801574707 25.93327140808105 23.77133369445801 L 27.18077278137207 18.76847457885742 C 28.59598922729492 19.12102890014648 33.15209197998047 19.77903938293457 32.41558074951172 22.73150825500488 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      width: width * 0.53,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'BTC',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: const Color(0xFF173051),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '2.932011',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: const Color(0xFF173051),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bitcoin',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: const Color(0xff173051),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                '\$19.000',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: const Color(0xff173051),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Container(
                              color: Color(0xff173051).withOpacity(0.2),
                              height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bitcoin',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: const Color(0xff173051),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '+34,3%',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: const Color(0xff52CC561),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  logout(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut();
    // await widget.prefs.remove(Dbkeys.phone);
    // await widget.prefs.remove('availablePhoneString');
    // await widget.prefs.remove('availablePhoneAndNameString');
    await widget.prefs.clear();

    // Navigator.pop(context);

    FlutterSecureStorage storage = new FlutterSecureStorage();
    // ignore: await_only_futures
    await storage.delete;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserNo)
        .update({
      Dbkeys.notificationTokens: [],
    });
    await widget.prefs.setBool(Dbkeys.isTokenGenerated, false);
    Navigator.of(context).pushAndRemoveUntil(
      // the new route
      MaterialPageRoute(
        builder: (BuildContext context) => FiberchatWrapper(),
      ),

      // this function should return true when we're done removing routes
      // but because we want to remove all other screens, we make it
      // always return false
      (Route route) => false,
    );
  }

  Column chatListWidget() {
    return Column(
      children: [
        Container(
          height: 100,
          child: Row(
            children: [
              SizedBox(
                width: 67.28,
                height: 67.28,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        alignment: Alignment.center,
                        width: 19.0,
                        height: 19.0,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Container(
                          width: 13.0,
                          height: 13.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF52CC56),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 55.56,
                        width: 55.56,
                        child: Image.asset(
                          'assets/images/girl3.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: SvgPicture.string(
                        // Exclusion 45
                        '<svg viewBox="0.0 0.0 67.28 67.28" ><path  d="M 33.63834762573242 67.27748107910156 C 29.0972728729248 67.27748107910156 24.69199752807617 66.38806915283203 20.5449047088623 64.63395690917969 C 16.53929328918457 62.93969345092773 12.94186019897461 60.51418685913086 9.852548599243164 57.42483520507812 C 6.763243198394775 54.33547592163086 4.337770462036133 50.73796844482422 2.64351224899292 46.73224258422852 C 0.8894066214561462 42.58503723144531 0 38.17961502075195 0 33.63834762573242 C 0 29.09726142883301 0.8894066214561462 24.69199562072754 2.64351224899292 20.54490280151367 C 4.337761878967285 16.5393009185791 6.763235092163086 12.9418773651123 9.852548599243164 9.852547645568848 C 12.9418773651123 6.763235092163086 16.5393009185791 4.337761878967285 20.5449047088623 2.64351224899292 C 24.69199752807617 0.8894066214561462 29.09726333618164 5.820766091346741e-11 33.63834762573242 5.820766091346741e-11 C 38.17961502075195 5.820766091346741e-11 42.58503723144531 0.8894066214561462 46.73224258422852 2.64351224899292 C 50.73796844482422 4.337770938873291 54.33547973632812 6.763243675231934 57.42483520507812 9.852547645568848 C 60.51418685913086 12.94186019897461 62.93969345092773 16.53929138183594 64.63395690917969 20.54490280151367 C 66.38806915283203 24.69199562072754 67.27748107910156 29.09727096557617 67.27748107910156 33.63834762573242 C 67.27748107910156 38.17961502075195 66.38806915283203 42.58503723144531 64.63395690917969 46.73224258422852 C 62.93967819213867 50.73796844482422 60.51418304443359 54.33547592163086 57.42483520507812 57.42483520507812 C 54.33547973632812 60.51417922973633 50.73796844482422 62.93967819213867 46.73224258422852 64.63395690917969 C 42.58503723144531 66.38806915283203 38.17961502075195 67.27748107910156 33.63834762573242 67.27748107910156 Z M 33.63834762573242 2.943296670913696 C 16.71304321289062 2.943296670913696 2.943296909332275 16.71304130554199 2.943296909332275 33.63834762573242 C 2.943296909332275 50.5640869140625 16.71304321289062 64.33418273925781 33.63834762573242 64.33418273925781 C 50.5640869140625 64.33418273925781 64.33418273925781 50.5640869140625 64.33418273925781 33.63834762573242 C 64.33418273925781 16.71304130554199 50.5640869140625 2.943296670913696 33.63834762573242 2.943296670913696 Z" fill="#d4af36" fill-opacity="0.3" stroke="none" stroke-width="1" stroke-opacity="0.3" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                        width: 67.28,
                        height: 67.28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 264,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Carla Yang',
                                    style: TextStyle(
                                      fontFamily: 'Open Sans',
                                      fontSize: 17,
                                      color: Color(0xff3f3d56),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    softWrap: false,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  SvgPicture.string(
                                    // path0
                                    '<svg viewBox="178.43 13.0 16.81 17.85" ><path transform="translate(177.46, 13.17)" d="M 1.277508735656738 1.132847666740417 C 1.018383979797363 1.289705038070679 0.9027814865112305 1.646101713180542 1.013968706130981 1.945366024971008 C 1.034172415733337 1.999733209609985 0.9119476675987244 1.74558699131012 2.045539617538452 2.880115747451782 L 4.090884685516357 4.927199840545654 L 3.827299833297729 4.927199840545654 C 3.257404327392578 4.927199840545654 2.833483457565308 5.177181720733643 2.586534738540649 5.658902645111084 L 2.488325834274292 5.85054874420166 L 2.488325834274292 8.759968757629395 L 2.488325834274292 11.66939067840576 L 2.583011150360107 11.86219501495361 C 2.703876733779907 12.1083402633667 2.954928636550903 12.3593921661377 3.201297521591187 12.48048210144043 L 3.394236326217651 12.57534503936768 L 5.049734115600586 12.59278297424316 L 6.705232620239258 12.6101770401001 L 9.80589771270752 15.08791637420654 C 11.51125717163086 16.45070457458496 12.95994758605957 17.59304237365723 13.02524089813232 17.62653541564941 C 13.20698547363281 17.71965789794922 13.53952217102051 17.68879508972168 13.703782081604 17.5634708404541 C 13.95113086700439 17.37485504150391 13.94988346099854 17.38203811645508 13.96928310394287 16.03334045410156 L 13.98668003082275 14.82228088378906 L 15.36302661895752 16.20112609863281 C 16.85738754272461 17.69820404052734 16.8355770111084 17.6799201965332 17.12654685974121 17.6799201965332 C 17.60706520080566 17.6799201965332 17.9118595123291 17.20832061767578 17.7183837890625 16.76415252685547 C 17.65425300598145 16.61688423156738 2.004797220230103 1.135969638824463 1.872469425201416 1.086820721626282 C 1.697237014770508 1.021794319152832 1.426427245140076 1.042711496353149 1.277508735656738 1.132847666740417 M 13.01359939575195 -0.1019578948616982 C 12.94375705718994 -0.06413730978965759 7.896090984344482 3.931867361068726 7.245960712432861 4.463986873626709 C 7.225979804992676 4.480354785919189 13.9071569442749 11.16416454315186 13.94350433349609 11.16416454315186 C 13.95813465118408 11.16416454315186 13.96602821350098 8.711668968200684 13.96098899841309 5.71416187286377 L 13.95184707641602 0.2641168832778931 L 13.84730339050293 0.1166701093316078 C 13.66203498840332 -0.1447736620903015 13.27843379974365 -0.2453461140394211 13.01359939575195 -0.1019578948616982" fill="#8c8b9a" fill-opacity="0.5" stroke="none" stroke-width="1" stroke-opacity="0.5" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                    width: 16.81,
                                    height: 17.85,

                                    allowDrawingOutsideViewBox: true,
                                    fit: BoxFit.fill,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SvgPicture.string(
                                    // Union 36
                                    '<svg viewBox="203.19 10.0 24.31 24.31" ><path transform="matrix(0.707107, 0.707107, -0.707107, 0.707107, -17639.82, -1750.7)" d="M 13879.095703125 -11361.837890625 C 13879.025390625 -11361.8369140625 13878.861328125 -11361.8505859375 13878.701171875 -11361.9912109375 C 13878.626953125 -11362.0517578125 13878.56640625 -11362.1259765625 13878.525390625 -11362.2099609375 C 13878.5009765625 -11362.25390625 13878.4765625 -11362.3017578125 13878.455078125 -11362.35546875 C 13878.2119140625 -11362.9423828125 13877.8505859375 -11365.123046875 13877.8505859375 -11365.123046875 L 13877.8505859375 -11369.048828125 L 13880.4375 -11369.048828125 L 13880.4375 -11365.7041015625 L 13880.4375 -11365.123046875 C 13880.4375 -11365.123046875 13880.046875 -11362.8447265625 13879.81640625 -11362.3115234375 C 13879.79296875 -11362.2568359375 13879.765625 -11362.2080078125 13879.73828125 -11362.1650390625 C 13879.6953125 -11362.091796875 13879.6376953125 -11362.029296875 13879.5693359375 -11361.9765625 C 13879.4404296875 -11361.876953125 13879.3076171875 -11361.84765625 13879.22265625 -11361.8408203125 C 13879.197265625 -11361.837890625 13879.1708984375 -11361.8369140625 13879.14453125 -11361.8369140625 C 13879.1279296875 -11361.8369140625 13879.1123046875 -11361.8369140625 13879.095703125 -11361.837890625 Z M 13885.009765625 -11369.048828125 L 13872.0009765625 -11369.048828125 C 13872 -11369.10546875 13871.9990234375 -11369.1552734375 13871.9990234375 -11369.2021484375 C 13871.9990234375 -11371.0146484375 13872.755859375 -11372.8701171875 13874.07421875 -11374.2958984375 C 13874.3974609375 -11374.6455078125 13874.7490234375 -11374.96484375 13875.1220703125 -11375.2431640625 C 13875.19921875 -11375.2998046875 13875.2783203125 -11375.3564453125 13875.3564453125 -11375.41015625 L 13875.3564453125 -11381.0390625 L 13875.3564453125 -11381.1455078125 L 13875.36328125 -11381.1455078125 C 13875.392578125 -11381.400390625 13875.5322265625 -11381.6279296875 13875.755859375 -11381.80078125 C 13875.90234375 -11381.9169921875 13876.1298828125 -11382 13876.376953125 -11382 L 13879.1982421875 -11382 L 13881.888671875 -11382 C 13882.0859375 -11382 13882.26953125 -11381.947265625 13882.4560546875 -11381.8369140625 C 13882.689453125 -11381.7021484375 13882.8681640625 -11381.4453125 13882.9033203125 -11381.1455078125 L 13882.91015625 -11381.1455078125 L 13882.91015625 -11375.3447265625 C 13883.80859375 -11374.7041015625 13884.5810546875 -11373.8505859375 13885.158203125 -11372.857421875 C 13885.482421875 -11372.3017578125 13885.7333984375 -11371.708984375 13885.9072265625 -11371.0947265625 C 13886.052734375 -11370.5791015625 13886.1396484375 -11370.05859375 13886.166015625 -11369.54296875 C 13886.201171875 -11369.4921875 13886.220703125 -11369.4326171875 13886.220703125 -11369.369140625 C 13886.220703125 -11369.310546875 13886.2041015625 -11369.255859375 13886.1748046875 -11369.208984375 C 13886.1748046875 -11369.205078125 13886.1748046875 -11369.201171875 13886.1748046875 -11369.197265625 C 13886.1748046875 -11369.14453125 13886.1748046875 -11369.0947265625 13886.173828125 -11369.048828125 L 13885.009765625 -11369.048828125 Z" fill="#8c8b9a" fill-opacity="0.5" stroke="none" stroke-width="1" stroke-opacity="0.5" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                    width: 14.22,
                                    height: 20.16,

                                    allowDrawingOutsideViewBox: true,
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                'Hi Good morning, how we...',
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: 'Open Sans',
                                  fontSize: 13,
                                  color: Color(0x993f3d56),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '11:16 PM',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 14,
                            color: Color(0x993f3d56),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1.0,
          color: const Color(0xFFE1E1E5),
        ),
      ],
    );
  }
}
