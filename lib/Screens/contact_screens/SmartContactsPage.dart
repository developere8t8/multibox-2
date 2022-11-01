import 'package:adobe_xd/pinned.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/contact_screens/contacts.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/chat_screen/pre_chat.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/componentss/xd_component5281.dart';

class SmartContactsPage extends StatefulWidget {
  final String currentUserNo;
  final DataModel model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  final Function onTapCreateGroup;
  const SmartContactsPage({
    Key? key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.onTapCreateGroup,
  }) : super(key: key);

  @override
  _SmartContactsPageState createState() => _SmartContactsPageState();
}

class _SmartContactsPageState extends State<SmartContactsPage> {
  Map<String?, String?>? contacts;
  Map<String?, String?>? _filtered = new Map<String, String>();

  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setInitial(context);
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setInitial(BuildContext context) {
    final AvailableContactsProvider contactsProvider =
        Provider.of<AvailableContactsProvider>(context, listen: false);
    contactsProvider.setIsLoading(true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setStateIfMounted(() {
        _filtered = contactsProvider.filtered;
      });

      contactsProvider.setIsLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return PickupLayout(
      scaffold: Fiberchat.getNTPWrappedWidget(
        ScopedModel<DataModel>(
          model: widget.model,
          child: ScopedModelDescendant<DataModel>(
            builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                builder: (context, availableContacts, _child) {
                  // _filtered = availableContacts.filtered;
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
                                        padding: const EdgeInsets.fromLTRB(
                                            30, 0, 30, 0),
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
                                              'Contacts',
                                              style: TextStyle(
                                                fontFamily: 'Open Sans',
                                                fontSize: 18.0,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return Contacts(
                                                        prefs: widget.prefs,
                                                        model: widget.model,
                                                        currentUserNo: widget
                                                            .currentUserNo,
                                                        biometricEnabled: widget
                                                            .biometricEnabled,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: SvgPicture.string(
                                                '<svg viewBox="0.0 0.0 35.0 35.0" ><path transform="translate(9901.0, -708.0)" d="M -9883.5 742.99951171875 C -9888.1748046875 742.99951171875 -9892.5703125 741.1792602539062 -9895.8759765625 737.8739624023438 C -9899.1806640625 734.5684204101562 -9901.0009765625 730.1735229492188 -9901.0009765625 725.4989013671875 C -9901.0009765625 720.8253173828125 -9899.1806640625 716.4312133789062 -9895.8759765625 713.1260375976562 C -9892.5693359375 709.8209838867188 -9888.1748046875 708.0007934570312 -9883.5 708.0007934570312 C -9878.8251953125 708.0007934570312 -9874.4306640625 709.8209838867188 -9871.125 713.1260375976562 C -9867.8203125 716.43115234375 -9866 720.8252563476562 -9866 725.4989013671875 C -9866 730.173583984375 -9867.8203125 734.5684814453125 -9871.125 737.8739624023438 C -9874.4296875 741.1792602539062 -9878.8251953125 742.99951171875 -9883.5 742.99951171875 Z M -9879.7802734375 729.9094848632812 L -9879.779296875 729.9100952148438 L -9875.7919921875 733.9000854492188 C -9875.7001953125 733.99169921875 -9875.5751953125 734.0442504882812 -9875.447265625 734.0442504882812 C -9875.31640625 734.0442504882812 -9875.1943359375 733.9930419921875 -9875.1015625 733.9000854492188 C -9874.9140625 733.7096557617188 -9874.9140625 733.3997802734375 -9875.1015625 733.2094116210938 L -9879.08984375 729.2186889648438 C -9876.6025390625 726.357177734375 -9876.826171875 722.089111328125 -9879.5986328125 719.5005493164062 C -9880.9013671875 718.287841796875 -9882.59765625 717.6199951171875 -9884.375 717.6199951171875 C -9886.2470703125 717.6199951171875 -9888.005859375 718.3487548828125 -9889.3291015625 719.6719970703125 C -9892.013671875 722.35302734375 -9892.087890625 726.6260986328125 -9889.4990234375 729.4000854492188 C -9888.1787109375 730.81640625 -9886.3115234375 731.6287231445312 -9884.3740234375 731.6287231445312 C -9882.6865234375 731.6287231445312 -9881.0546875 731.0183715820312 -9879.78125 729.9100952148438 L -9879.7802734375 729.9094848632812 Z M -9884.3720703125 730.6474609375 C -9887.685546875 730.6449584960938 -9890.3857421875 727.9451904296875 -9890.390625 724.6292114257812 C -9890.390625 721.3120727539062 -9887.6904296875 718.6134643554688 -9884.3720703125 718.6134643554688 C -9881.0537109375 718.6134643554688 -9878.3544921875 721.3120727539062 -9878.3544921875 724.6292114257812 C -9878.3544921875 727.9476928710938 -9881.0537109375 730.6474609375 -9884.3720703125 730.6474609375 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                                width: 35.0,
                                                height: 35.0,
                                              ),
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: availableContacts
                                                    .searchingcontactsindatabase ==
                                                true
                                            ? loading()
                                            : RefreshIndicator(
                                                onRefresh: () {
                                                  return availableContacts
                                                      .fetchContacts(
                                                          context,
                                                          model,
                                                          widget.currentUserNo,
                                                          widget.prefs);
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
                                                    : ListView(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 15,
                                                                top: 0),
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        children: [
                                                          availableContacts
                                                                      .joinedUserPhoneStringAsInServer
                                                                      .length ==
                                                                  0
                                                              ? SizedBox(
                                                                  height: 0,
                                                                )
                                                              : ListView
                                                                  .builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              00),
                                                                  itemCount:
                                                                      availableContacts
                                                                          .joinedUserPhoneStringAsInServer
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          idx) {
                                                                    JoinedUserModel
                                                                        user =
                                                                        availableContacts
                                                                            .joinedUserPhoneStringAsInServer
                                                                            .elementAt(idx);
                                                                    String
                                                                        phone =
                                                                        user.phone;
                                                                    String
                                                                        name =
                                                                        user.name ??
                                                                            user.phone;
                                                                    return Column(
                                                                      children: [
                                                                        ListTile(
                                                                          tileColor:
                                                                              Colors.white,
                                                                          leading:
                                                                              FutureBuilder(
                                                                            future:
                                                                                availableContacts.getUserDoc(phone),
                                                                            builder:
                                                                                (BuildContext context, AsyncSnapshot snapshot) {
                                                                              if (snapshot.hasData && snapshot.data.exists) {
                                                                                return customCircleAvatar(url: snapshot.data[Dbkeys.photoUrl], radius: 30);
                                                                              }
                                                                              return CircleAvatar(
                                                                                  backgroundColor: multiboxMainColor,
                                                                                  radius: 30,
                                                                                  child: Text(
                                                                                    Fiberchat.getInitials(name),
                                                                                    style: TextStyle(color: fiberchatWhite),
                                                                                  ));
                                                                            },
                                                                          ),
                                                                          title:
                                                                              Text(
                                                                            name,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 17.0,
                                                                              color: Color(0xff3F3D56),
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            phone,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14.0,
                                                                              color: Color(0xff3F3D56).withOpacity(0.6),
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                          contentPadding:
                                                                              EdgeInsets.all(0),
                                                                          onTap:
                                                                              () {
                                                                            hidekeyboard(context);
                                                                            dynamic
                                                                                wUser =
                                                                                model.userData[phone];
                                                                            if (wUser != null &&
                                                                                wUser[Dbkeys.chatStatus] != null) {
                                                                              if (model.currentUser![Dbkeys.locked] != null && model.currentUser![Dbkeys.locked].contains(user.name)) {
                                                                                Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => new ChatScreen(isSharingIntentForwarded: false, prefs: widget.prefs, model: model, currentUserNo: widget.currentUserNo, peerNo: phone, unread: 0)), (Route r) => r.isFirst);
                                                                              } else {
                                                                                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new ChatScreen(isSharingIntentForwarded: false, prefs: widget.prefs, model: model, currentUserNo: widget.currentUserNo, peerNo: phone, unread: 0)));
                                                                              }
                                                                            } else {
                                                                              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) {
                                                                                return new PreChat(prefs: widget.prefs, model: widget.model, name: name, phone: phone, currentUserNo: widget.currentUserNo);
                                                                              }));
                                                                            }
                                                                          },
                                                                          onLongPress:
                                                                              () async {},
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              1.0,
                                                                          color:
                                                                              const Color(0xFFE1E1E5),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    18,
                                                                    24,
                                                                    18,
                                                                    18),
                                                            child: Text(
                                                              getTranslated(
                                                                  context,
                                                                  'invite'),
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            itemCount:
                                                                _filtered!
                                                                    .length,
                                                            itemBuilder:
                                                                (context, idx) {
                                                              MapEntry user =
                                                                  _filtered!
                                                                      .entries
                                                                      .elementAt(
                                                                          idx);
                                                              String phone =
                                                                  user.key;
                                                              return availableContacts
                                                                          .joinedcontactsInSharePref
                                                                          .indexWhere((element) =>
                                                                              element.phone ==
                                                                              phone) >=
                                                                      0
                                                                  ? Container(
                                                                      width: 0,
                                                                    )
                                                                  : Column(
                                                                      children: [
                                                                        ListTile(
                                                                          tileColor:
                                                                              Colors.white,
                                                                          leading:
                                                                              CircleAvatar(
                                                                            backgroundColor:
                                                                                multiboxMainColor,
                                                                            radius:
                                                                                30,
                                                                            child:
                                                                                Text(
                                                                              Fiberchat.getInitials(user.value),
                                                                              style: TextStyle(color: fiberchatWhite),
                                                                            ),
                                                                          ),
                                                                          title:
                                                                              Text(
                                                                            user.value,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 17.0,
                                                                              color: Color(0xff3F3D56),
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                          subtitle: Text(
                                                                              phone,
                                                                              style: TextStyle(
                                                                                fontSize: 14.0,
                                                                                color: Color(0xff3F3D56).withOpacity(0.6),
                                                                                fontWeight: FontWeight.w600,
                                                                              )),
                                                                          contentPadding:
                                                                              EdgeInsets.all(0),
                                                                          onTap:
                                                                              () {
                                                                            hidekeyboard(context);
                                                                            Fiberchat.invite(context);
                                                                          },
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              1.0,
                                                                          color:
                                                                              const Color(0xFFE1E1E5),
                                                                        ),
                                                                        // Positioned(
                                                                        //   right:
                                                                        //       19,
                                                                        //   bottom:
                                                                        //       19,
                                                                        //   child:
                                                                        //       InkWell(
                                                                        //     onTap:
                                                                        //         () {
                                                                        //       hidekeyboard(context);
                                                                        //       Fiberchat.invite(context);
                                                                        //     },
                                                                        //     child:
                                                                        //         Icon(
                                                                        //       Icons.person_add_alt,
                                                                        //       color: multiboxMainColor,
                                                                        //     ),
                                                                        //   ),
                                                                        // )
                                                                      ],
                                                                    );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Pinned.fromPins(
                              Pin(size: 56.0, end: 17.0),
                              Pin(size: 56.0, end: 24.0),
                              child: InkWell(
                                  onTap: () async {
                                    try {
                                      await ContactsService.openContactForm();
                                    } on FormOperationException catch (e) {
                                      switch (e.errorCode) {
                                        case FormOperationErrorCode
                                            .FORM_OPERATION_CANCELED:
                                          break;
                                        case FormOperationErrorCode
                                            .FORM_COULD_NOT_BE_OPEN:
                                          break;
                                        case FormOperationErrorCode
                                            .FORM_OPERATION_UNKNOWN_ERROR:
                                          break;
                                        default:
                                          break;
                                      }
                                    }
                                  },
                                  child: XDComponent5281()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child:
                // Column(
                //     mainAxisSize: MainAxisSize.min,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [Icon(Icons.search, size: 30)])
                CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }
}
