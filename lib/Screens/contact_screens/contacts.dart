import 'package:contacts_service/contacts_service.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/chat_screen/pre_chat.dart';
import 'package:fiberchat/Screens/contact_screens/AddunsavedContact.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contacts extends StatefulWidget {
  const Contacts({
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
  });
  final String? currentUserNo;
  final DataModel? model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  @override
  _ContactsState createState() => new _ContactsState();
}

class _ContactsState extends State<Contacts>
    with AutomaticKeepAliveClientMixin {
  Map<String?, String?>? contacts;
  Map<String?, String?>? _filtered = new Map<String, String>();

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();

  late String _query;

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  _ContactsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _query = "";
          this._filtered = this.contacts;
        });
      } else {
        setState(() {
          _query = _filter.text;
          this._filtered =
              Map.fromEntries(this.contacts!.entries.where((MapEntry contact) {
            return contact.value
                .toLowerCase()
                .trim()
                .contains(new RegExp(r'' + _query.toLowerCase().trim() + ''));
          }));
        });
      }
    });
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }

  @override
  initState() {
    super.initState();
    getContacts();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _appBarTitle = new Text(
        getTranslated(context, 'searchcontact'),
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatWhite
              : fiberchatBlack,
        ),
      );
      _searchPressed();
    });
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo) {
    Map<String, dynamic> _currentUser = widget.model!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  Future<Map<String?, String?>> getContacts({bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        new Completer<Map<String?, String?>>();

    LocalStorage storage = LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key));
      if (mounted) {
        setState(() {
          this.contacts = this._filtered = c;
        });
      }
    });

    Fiberchat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(new RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              contacts.where((c) => c.phones!.isNotEmpty).forEach((Contact p) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  numbers.forEach((number) {
                    _cachedContacts[number] = p.displayName;
                    setState(() {});
                  });
                  setState(() {});
                }
              });

              // await storage.setItem(Dbkeys.cachedContacts, _cachedContacts);
              completer.complete(_cachedContacts);
            });
          }
          // }
        });
      } else {
        Fiberchat.showRationale(getTranslated(context, 'perm_contact'));
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      }
    }).catchError((onError) {
      Fiberchat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  Icon _searchIcon = new Icon(Icons.search, color: fiberchatWhite);
  Widget _appBarTitle = Text('');

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close, color: fiberchatWhite);
        this._appBarTitle = new TextField(
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          style: TextStyle(
            color: fiberchatWhite,
            fontSize: 18.5,
            fontWeight: FontWeight.w600,
          ),
          controller: _filter,
          decoration: new InputDecoration(
              labelStyle: TextStyle(color: fiberchatWhite),
              hintText: getTranslated(context, 'search'),
              hintStyle: TextStyle(
                fontSize: 18.5,
                color: fiberchatWhite,
              )),
        );
      } else {
        this._searchIcon = new Icon(Icons.search, color: fiberchatWhite);
        this._appBarTitle = new Text(
          getTranslated(context, 'searchcontact'),
          style: TextStyle(fontSize: 18.5, color: fiberchatWhite),
        );

        _filter.clear();
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
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
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                        Expanded(child: _appBarTitle),
                                        IconButton(
                                          icon: Icon(Icons.add_call,
                                              color: fiberchatWhite),
                                          onPressed: () {
                                            Navigator.pushReplacement(context,
                                                new MaterialPageRoute(
                                                    builder: (context) {
                                              return new AddunsavedNumber(
                                                  prefs: widget.prefs,
                                                  model: widget.model,
                                                  currentUserNo:
                                                      widget.currentUserNo);
                                            }));
                                          },
                                        ),
                                        IconButton(
                                          icon: _searchIcon,
                                          onPressed: _searchPressed,
                                        )
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
                                        child: contacts == null
                                            ? loading()
                                            : RefreshIndicator(
                                                onRefresh: () {
                                                  return getContacts(
                                                      refresh: true);
                                                },
                                                child: _filtered!.isEmpty
                                                    ? ListView(children: [
                                                        Padding(
                                                            padding: EdgeInsets.only(
                                                                top: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    2.5),
                                                            child: Center(
                                                              child: Text(
                                                                  getTranslated(
                                                                      context,
                                                                      'nosearchresult'),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        fiberchatBlack,
                                                                  )),
                                                            ))
                                                      ])
                                                    : ListView.builder(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        itemCount:
                                                            _filtered!.length,
                                                        itemBuilder:
                                                            (context, idx) {
                                                          MapEntry user =
                                                              _filtered!.entries
                                                                  .elementAt(
                                                                      idx);
                                                          String phone =
                                                              user.key;
                                                          return ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                                    backgroundColor:
                                                                        multiboxMainColor,
                                                                    radius:
                                                                        22.5,
                                                                    child: Text(
                                                                      Fiberchat
                                                                          .getInitials(
                                                                              user.value),
                                                                      style: TextStyle(
                                                                          color:
                                                                              fiberchatWhite),
                                                                    )),
                                                            title: Text(
                                                                user.value,
                                                                style: TextStyle(
                                                                    color:
                                                                        fiberchatBlack)),
                                                            subtitle: Text(
                                                                phone,
                                                                style: TextStyle(
                                                                    color:
                                                                        fiberchatGrey)),
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            onTap: () {
                                                              hidekeyboard(
                                                                  context);
                                                              dynamic wUser =
                                                                  model.userData[
                                                                      phone];
                                                              if (wUser !=
                                                                      null &&
                                                                  wUser[Dbkeys
                                                                          .chatStatus] !=
                                                                      null) {
                                                                if (model.currentUser![Dbkeys
                                                                            .locked] !=
                                                                        null &&
                                                                    model
                                                                        .currentUser![Dbkeys
                                                                            .locked]
                                                                        .contains(
                                                                            phone)) {
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)),
                                                                      (Route r) => r.isFirst);
                                                                } else {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)));
                                                                }
                                                              } else {
                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return new PreChat(
                                                                      prefs: widget
                                                                          .prefs,
                                                                      model: widget
                                                                          .model,
                                                                      name: user
                                                                          .value,
                                                                      phone:
                                                                          phone,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo);
                                                                }));
                                                              }
                                                            },
                                                          );
                                                        },
                                                      )))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }))));
  }
}
