import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/status/components/formatStatusTime.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/call_utilities.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/permissions.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final DocumentSnapshot<Map<String, dynamic>>? firestoreUserDoc;
  ProfileView(this.user, this.currentUserNo, this.model, this.prefs, {this.firestoreUserDoc});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        currentuseruid: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: widget.user[Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.user[Dbkeys.phone],
        toFullname: widget.user[Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);

    var w = MediaQuery.of(context).size.width;
    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
      backgroundColor: DESIGN_TYPE == Themetype.whatsapp ? Color(0xfff2f2f2) : fiberchatWhite,
      body: ListView(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.user[Dbkeys.photoUrl] ?? '',
                imageBuilder: (context, imageProvider) => Container(
                  width: w,
                  height: w / 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Container(
                  width: w,
                  height: w / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(Icons.person, color: fiberchatGrey.withOpacity(0.5), size: 95),
                ),
                errorWidget: (context, url, error) => Container(
                  width: w,
                  height: w / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(Icons.person, color: fiberchatGrey.withOpacity(0.5), size: 95),
                ),
              ),
              Container(
                width: w,
                height: w / 1.2,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.29),
                    Colors.black.withOpacity(0.48),
                  ],
                )),
              ),
              Positioned(
                  bottom: 19,
                  left: 19,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Text(
                      widget.user[Dbkeys.nickname],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              Positioned(
                top: 11,
                left: 7,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.string(
                    '<svg viewBox="26.0 72.0 35.34 35.34" ><path transform="translate(-6634.0, 21996.0)" d="M 6677.66650390625 -21888.66015625 C 6672.94921875 -21888.66015625 6668.51318359375 -21890.5 6665.17626953125 -21893.837890625 C 6661.83740234375 -21897.171875 6659.99853515625 -21901.609375 6659.99853515625 -21906.33203125 C 6659.99853515625 -21911.052734375 6661.83740234375 -21915.48828125 6665.17626953125 -21918.822265625 C 6668.50927734375 -21922.16015625 6672.9453125 -21924 6677.66650390625 -21924 C 6682.39111328125 -21924 6686.8291015625 -21922.16015625 6690.16162109375 -21918.822265625 C 6693.50048828125 -21915.48828125 6695.33935546875 -21911.052734375 6695.33935546875 -21906.33203125 C 6695.33935546875 -21901.609375 6693.50048828125 -21897.171875 6690.16162109375 -21893.837890625 C 6686.8251953125 -21890.5 6682.38720703125 -21888.66015625 6677.66650390625 -21888.66015625 Z M 6677.15625 -21914 C 6676.94580078125 -21914 6676.74609375 -21913.921875 6676.59326171875 -21913.77734375 L 6669.47900390625 -21906.998046875 C 6669.17041015625 -21906.689453125 6669.00048828125 -21906.279296875 6669.00048828125 -21905.84375 C 6669.00048828125 -21905.40625 6669.17431640625 -21904.9921875 6669.490234375 -21904.67578125 L 6676.59326171875 -21897.9140625 C 6676.7451171875 -21897.767578125 6676.93896484375 -21897.689453125 6677.15478515625 -21897.689453125 C 6677.380859375 -21897.689453125 6677.59765625 -21897.78125 6677.7490234375 -21897.94140625 C 6677.8984375 -21898.099609375 6677.97802734375 -21898.306640625 6677.97265625 -21898.5234375 C 6677.9677734375 -21898.740234375 6677.8779296875 -21898.94140625 6677.72119140625 -21899.091796875 L 6671.4599609375 -21905.029296875 L 6685.0390625 -21905.029296875 C 6685.48828125 -21905.029296875 6685.853515625 -21905.39453125 6685.853515625 -21905.84375 C 6685.853515625 -21906.294921875 6685.48828125 -21906.662109375 6685.0390625 -21906.662109375 L 6671.4873046875 -21906.662109375 L 6677.7158203125 -21912.59375 C 6677.87353515625 -21912.7421875 6677.9638671875 -21912.943359375 6677.97119140625 -21913.16015625 C 6677.978515625 -21913.37890625 6677.8994140625 -21913.58984375 6677.7490234375 -21913.75 C 6677.591796875 -21913.912109375 6677.38134765625 -21914 6677.15625 -21914 Z" fill="#d4af36" stroke="none" stroke-width="0.1333329975605011" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                    width: 35.34,
                    height: 35.34,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, 'about'),
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: multiboxMainColor, fontSize: 16),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(
                  height: 7,
                ),
                Text(
                  widget.user[Dbkeys.aboutMe] == null || widget.user[Dbkeys.aboutMe] == ''
                      ? 'Hey there! I am using $Appname'
                      : widget.user[Dbkeys.aboutMe],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.normal, color: fiberchatBlack, fontSize: 15.9),
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  getJoinTime(widget.user[Dbkeys.joinedOn], context),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.normal, color: fiberchatGrey, fontSize: 13.3),
                ),
                SizedBox(
                  height: 7,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, 'enter_mobilenumber'),
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: multiboxMainColor, fontSize: 16),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(
                  height: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.user[Dbkeys.phone],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: fiberchatBlack, fontSize: 15.3),
                    ),
                    Container(
                      child: Row(
                        children: [
                          observer.isCallFeatureTotallyHide == true
                              ? SizedBox()
                              : IconButton(
                                  onPressed: observer.iscallsallowed == false
                                      ? () {
                                          Fiberchat.showRationale(
                                              getTranslated(context, 'callnotallowed'));
                                        }
                                      : () async {
                                          await Permissions.cameraAndMicrophonePermissionsGranted()
                                              .then((isgranted) {
                                            if (isgranted == true) {
                                              call(context, false);
                                            } else {
                                              Fiberchat.showRationale(getTranslated(context, 'pmc'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) => OpenSettings()));
                                            }
                                          }).catchError((onError) {
                                            Fiberchat.showRationale(getTranslated(context, 'pmc'));
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) => OpenSettings()));
                                          });
                                        },
                                  icon: Icon(
                                    Icons.phone,
                                    color: multiboxMainColor,
                                  )),
                          observer.isCallFeatureTotallyHide == true
                              ? SizedBox()
                              : IconButton(
                                  onPressed: observer.iscallsallowed == false
                                      ? () {
                                          Fiberchat.showRationale(
                                              getTranslated(context, 'callnotallowed'));
                                        }
                                      : () async {
                                          await Permissions.cameraAndMicrophonePermissionsGranted()
                                              .then((isgranted) {
                                            if (isgranted == true) {
                                              call(context, true);
                                            } else {
                                              Fiberchat.showRationale(getTranslated(context, 'pmc'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) => OpenSettings()));
                                            }
                                          }).catchError((onError) {
                                            Fiberchat.showRationale(getTranslated(context, 'pmc'));
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) => OpenSettings()));
                                          });
                                        },
                                  icon: Icon(
                                    Icons.videocam_rounded,
                                    size: 26,
                                    color: multiboxMainColor,
                                  )),
                          IconButton(
                              onPressed: () {
                                if (widget.firestoreUserDoc != null) {
                                  widget.model!.addUser(widget.firestoreUserDoc!);
                                }

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new ChatScreen(
                                            isSharingIntentForwarded: false,
                                            prefs: widget.prefs,
                                            model: widget.model!,
                                            currentUserNo: widget.currentUserNo,
                                            peerNo: widget.user[Dbkeys.phone],
                                            unread: 0)),
                                    (Route r) => r.isFirst);
                              },
                              icon: Icon(
                                Icons.message,
                                color: multiboxMainColor,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(bottom: 18, top: 8),
            color: Colors.white,
            // height: 30,
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  getTranslated(context, 'encryption'),
                  style: TextStyle(fontWeight: FontWeight.w600, height: 2),
                ),
              ),
              dense: false,
              subtitle: Text(
                getTranslated(context, 'encryptionshort'),
                style: TextStyle(color: fiberchatGrey, height: 1.3, fontSize: 15),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Icon(
                  Icons.lock,
                  color: multiboxMainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    )));
  }
}
