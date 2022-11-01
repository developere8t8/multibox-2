import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Configs/Dbkeys.dart';
import '../../Configs/Dbpaths.dart';
import '../../Models/DataModel.dart';
import '../../Services/Providers/AvailableContactsProvider.dart';
import '../../Services/Providers/Observer.dart';
import '../../Services/localization/language_constants.dart';
import '../../Utils/utils.dart';
import '../../main.dart';
import '../../widgets/componentss/xd_component5272.dart';
import '../../widgets/componentss/xd_component5301.dart';
import '../../widgets/componentss/xd_component5311.dart';
import '../../widgets/componentss/xd_component5321.dart';
import '../../widgets/componentss/xd_component5327.dart';
import '../../widgets/componentss/xd_component5331.dart';
import '../Groups/AddContactsToGroup.dart';
import '../homepage/homepage.dart';
import '../search_chats/SearchRecentChat.dart';
import '../settings/settings.dart';
import '../wallet/xd_mainpage_crypto.dart';

class XDMainpageLocation extends StatefulWidget {
  XDMainpageLocation(
      {required this.currentUserNo,
      required this.isSecuritySetupDone,
      required this.prefs,
      key})
      : super(key: key);
  final String? currentUserNo;
  final bool isSecuritySetupDone;
  final SharedPreferences prefs;

  @override
  State<XDMainpageLocation> createState() => _XDMainpageLocationState();
}

class _XDMainpageLocationState extends State<XDMainpageLocation> {
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

  String? currentUserNo;
  DataModel? _cachedModel;

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  var status;

  @override
  // ignore: must_call_super
  void initState() {
    status = true;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(context, listen: true);

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
                              child: const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: XDComponent5301(
                                    color: Color(0xff748397),
                                  )),
                            ),
                            const Spacer(),
                            PageLink(
                              links: [
                                PageLinkInfo(
                                  transition: LinkTransition.Fade,
                                  ease: Curves.easeOut,
                                  duration: 0.3,
                                  pageBuilder: () => XDMainpageCrypto(
                                    currentUserNo: widget.currentUserNo,
                                    isSecuritySetupDone:
                                        widget.isSecuritySetupDone,
                                    prefs: widget.prefs,
                                  ),
                                ),
                              ],
                              child: SizedBox(
                                height: 28,
                                width: 28,
                                child: SvgPicture.string(
                                  '<svg viewBox="0.0 0.0 28.17 28.21" ><path transform="translate(-0.39, 0.43)" d="M 12.76949405670166 -0.3323599696159363 C 5.693131923675537 0.4664138555526733 0.3910000026226044 6.459858417510986 0.3910000026226044 13.66001987457275 C 0.3910000026226044 17.75064659118652 1.766795039176941 21.03017616271973 4.661126613616943 23.83880805969238 C 12.04628086090088 31.00509834289551 24.55033683776855 27.97330474853516 27.80867004394531 18.22633361816406 C 31.10221290588379 8.374085426330566 23.10179710388184 -1.498655796051025 12.76949405670166 -0.3323599696159363 M 14.94258403778076 5.096950531005859 C 15.20623683929443 5.292788505554199 15.28623294830322 5.51263952255249 15.32193660736084 6.139729499816895 C 15.35348415374756 6.694146156311035 15.36228656768799 6.727665901184082 15.49277496337891 6.789635181427002 C 16.75392913818359 7.389050483703613 16.71822547912598 7.366867542266846 17.20010948181152 7.851287364959717 C 18.58900260925293 9.247433662414551 18.7857551574707 11.4306640625 17.52270317077637 11.43172073364258 C 17.00863647460938 11.43214321136475 16.7418155670166 11.11222457885742 16.65118598937988 10.3868989944458 C 16.37260437011719 8.157684326171875 13.41890716552734 7.637070178985596 12.43598556518555 9.643898963928223 C 12.05219554901123 10.42760276794434 12.24690818786621 11.5487585067749 12.8761100769043 12.17803192138672 C 13.30567073822021 12.60752296447754 13.66227912902832 12.74906826019287 14.53414916992188 12.83617687225342 C 18.11282348632812 13.19377040863037 19.65325927734375 17.05792427062988 17.20010948181152 19.5238208770752 C 16.71801376342773 20.00838279724121 16.75576019287109 19.98493385314941 15.49277496337891 20.58547401428223 C 15.36249923706055 20.6474437713623 15.35327434539795 20.68216133117676 15.31855583190918 21.24122428894043 C 15.26539039611816 22.0965461730957 15.01842594146729 22.43505477905273 14.44746112823486 22.43505477905273 C 13.87494659423828 22.43505477905273 13.62150478363037 22.08739280700684 13.5729866027832 21.23538208007812 C 13.54143905639648 20.68096351623535 13.53263473510742 20.6474437713623 13.40214824676514 20.58547401428223 C 12.14099597930908 19.98605918884277 12.17669868469238 20.00824165344238 11.69481468200684 19.5238208770752 C 10.30592250823975 18.12767601013184 10.10916709899902 15.94444465637207 11.37222099304199 15.94338798522949 C 11.88304805755615 15.94296646118164 12.15317821502686 16.26337623596191 12.24204921722412 16.97490119934082 C 12.5219669342041 19.21510124206543 15.4729175567627 19.7443790435791 16.45893859863281 17.73121070861816 C 16.70040893554688 17.23812866210938 16.70040893554688 16.29872703552246 16.45893859863281 15.8056468963623 C 16.06845855712891 15.00842189788818 15.47517013549805 14.65026664733887 14.36077404022217 14.53893184661865 C 10.78210067749023 14.1813383102417 9.241663932800293 10.31718444824219 11.69481468200684 7.851287364959717 C 12.17691040039062 7.366727352142334 12.13916492462158 7.390177249908447 13.40214824676514 6.789635181427002 C 13.5324239730835 6.727665901184082 13.54164886474609 6.692948818206787 13.57636737823486 6.133884906768799 C 13.64270305633545 5.066529273986816 14.26535511016846 4.593940258026123 14.94258403778076 5.096950531005859" fill="#748397" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                ),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                                height: 28.9,
                                width: 25.6,
                                child: Stack(
                                  children: <Widget>[
                                    SizedBox.expand(
                                        child:
                                            // Adobe XD layer: 'path0' (shape)
                                            SvgPicture.string(
                                      '<svg viewBox="0.0 0.0 25.7 29.0" ><path transform="translate(-22.79, 0.44)" d="M 33.89828109741211 -0.3219688236713409 C 26.44837188720703 0.6901537775993347 21.4747142791748 7.841768264770508 23.10240936279297 15.2014684677124 C 24.12242317199707 19.81376266479492 27.67604064941406 23.54867553710938 32.21049499511719 24.77431678771973 L 32.88666915893555 24.95705986022949 L 34.23344039916992 26.75396156311035 C 34.97419738769531 27.74218940734863 35.59968566894531 28.55079078674316 35.62350463867188 28.55079078674316 C 35.64731979370117 28.55079078674316 36.27353286743164 27.74124908447266 37.01515960693359 26.75178909301758 L 38.363525390625 24.9528636932373 L 38.95166015625 24.79871559143066 C 43.36179733276367 23.6433048248291 46.89991760253906 20.07600784301758 48.03730392456055 15.63820362091064 C 50.30670547485352 6.783597469329834 42.92549896240234 -1.548332333564758 33.89828109741211 -0.3219688236713409 M 37.46189117431641 3.146645784378052 C 44.63913726806641 4.686949253082275 47.44222259521484 13.28713035583496 42.52069091796875 18.66747665405273 C 38.82335662841797 22.70945358276367 32.42364883422852 22.70945358276367 28.726318359375 18.66747665405273 C 23.57447624206543 13.03538513183594 26.86360359191895 4.152252197265625 34.52051544189453 3.019144296646118 C 35.01198577880859 2.946451187133789 36.91278839111328 3.02884578704834 37.46189117431641 3.146645784378052 M 34.35079956054688 4.711783409118652 C 28.79865074157715 5.649909973144531 26.06412887573242 12.0352087020874 29.22314643859863 16.68508148193359 C 32.80593872070312 21.95841598510742 41.00529479980469 20.82009315490723 42.96662139892578 14.77704238891602 C 44.76374053955078 9.239944458007812 40.06166839599609 3.746867418289185 34.35079956054688 4.711783409118652" fill="#748397" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                      allowDrawingOutsideViewBox: true,
                                      fit: BoxFit.fill,
                                      color: Colors.white,
                                    )),
                                  ],
                                )),
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
                                                  dbcontactsProvider = Provider
                                                      .of<AvailableContactsProvider>(
                                                          context,
                                                          listen: false);
                                              dbcontactsProvider.fetchContacts(
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
                                                            model: _cachedModel,
                                                            biometricEnabled:
                                                                false,
                                                            prefs: widget.prefs,
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
                                                color: const Color(0xFFE1E1E5),
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
                              Container(
                                width: 302.0,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.16),
                                      offset: const Offset(0, 0),
                                      blurRadius: 12.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: TextField(
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          20, 15, 0, 15),
                                      suffixIcon: const Icon(
                                        Icons.search,
                                        color: Color(0xff3F3D56),
                                        size: 28,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: 'Open Sans',
                                        fontSize: 19,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                      hintText: "Search destination...",
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          borderSide: BorderSide.none),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                              )
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
                child: XDComponent5327(),
              ),
              Pinned.fromPins(
                Pin(size: 56.0, end: 17.0),
                Pin(size: 56.0, end: 24.0),
                child: XDComponent5331(),
              ),
              Pinned.fromPins(
                Pin(size: 56.0, end: 17.0),
                Pin(size: 56.0, middle: 0.7725),
                child: XDComponent5272(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
