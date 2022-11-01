import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/chat_screen/utils/messagedata.dart';
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

class SearchChats extends StatefulWidget {
  SearchChats({required this.currentUserNo, required this.isSecuritySetupDone, required this.prefs, key})
      : super(key: key);
  final String? currentUserNo;
  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  State createState() => new SearchChatsState(currentUserNo: this.currentUserNo);
}

class SearchChatsState extends State<SearchChats> {
  SearchChatsState({Key? key, this.currentUserNo}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions = List.from(<StreamSubscription>[]);

  List<StreamController> controllers = new List.from(<StreamController>[]);

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
                      onLongPress: () {
                        unawaited(showDialog(
                            context: context,
                            builder: (context) {
                              return AliasForm(user, _cachedModel);
                            }));
                      },
                      leading: customCircleAvatar(url: user['photoUrl'], radius: 22),
                      title: Text(
                        Fiberchat.getNickname(user)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fiberchatBlack,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        if (_cachedModel!.currentUser![Dbkeys.locked] != null &&
                            _cachedModel!.currentUser![Dbkeys.locked].contains(user[Dbkeys.phone])) {
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
                      trailing: unread != 0
                          ? Container(
                              child: Text(unread.toString(),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                              padding: const EdgeInsets.all(7.0),
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    user[Dbkeys.lastSeen] == true ? Colors.green[400] : Colors.blue[300],
                              ),
                            )
                          : user[Dbkeys.lastSeen] == true
                              ? Container(
                                  child: Container(width: 0, height: 0),
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle, color: Colors.green[400]),
                                )
                              : SizedBox(
                                  height: 0,
                                  width: 0,
                                )),
                  Divider(),
                ],
              ));
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

  List<Map<String, dynamic>> _users = List.from(<Map<String, dynamic>>[]);

  _chats(Map<String?, Map<String, dynamic>?> _userData, Map<String, dynamic>? currentUser) {
    _users = Map.from(_userData)
        .values
        .where((_user) => _user.keys.contains(Dbkeys.chatStatus))
        .toList()
        .cast<Map<String, dynamic>>();
    Map<String?, int?> _lastSpokenAt = _cachedModel!.lastSpokenAt;
    List<Map<String, dynamic>> filtered = List.from(<Map<String, dynamic>>[]);

    _users.sort((a, b) {
      int aTimestamp = _lastSpokenAt[a[Dbkeys.phone]] ?? 0;
      int bTimestamp = _lastSpokenAt[b[Dbkeys.phone]] ?? 0;
      return bTimestamp - aTimestamp;
    });

    if (!showHidden) {
      _users.removeWhere((_user) => _isHidden(_user[Dbkeys.phone]));
    }

    return Stack(
      children: <Widget>[
        RefreshIndicator(
            onRefresh: () {
              isAuthenticating = false;
              setState(() {
                showHidden = true;
              });
              return Future.value(false);
            },
            child: Container(
                child: _users.isNotEmpty
                    ? StreamBuilder(
                        stream: _userQuery.stream.asBroadcastStream(),
                        builder: (context, snapshot) {
                          if (_filter.text.isNotEmpty || snapshot.hasData) {
                            filtered = this._users.where((user) {
                              return user[Dbkeys.nickname]
                                  .toLowerCase()
                                  .trim()
                                  .contains(new RegExp(r'' + _filter.text.toLowerCase().trim() + ''));
                            }).toList();
                            if (filtered.isNotEmpty)
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0.0),
                                itemBuilder: (context, index) =>
                                    buildItem(context, filtered.elementAt(index)),
                                itemCount: filtered.length,
                              );
                            else
                              return ListView(shrinkWrap: true, children: [
                                Padding(
                                    padding:
                                        EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.5),
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
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                            itemBuilder: (context, index) => buildItem(context, _users.elementAt(index)),
                            itemCount: _users.length,
                          );
                        })
                    : ListView(shrinkWrap: true, padding: EdgeInsets.all(0), children: [
                        Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10.5),
                            child: Center(
                              child: Padding(
                                  padding: EdgeInsets.all(30.0),
                                  child: Text(getTranslated(context, 'nochats'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.59,
                                        color: fiberchatGrey,
                                      ))),
                            )),
                        // will implement Google ads here in next update
                      ]))),
      ],
    );
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Fiberchat.getNTPWrappedWidget(
      ScopedModel<DataModel>(
        model: getModel()!,
        child: ScopedModelDescendant<DataModel>(
          builder: (context, child, _model) {
            _cachedModel = _model;
            // will implement Google ads here in next update
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
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Container(
                                            height: 77,
                                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 7),
                                            child: TextField(
                                              autocorrect: true,
                                              style: TextStyle(
                                                fontFamily: 'Open Sans',
                                                fontSize: 16.0,
                                                color: Colors.white,
                                              ),
                                              textCapitalization: TextCapitalization.sentences,
                                              controller: _filter,
                                              decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                  hintText: 'Search...',
                                                  hintStyle: TextStyle(
                                                    fontFamily: 'Open Sans',
                                                    fontSize: 16.0,
                                                    color: Colors.white,
                                                  ),
                                                  filled: true,
                                                  fillColor: Color(0xff3A4F6B),
                                                  disabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                    borderSide:
                                                        BorderSide(color: Color(0xff3A4F6B), width: 1),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                    borderSide:
                                                        BorderSide(color: Color(0xff3A4F6B), width: 1),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                    borderSide:
                                                        BorderSide(color: Color(0xff3A4F6B), width: 1),
                                                  ),
                                                  suffixIcon: Icon(
                                                    Icons.search,
                                                    color: Colors.white,
                                                  )),
                                            )),
                                      ),

                                      // IconButton(
                                      //   icon: _searchIcon,
                                      //   onPressed: _searchPressed,
                                      // )
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
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: _chats(_model.userData, _model.currentUser),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //                             Scaffold(
  // key: scaffoldState,
  // backgroundColor: fiberchatWhite,
  // bottomSheet: IsBannerAdShow == true &&
  //         observer.isadmobshow == true &&
  //         adWidget != null
  //     ? Container(
  //         height: 60,
  //         margin: EdgeInsets.only(
  //             bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
  //         child: Center(child: adWidget),
  //       )
  //     : SizedBox(
  //         height: 0,
  //       ),
  // body: ListView(
  //     padding: IsBannerAdShow == true && observer.isadmobshow == true
  //         ? EdgeInsets.fromLTRB(5, 5, 5, 60)
  //         : EdgeInsets.all(5),
  //     shrinkWrap: true,
  //     children: [
  //       Container(
  //           height: 77,
  //           padding: const EdgeInsets.fromLTRB(10, 15, 10, 7),
  //           child: TextField(
  //             autocorrect: true,
  //             textCapitalization: TextCapitalization.sentences,
  //             controller: _filter,
  //             decoration: InputDecoration(
  //               contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //               hintText:
  //                   getTranslated(context, 'search_recentchats'),
  //               hintStyle: TextStyle(color: Colors.grey),
  //               filled: true,
  //               fillColor: Colors.grey[100],
  //               enabledBorder: OutlineInputBorder(
  //                 borderRadius:
  //                     BorderRadius.all(Radius.circular(30.0)),
  //                 borderSide:
  //                     BorderSide(color: Colors.grey[100]!, width: 2),
  //               ),
  //               focusedBorder: OutlineInputBorder(
  //                 borderRadius:
  //                     BorderRadius.all(Radius.circular(30.0)),
  //                 borderSide: BorderSide(
  //                   color: Colors.grey[100]!,
  //                 ),
  //               ),
  //             ),
  //           )),
  //       Divider(),
  //                 _chats(_model.userData, _model.currentUser),
  //               ]));
  //     }),
  //   ));
  // }

  @override
  void dispose() {
    super.dispose();
  }
}
