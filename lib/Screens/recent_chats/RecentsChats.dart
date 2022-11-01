import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Screens/Groups/GroupChatPage.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/chat_screen/utils/messagedata.dart';
import 'package:fiberchat/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/alias.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentChats extends StatefulWidget {
  RecentChats({required this.currentUserNo, required this.isSecuritySetupDone, required this.prefs, key})
      : super(key: key);
  final String? currentUserNo;
  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  State createState() => new RecentChatsState(currentUserNo: this.currentUserNo);
}

class RecentChatsState extends State<RecentChats> {
  RecentChatsState({Key? key, this.currentUserNo}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions = [];

  List<StreamController> controllers = [];

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  getuid(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getUserDetails(currentUserNo);
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  String? currentUserNo;

  bool isLoading = false;

  Widget buildItem(BuildContext context, Map<String, dynamic> user) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (user[Dbkeys.phone] == currentUserNo) {
      return Container(width: 0, height: 0);
    } else {
      return StreamBuilder(
        stream: getUnread(user).asBroadcastStream(),
        builder: (context, AsyncSnapshot<MessageData> unreadData) {
          int unread = unreadData.hasData && unreadData.data!.snapshot.docs.isNotEmpty
              ? unreadData.data!.snapshot.docs
                  .where((t) => t[Dbkeys.timestamp] > unreadData.data!.lastSeen)
                  .length
              : 0;
          return Theme(
            data: ThemeData(splashColor: fiberchatBlue, highlightColor: Colors.transparent),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  onLongPress: () {
                    unawaited(
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AliasForm(user, _cachedModel);
                        },
                      ),
                    );
                  },
                  leading: SizedBox(
                    width: 65,
                    height: 65,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: customCircleAvatar(
                              url: user['photoUrl'],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            alignment: Alignment.center,
                            width: 19.0,
                            height: 19.0,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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
                        SizedBox(
                          width: 65,
                          height: 65,
                          child: SvgPicture.string(
                            '<svg viewBox="0.0 0.0 67.28 67.28" ><path  d="M 33.63834762573242 67.27748107910156 C 29.0972728729248 67.27748107910156 24.69199752807617 66.38806915283203 20.5449047088623 64.63395690917969 C 16.53929328918457 62.93969345092773 12.94186019897461 60.51418685913086 9.852548599243164 57.42483520507812 C 6.763243198394775 54.33547592163086 4.337770462036133 50.73796844482422 2.64351224899292 46.73224258422852 C 0.8894066214561462 42.58503723144531 0 38.17961502075195 0 33.63834762573242 C 0 29.09726142883301 0.8894066214561462 24.69199562072754 2.64351224899292 20.54490280151367 C 4.337761878967285 16.5393009185791 6.763235092163086 12.9418773651123 9.852548599243164 9.852547645568848 C 12.9418773651123 6.763235092163086 16.5393009185791 4.337761878967285 20.5449047088623 2.64351224899292 C 24.69199752807617 0.8894066214561462 29.09726333618164 5.820766091346741e-11 33.63834762573242 5.820766091346741e-11 C 38.17961502075195 5.820766091346741e-11 42.58503723144531 0.8894066214561462 46.73224258422852 2.64351224899292 C 50.73796844482422 4.337770938873291 54.33547973632812 6.763243675231934 57.42483520507812 9.852547645568848 C 60.51418685913086 12.94186019897461 62.93969345092773 16.53929138183594 64.63395690917969 20.54490280151367 C 66.38806915283203 24.69199562072754 67.27748107910156 29.09727096557617 67.27748107910156 33.63834762573242 C 67.27748107910156 38.17961502075195 66.38806915283203 42.58503723144531 64.63395690917969 46.73224258422852 C 62.93967819213867 50.73796844482422 60.51418304443359 54.33547592163086 57.42483520507812 57.42483520507812 C 54.33547973632812 60.51417922973633 50.73796844482422 62.93967819213867 46.73224258422852 64.63395690917969 C 42.58503723144531 66.38806915283203 38.17961502075195 67.27748107910156 33.63834762573242 67.27748107910156 Z M 33.63834762573242 2.943296670913696 C 16.71304321289062 2.943296670913696 2.943296909332275 16.71304130554199 2.943296909332275 33.63834762573242 C 2.943296909332275 50.5640869140625 16.71304321289062 64.33418273925781 33.63834762573242 64.33418273925781 C 50.5640869140625 64.33418273925781 64.33418273925781 50.5640869140625 64.33418273925781 33.63834762573242 C 64.33418273925781 16.71304130554199 50.5640869140625 2.943296670913696 33.63834762573242 2.943296670913696 Z" fill="#d4af36" fill-opacity="0.3" stroke="none" stroke-width="1" stroke-opacity="0.3" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Row(
                    children: [
                      SizedBox(
                        width: width * 0.2,
                        child: Text(
                          Fiberchat.getNickname(user)!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 17,
                            color: Color(0xff3f3d56),
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SvgPicture.string(
                        // path0
                        '<svg viewBox="178.43 13.0 16.81 17.85" ><path transform="translate(177.46, 13.17)" d="M 1.277508735656738 1.132847666740417 C 1.018383979797363 1.289705038070679 0.9027814865112305 1.646101713180542 1.013968706130981 1.945366024971008 C 1.034172415733337 1.999733209609985 0.9119476675987244 1.74558699131012 2.045539617538452 2.880115747451782 L 4.090884685516357 4.927199840545654 L 3.827299833297729 4.927199840545654 C 3.257404327392578 4.927199840545654 2.833483457565308 5.177181720733643 2.586534738540649 5.658902645111084 L 2.488325834274292 5.85054874420166 L 2.488325834274292 8.759968757629395 L 2.488325834274292 11.66939067840576 L 2.583011150360107 11.86219501495361 C 2.703876733779907 12.1083402633667 2.954928636550903 12.3593921661377 3.201297521591187 12.48048210144043 L 3.394236326217651 12.57534503936768 L 5.049734115600586 12.59278297424316 L 6.705232620239258 12.6101770401001 L 9.80589771270752 15.08791637420654 C 11.51125717163086 16.45070457458496 12.95994758605957 17.59304237365723 13.02524089813232 17.62653541564941 C 13.20698547363281 17.71965789794922 13.53952217102051 17.68879508972168 13.703782081604 17.5634708404541 C 13.95113086700439 17.37485504150391 13.94988346099854 17.38203811645508 13.96928310394287 16.03334045410156 L 13.98668003082275 14.82228088378906 L 15.36302661895752 16.20112609863281 C 16.85738754272461 17.69820404052734 16.8355770111084 17.6799201965332 17.12654685974121 17.6799201965332 C 17.60706520080566 17.6799201965332 17.9118595123291 17.20832061767578 17.7183837890625 16.76415252685547 C 17.65425300598145 16.61688423156738 2.004797220230103 1.135969638824463 1.872469425201416 1.086820721626282 C 1.697237014770508 1.021794319152832 1.426427245140076 1.042711496353149 1.277508735656738 1.132847666740417 M 13.01359939575195 -0.1019578948616982 C 12.94375705718994 -0.06413730978965759 7.896090984344482 3.931867361068726 7.245960712432861 4.463986873626709 C 7.225979804992676 4.480354785919189 13.9071569442749 11.16416454315186 13.94350433349609 11.16416454315186 C 13.95813465118408 11.16416454315186 13.96602821350098 8.711668968200684 13.96098899841309 5.71416187286377 L 13.95184707641602 0.2641168832778931 L 13.84730339050293 0.1166701093316078 C 13.66203498840332 -0.1447736620903015 13.27843379974365 -0.2453461140394211 13.01359939575195 -0.1019578948616982" fill="#8c8b9a" fill-opacity="0.5" stroke="none" stroke-width="1" stroke-opacity="0.5" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',

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
                  subtitle: SizedBox(
                    width: width * 2,
                    child: Text(
                      Fiberchat.getInitials(''),
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Open Sans',
                        fontSize: 13,
                        color: Color(0x993f3d56),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (_cachedModel!.currentUser![Dbkeys.locked] != null &&
                        _cachedModel!.currentUser![Dbkeys.locked].contains(user[Dbkeys.username])) {
                      MaterialPageRoute(
                          builder: (context) => new ChatScreen(
                              isSharingIntentForwarded: false,
                              prefs: widget.prefs,
                              unread: unread,
                              model: _cachedModel!,
                              currentUserNo: currentUserNo,
                              peerNo: user[Dbkeys.phone] as String?));
                    } else {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ChatScreen(
                                  isSharingIntentForwarded: false,
                                  prefs: widget.prefs,
                                  unread: unread,
                                  model: _cachedModel!,
                                  currentUserNo: currentUserNo,
                                  peerNo: user[Dbkeys.phone] as String?)));
                    }
                  },
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: width * 0.17,
                        child: Text(
                          '11:30 PM',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 14,
                            color: Color(0x993f3d56),
                          ),
                        ),
                      ),
                      Text(
                        '',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 14,
                          color: Color(0x993f3d56),
                        ),
                      ),
                    ],
                  ),
                  // Container(

                  //   child: Text(unread.toString(),
                  //       style: TextStyle(
                  //           fontSize: 14,
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold)),
                  //   padding: const EdgeInsets.all(7.0),
                  //   decoration: new BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: user[Dbkeys.lastSeen] == true
                  //         ? Colors.green[400]
                  //         : Colors.blue[400],
                  //   ),
                  // )
                  // : user[Dbkeys.lastSeen] == true
                  //     ? Container(
                  //         child: Container(width: 0, height: 0),
                  //         padding: const EdgeInsets.all(7.0),
                  //         decoration: new BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: Colors.green[400]),
                  //       )
                  //     : SizedBox(
                  //         height: 0,
                  //         width: 0,
                  //       ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  height: 1.0,
                  color: const Color(0xFFE1E1E5),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Stream<MessageData> getUnread(Map<String, dynamic> user) {
    String chatId = Fiberchat.getChatId(currentUserNo, user[Dbkeys.phone]);
    var controller = StreamController<MessageData>.broadcast();
    unreadSubscriptions.add(FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc[currentUserNo!] != null && doc[currentUserNo!] is int) {
        unreadSubscriptions.add(FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .collection(chatId)
            .snapshots()
            .listen((snapshot) {
          controller.add(MessageData(snapshot: snapshot, lastSeen: doc[currentUserNo!]));
        }));
      }
    }));
    controllers.add(controller);
    return controller.stream;
  }

  _isHidden(phoneNo) {
    Map<String, dynamic> _currentUser = _cachedModel!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null && _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  StreamController<String> _userQuery = new StreamController<String>.broadcast();

  List<Map<String, dynamic>> _streamDocSnap = [];

  _chats(Map<String?, Map<String, dynamic>?> _userData, Map<String, dynamic>? currentUser) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) =>
            Consumer<List<BroadcastModel>>(builder: (context, broadcastList, _child) {
              _streamDocSnap = Map.from(_userData)
                  .values
                  .where((_user) => _user.keys.contains(Dbkeys.chatStatus))
                  .toList()
                  .cast<Map<String, dynamic>>();
              Map<String?, int?> _lastSpokenAt = _cachedModel!.lastSpokenAt;
              List<Map<String, dynamic>> filtered = List.from(<Map<String, dynamic>>[]);
              groupList.forEach((element) {
                _streamDocSnap.add(element.docmap);
              });
              broadcastList.forEach((element) {
                _streamDocSnap.add(element.docmap);
              });
              _streamDocSnap.sort((a, b) {
                int aTimestamp = a.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? a[Dbkeys.groupLATESTMESSAGETIME]
                    : a.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? a[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[a[Dbkeys.phone]] ?? 0;
                int bTimestamp = b.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? b[Dbkeys.groupLATESTMESSAGETIME]
                    : b.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? b[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[b[Dbkeys.phone]] ?? 0;
                return bTimestamp - aTimestamp;
              });

              if (!showHidden) {
                _streamDocSnap.removeWhere((_user) =>
                    !_user.containsKey(Dbkeys.groupISTYPINGUSERID) &&
                    !_user.containsKey(Dbkeys.broadcastBLACKLISTED) &&
                    _isHidden(_user[Dbkeys.phone]));
              }

              return ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                shrinkWrap: true,
                children: [
                  Container(
                      child: _streamDocSnap.isNotEmpty
                          ? StreamBuilder(
                              stream: _userQuery.stream.asBroadcastStream(),
                              builder: (context, snapshot) {
                                if (_filter.text.isNotEmpty || snapshot.hasData) {
                                  filtered = this._streamDocSnap.where((user) {
                                    return user[Dbkeys.nickname].toLowerCase().trim().contains(
                                        new RegExp(r'' + _filter.text.toLowerCase().trim() + ''));
                                  }).toList();
                                  if (filtered.isNotEmpty)
                                    return ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(10.0),
                                      itemBuilder: (context, index) =>
                                          buildItem(context, filtered.elementAt(index)),
                                      itemCount: filtered.length,
                                    );
                                  else
                                    return ListView(
                                        physics: AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context).size.height / 3.5),
                                              child: Center(
                                                child: Text(getTranslated(context, 'nosearchresult'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: fiberchatGrey,
                                                    )),
                                              ))
                                        ]);
                                }
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 120),
                                  itemBuilder: (context, index) {
                                    if (_streamDocSnap[index].containsKey(Dbkeys.groupISTYPINGUSERID)) {
                                      ///----- Build Group Chat Tile ----
                                      return Theme(
                                        data: ThemeData(
                                            splashColor: fiberchatBlue,
                                            highlightColor: Colors.transparent),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.all(0),
                                              leading: SizedBox(
                                                width: 65,
                                                height: 65,
                                                child: Stack(
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: SizedBox(
                                                        height: 45,
                                                        width: 45,
                                                        child: customCircleAvatarGroup(
                                                            url: _streamDocSnap[index]
                                                                [Dbkeys.groupPHOTOURL],
                                                            radius: 22),
                                                      ),
                                                    ),
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
                                                    SizedBox(
                                                      width: 65,
                                                      height: 65,
                                                      child: SvgPicture.string(
                                                        '<svg viewBox="0.0 0.0 67.28 67.28" ><path  d="M 33.63834762573242 67.27748107910156 C 29.0972728729248 67.27748107910156 24.69199752807617 66.38806915283203 20.5449047088623 64.63395690917969 C 16.53929328918457 62.93969345092773 12.94186019897461 60.51418685913086 9.852548599243164 57.42483520507812 C 6.763243198394775 54.33547592163086 4.337770462036133 50.73796844482422 2.64351224899292 46.73224258422852 C 0.8894066214561462 42.58503723144531 0 38.17961502075195 0 33.63834762573242 C 0 29.09726142883301 0.8894066214561462 24.69199562072754 2.64351224899292 20.54490280151367 C 4.337761878967285 16.5393009185791 6.763235092163086 12.9418773651123 9.852548599243164 9.852547645568848 C 12.9418773651123 6.763235092163086 16.5393009185791 4.337761878967285 20.5449047088623 2.64351224899292 C 24.69199752807617 0.8894066214561462 29.09726333618164 5.820766091346741e-11 33.63834762573242 5.820766091346741e-11 C 38.17961502075195 5.820766091346741e-11 42.58503723144531 0.8894066214561462 46.73224258422852 2.64351224899292 C 50.73796844482422 4.337770938873291 54.33547973632812 6.763243675231934 57.42483520507812 9.852547645568848 C 60.51418685913086 12.94186019897461 62.93969345092773 16.53929138183594 64.63395690917969 20.54490280151367 C 66.38806915283203 24.69199562072754 67.27748107910156 29.09727096557617 67.27748107910156 33.63834762573242 C 67.27748107910156 38.17961502075195 66.38806915283203 42.58503723144531 64.63395690917969 46.73224258422852 C 62.93967819213867 50.73796844482422 60.51418304443359 54.33547592163086 57.42483520507812 57.42483520507812 C 54.33547973632812 60.51417922973633 50.73796844482422 62.93967819213867 46.73224258422852 64.63395690917969 C 42.58503723144531 66.38806915283203 38.17961502075195 67.27748107910156 33.63834762573242 67.27748107910156 Z M 33.63834762573242 2.943296670913696 C 16.71304321289062 2.943296670913696 2.943296909332275 16.71304130554199 2.943296909332275 33.63834762573242 C 2.943296909332275 50.5640869140625 16.71304321289062 64.33418273925781 33.63834762573242 64.33418273925781 C 50.5640869140625 64.33418273925781 64.33418273925781 50.5640869140625 64.33418273925781 33.63834762573242 C 64.33418273925781 16.71304130554199 50.5640869140625 2.943296670913696 33.63834762573242 2.943296670913696 Z" fill="#d4af36" fill-opacity="0.3" stroke="none" stroke-width="1" stroke-opacity="0.3" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              title: Row(
                                                children: [
                                                  SizedBox(
                                                    width: width * 0.2,
                                                    child: Text(
                                                      _streamDocSnap[index][Dbkeys.groupNAME],
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Open Sans',
                                                        fontSize: 17,
                                                        color: Color(0xff3f3d56),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
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
                                              subtitle: SizedBox(
                                                width: width * 0.2,
                                                child: Text(
                                                  '${_streamDocSnap[index][Dbkeys.groupMEMBERSLIST].length} ${getTranslated(context, 'participants')}',
                                                  style: TextStyle(
                                                    overflow: TextOverflow.ellipsis,
                                                    fontFamily: 'Open Sans',
                                                    fontSize: 13,
                                                    color: Color(0x993f3d56),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) => new GroupChatPage(
                                                            isSharingIntentForwarded: false,
                                                            model: _cachedModel!,
                                                            prefs: widget.prefs,
                                                            joinedTime: _streamDocSnap[index]
                                                                ['${widget.currentUserNo}-joinedOn'],
                                                            currentUserno: widget.currentUserNo!,
                                                            groupID: _streamDocSnap[index]
                                                                [Dbkeys.groupID])));
                                              },
                                              trailing: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  SizedBox(
                                                    width: width * 0.17,
                                                    child: Text(
                                                      '12:00 AM',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Open Sans',
                                                        fontSize: 14,
                                                        color: Color(0x993f3d56),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '',
                                                    style: TextStyle(
                                                      fontFamily: 'Open Sans',
                                                      fontSize: 14,
                                                      color: Color(0x993f3d56),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // StreamBuilder(
                                              //   stream: FirebaseFirestore
                                              //       .instance
                                              //       .collection(DbPaths
                                              //           .collectiongroups)
                                              //       .doc(_streamDocSnap[index]
                                              //           [Dbkeys.groupID])
                                              //       .collection(DbPaths
                                              //           .collectiongroupChats)
                                              //       .where(
                                              //           Dbkeys.groupmsgTIME,
                                              //           isGreaterThan:
                                              //               _streamDocSnap[
                                              //                       index][
                                              //                   widget
                                              //                       .currentUserNo])
                                              //       .snapshots(),
                                              //   builder:
                                              //       (BuildContext context,
                                              //           AsyncSnapshot<
                                              //                   QuerySnapshot<
                                              //                       dynamic>>
                                              //               snapshot) {
                                              //     if (snapshot
                                              //             .connectionState ==
                                              //         ConnectionState
                                              //             .waiting) {
                                              //       return SizedBox(
                                              //         height: 0,
                                              //         width: 0,
                                              //       );
                                              //     } else if (snapshot
                                              //             .hasData &&
                                              //         snapshot.data!.docs
                                              //                 .length >
                                              //             0) {
                                              //       return Container(
                                              //         child: Text(
                                              //             '${snapshot.data!.docs.length}',
                                              //             style: TextStyle(
                                              //                 fontSize: 14,
                                              //                 color: Colors
                                              //                     .white,
                                              //                 fontWeight:
                                              //                     FontWeight
                                              //                         .bold)),
                                              //         padding:
                                              //             const EdgeInsets
                                              //                 .all(7.0),
                                              //         decoration:
                                              //             new BoxDecoration(
                                              //           shape:
                                              //               BoxShape.circle,
                                              //           color:
                                              //               Colors.blue[400],
                                              //         ),
                                              //       );
                                              //     }
                                              //     return SizedBox(
                                              //       height: 0,
                                              //       width: 0,
                                              //     );
                                              //   },
                                              // ),
                                            ),
                                            SizedBox(
                                              height: height * 0.01,
                                            ),
                                            Container(
                                              height: 1.0,
                                              color: const Color(0xFFE1E1E5),
                                            ),
                                            SizedBox(
                                              height: height * 0.01,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return buildItem(context, _streamDocSnap.elementAt(index));
                                    }
                                  },
                                  itemCount: _streamDocSnap.length,
                                );
                              })
                          : ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0),
                              children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.5),
                                      child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.all(30.0),
                                            child: Text(
                                                groupList.length != 0
                                                    ? ''
                                                    : getTranslated(context, 'startchat'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  height: 1.59,
                                                  color: fiberchatGrey,
                                                ))),
                                      ))
                                ])),
                ],
              );
            }));
  }

  Widget buildGroupitem() {
    return Text(
      Dbkeys.groupNAME,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: getModel()!,
      child: ScopedModelDescendant<DataModel>(builder: (context, child, _model) {
        _cachedModel = _model;
        return Scaffold(
          backgroundColor: fiberchatWhite,
          body: RefreshIndicator(
            onRefresh: () {
              isAuthenticating = !isAuthenticating;
              setState(() {
                showHidden = !showHidden;
              });
              return Future.value(true);
            },
            child: _chats(_model.userData, _model.currentUser),
          ),
        );
      }),
    ));
  }
}
