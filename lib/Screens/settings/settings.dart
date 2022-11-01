import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Configs/Dbkeys.dart';
import '../../Configs/Dbpaths.dart';
import '../../Services/localization/language_constants.dart';
import '../../Utils/utils.dart';
import '../../main.dart';
import '../../widgets/ImagePicker/image_picker.dart';

class XDSettings extends StatefulWidget {
  final SharedPreferences prefs;
  final String? currentUserNo;

  XDSettings({
    required this.prefs,
    required this.currentUserNo,
  });

  @override
  State<XDSettings> createState() => _XDSettingsState();
}

class _XDSettingsState extends State<XDSettings> {
  String? password;
  String? phase;

  bool? isNameEdited;

  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;
  TextEditingController? controllerMobilenumber;

  String phone = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  File? avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();

    isNameEdited = false;
    password = "john123";
    phase = "phase";

    setState(() {});

    readLocal();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void readLocal() async {
    phone = widget.prefs.getString(Dbkeys.phone) ?? '';
    nickname = widget.prefs.getString(Dbkeys.nickname) ?? '';
    aboutMe = widget.prefs.getString(Dbkeys.aboutMe) ?? '';
    photoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);
    controllerMobilenumber = new TextEditingController(text: phone);
    // Force refresh input
    setState(() {});
  }

  Future getImage(File image) async {
    setState(() {
      avatarImageFile = image;
    });

    return uploadFile();
  }

  Future uploadFile() async {
    String fileName = phone;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot uploading = await reference.putFile(avatarImageFile!);

    return uploading.ref.getDownloadURL();
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });
    nickname = controllerNickname!.text.isEmpty ? nickname : controllerNickname!.text;
    aboutMe = controllerAboutMe!.text.isEmpty ? aboutMe : controllerAboutMe!.text;
    FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(phone).update({
      Dbkeys.nickname: nickname,
      Dbkeys.aboutMe: aboutMe,
      Dbkeys.searchKey: nickname.trim().substring(0, 1).toUpperCase(),
    }).then((data) {
      widget.prefs.setString(Dbkeys.nickname, nickname);
      widget.prefs.setString(Dbkeys.aboutMe, aboutMe);
      setState(() {
        isLoading = false;
      });
      Fiberchat.toast(getTranslated(this.context, 'saved'));
      Navigator.of(context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fiberchat.toast(err.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                                  'Settings',
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
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                              child: ListView(children: [
                                Container(
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 65,
                                            height: 65,
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: SizedBox(
                                                    height: 55.56,
                                                    width: 55.56,
                                                    child: (avatarImageFile == null)
                                                        ? (photoUrl != ''
                                                            ? Material(
                                                                child: CachedNetworkImage(
                                                                  placeholder: (context, url) =>
                                                                      Container(
                                                                    child: Padding(
                                                                        padding: EdgeInsets.all(50.0),
                                                                        child: CircularProgressIndicator(
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<
                                                                                      Color>(
                                                                                  Color(0xffD4AF36)),
                                                                        )),
                                                                    height: 55.56,
                                                                    width: 55.56,
                                                                  ),
                                                                  imageUrl: photoUrl,
                                                                  height: 55.56,
                                                                  width: 55.56,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(50.0)),
                                                                clipBehavior: Clip.hardEdge,
                                                              )
                                                            : Icon(
                                                                Icons.account_circle,
                                                                size: 55,
                                                                color: Colors.grey,
                                                              ))
                                                        : Material(
                                                            child: Image.file(
                                                              avatarImageFile!,
                                                              height: 55.56,
                                                              width: 55.56,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.all(Radius.circular(30.0)),
                                                            clipBehavior: Clip.hardEdge,
                                                          ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: SvgPicture.string(
                                                    // Exclusion 45
                                                    '<svg viewBox="0.0 0.0 67.28 67.28" ><path  d="M 33.63834762573242 67.27748107910156 C 29.0972728729248 67.27748107910156 24.69199752807617 66.38806915283203 20.5449047088623 64.63395690917969 C 16.53929328918457 62.93969345092773 12.94186019897461 60.51418685913086 9.852548599243164 57.42483520507812 C 6.763243198394775 54.33547592163086 4.337770462036133 50.73796844482422 2.64351224899292 46.73224258422852 C 0.8894066214561462 42.58503723144531 0 38.17961502075195 0 33.63834762573242 C 0 29.09726142883301 0.8894066214561462 24.69199562072754 2.64351224899292 20.54490280151367 C 4.337761878967285 16.5393009185791 6.763235092163086 12.9418773651123 9.852548599243164 9.852547645568848 C 12.9418773651123 6.763235092163086 16.5393009185791 4.337761878967285 20.5449047088623 2.64351224899292 C 24.69199752807617 0.8894066214561462 29.09726333618164 5.820766091346741e-11 33.63834762573242 5.820766091346741e-11 C 38.17961502075195 5.820766091346741e-11 42.58503723144531 0.8894066214561462 46.73224258422852 2.64351224899292 C 50.73796844482422 4.337770938873291 54.33547973632812 6.763243675231934 57.42483520507812 9.852547645568848 C 60.51418685913086 12.94186019897461 62.93969345092773 16.53929138183594 64.63395690917969 20.54490280151367 C 66.38806915283203 24.69199562072754 67.27748107910156 29.09727096557617 67.27748107910156 33.63834762573242 C 67.27748107910156 38.17961502075195 66.38806915283203 42.58503723144531 64.63395690917969 46.73224258422852 C 62.93967819213867 50.73796844482422 60.51418304443359 54.33547592163086 57.42483520507812 57.42483520507812 C 54.33547973632812 60.51417922973633 50.73796844482422 62.93967819213867 46.73224258422852 64.63395690917969 C 42.58503723144531 66.38806915283203 38.17961502075195 67.27748107910156 33.63834762573242 67.27748107910156 Z M 33.63834762573242 2.943296670913696 C 16.71304321289062 2.943296670913696 2.943296909332275 16.71304130554199 2.943296909332275 33.63834762573242 C 2.943296909332275 50.5640869140625 16.71304321289062 64.33418273925781 33.63834762573242 64.33418273925781 C 50.5640869140625 64.33418273925781 64.33418273925781 50.5640869140625 64.33418273925781 33.63834762573242 C 64.33418273925781 16.71304130554199 50.5640869140625 2.943296670913696 33.63834762573242 2.943296670913696 Z" fill="#d4af36" fill-opacity="0.3" stroke="none" stroke-width="1" stroke-opacity="0.3" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                                    width: 65,
                                                    height: 65,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          SizedBox(
                                            // width: 264,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 150,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                nickname,
                                                                style: TextStyle(
                                                                  fontFamily: 'Open Sans',
                                                                  fontSize: 17,
                                                                  color: Color(0xff3f3d56),
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                                softWrap: false,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          const Text(
                                                            'Profile phrase',
                                                            style: TextStyle(
                                                              overflow: TextOverflow.ellipsis,
                                                              fontFamily: 'Open Sans',
                                                              fontSize: 14,
                                                              color: Color(0x993f3d56),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => SingleImagePicker(
                                                      title: getTranslated(this.context, 'pickimage'),
                                                      callback: getImage,
                                                      profile: true))).then((url) {
                                            if (url != null) {
                                              photoUrl = url.toString();
                                              FirebaseFirestore.instance
                                                  .collection(DbPaths.collectionusers)
                                                  .doc(phone)
                                                  .update({Dbkeys.photoUrl: photoUrl}).then(
                                                      (data) async {
                                                await widget.prefs.setString(Dbkeys.photoUrl, photoUrl);
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                // Fiberchat.toast(
                                                //     "Profile Picture Changed!");
                                              }).catchError((err) {
                                                setState(() {
                                                  isLoading = false;
                                                });

                                                Fiberchat.toast(err.toString());
                                              });
                                            }
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 49.0,
                                          height: 49.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(60.0),
                                            color: Colors.white,
                                            border: Border.all(
                                              width: 1.0,
                                              color: const Color(0xFFE1E1E5),
                                            ),
                                          ),
                                          child: SvgPicture.string(
                                            // path0
                                            '<svg viewBox="13.0 15.0 23.32 19.8" ><path transform="translate(13.04, -10.87)" d="M 6.7340087890625 25.95914649963379 C 6.40166711807251 26.11007690429688 6.226136207580566 25.80633926391602 5.613219261169434 27.03199768066406 L 5.038195133209229 28.18199157714844 L 3.753423929214478 28.18199157714844 C 2.286712884902954 28.18199157714844 2.153216361999512 28.20046806335449 1.558428883552551 28.48594093322754 C 0.7914955615997314 28.85396003723145 0.1754887104034424 29.63471221923828 0.008647403679788113 30.45002746582031 C -0.06054916232824326 30.78819847106934 -0.06054916232824326 43.06438064575195 0.008647403679788113 43.40255737304688 C 0.2211339473724365 44.44120025634766 1.188661575317383 45.40872955322266 2.227309942245483 45.62121200561523 C 2.567113637924194 45.69076538085938 20.6695671081543 45.69076538085938 21.00937080383301 45.62121200561523 C 22.04801940917969 45.40872955322266 23.01554679870605 44.44120025634766 23.22803688049316 43.40255737304688 C 23.2972297668457 43.06438064575195 23.2972297668457 30.78819847106934 23.22803688049316 30.45002746582031 C 23.06119155883789 29.63471221923828 22.4451847076416 28.85396003723145 21.67825126647949 28.48594093322754 C 21.08346366882324 28.20046806335449 20.9499683380127 28.18199157714844 19.48325538635254 28.18199157714844 L 18.198486328125 28.18199157714844 L 17.63593673706055 27.05479049682617 C 16.97859764099121 25.73766326904297 16.81927871704102 26.1526927947998 16.49445724487305 25.99080467224121 L 16.25917625427246 25.87357139587402 L 11.58855438232422 25.87455940246582 C 7.156766891479492 25.87549781799316 6.90854549407959 25.87986755371094 6.7340087890625 25.95914649963379 M 12.587965965271 31.2101936340332 C 16.68881225585938 31.92536926269531 18.74774360656738 36.62886810302734 16.47235870361328 40.0839729309082 C 13.77777481079102 44.17566680908203 7.559525489807129 43.31657409667969 6.085061550140381 38.64897537231445 C 4.795919418334961 34.5681266784668 8.373795509338379 30.47532844543457 12.587965965271 31.2101936340332 M 10.83642387390137 32.59786224365234 C 7.750442981719971 33.16017913818359 6.239545345306396 36.69759750366211 7.953601837158203 39.34723281860352 C 9.449169158935547 41.65911483764648 12.84883689880371 41.98119735717773 14.76628684997559 39.99262619018555 C 16.41260719299316 38.28532791137695 16.41260719299316 35.56725311279297 14.76628684997559 33.85995483398438 C 13.80779647827148 32.86590576171875 12.1996603012085 32.34946441650391 10.83642387390137 32.59786224365234" fill="#173051" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                            width: 23.32,
                                            height: 19.8,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                dividerwidget('Account'),
                                InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context).viewInsets.bottom),
                                          child: SingleChildScrollView(
                                            controller: ModalScrollController.of(context),
                                            child: Container(
                                              height: 214.0,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(34.0),
                                                ),
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Container(
                                                      width: 94.0,
                                                      height: 8.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(17.0),
                                                        color: const Color(0xFFE1E1E5),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Account Name',
                                                      style: TextStyle(
                                                        fontFamily: 'Open Sans',
                                                        fontSize: 18.0,
                                                        color: Color(0xff3F3D56),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    Container(
                                                      height: 47.0,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xffefeff2),
                                                        borderRadius: BorderRadius.circular(24.0),
                                                        border: Border.all(
                                                            width: 1.0, color: const Color(0xffe1e1e5)),
                                                      ),
                                                      child: TextField(
                                                        onChanged: ((value) {
                                                          setState(() {
                                                            isNameEdited!
                                                                ? nickname = value
                                                                : nickname = nickname;
                                                          });
                                                        }),
                                                        textAlign: TextAlign.center,
                                                        decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                20, 15, 20, 15),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(24.0),
                                                            ),
                                                            labelStyle: TextStyle(
                                                              fontFamily: 'Open Sans',
                                                              fontSize: 19,
                                                              color: Colors.black.withOpacity(0.7),
                                                            ),
                                                            labelText: "Name:",
                                                            disabledBorder: InputBorder.none,
                                                            enabledBorder: InputBorder.none),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isNameEdited = true;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        height: 47.0,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(22.0),
                                                          color: const Color(0xFFD4AF36),
                                                        ),
                                                        child: Center(
                                                          child: Row(
                                                            children: const [
                                                              Padding(
                                                                padding: EdgeInsets.only(left: 20),
                                                                child: Icon(
                                                                  Icons.arrow_forward_ios,
                                                                  color: Color(0xFFD4AF36),
                                                                  size: 15,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                'Save',
                                                                style: TextStyle(
                                                                  fontFamily: 'Open Sans',
                                                                  fontSize: 19,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Padding(
                                                                padding: EdgeInsets.only(right: 20),
                                                                child: Icon(
                                                                  Icons.arrow_forward_ios,
                                                                  color: Colors.white,
                                                                  size: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: settingsWidget(title: 'Name:', detail: nickname)),
                                settingsWidget(title: 'Phase:', detail: phase),
                                settingsWidget(title: 'Phone:', detail: phone),
                                settingsWidget(title: 'Password', detail: password),
                                InkWell(
                                    onTap: () async {
                                      await logout(context);
                                    },
                                    child: settingsWidget3(title: 'Logout', svg: 'logout')),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    height: 47,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Color(0xffEFEFF2),
                                      border: Border.all(
                                        color: Color(0xffE1E1E5),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Delete account',
                                            style: TextStyle(
                                              fontFamily: 'Open Sans',
                                              fontSize: 19.0,
                                              color: Color(0xffFF0000),
                                            ),
                                          ),
                                          // Group: close (1)
                                          SvgPicture.string(
                                            // Group 4134
                                            '<svg viewBox="0.0 0.0 13.28 13.28" ><path transform="translate(0.0, -0.02)" d="M 8.101014137268066 6.654239177703857 L 13.06522941589355 1.689809083938599 C 13.20178031921387 1.553149580955505 13.27712726593018 1.370829224586487 13.27734375 1.176418542861938 C 13.27734375 0.9819000959396362 13.20199680328369 0.7993636131286621 13.06522941589355 0.6629198789596558 L 12.63020801544189 0.2280059903860092 C 12.49343967437744 0.09102264791727066 12.31112098693848 0.01600027829408646 12.11649322509766 0.01600027829408646 C 11.92218971252441 0.01600027829408646 11.73986911773682 0.09102264791727066 11.603102684021 0.2280059903860092 L 6.638886451721191 5.192113876342773 L 1.674456477165222 0.2280059903860092 C 1.537904977798462 0.09102264791727066 1.355476498603821 0.01600027829408646 1.160958051681519 0.01600027829408646 C 0.966655433177948 0.01600027829408646 0.7842269539833069 0.09102264791727066 0.6476753354072571 0.2280059903860092 L 0.2124375253915787 0.6629198789596558 C -0.07081251591444016 0.9461699724197388 -0.07081251591444016 1.406883120536804 0.2124375253915787 1.689809083938599 L 5.176760196685791 6.654239177703857 L 0.2124375253915787 11.61845588684082 C 0.07577800005674362 11.75533199310303 0.0005397233762778342 11.93765163421631 0.0005397233762778342 12.1320629119873 C 0.0005397233762778342 12.32647514343262 0.07577800005674362 12.5087947845459 0.2124375253915787 12.64556312561035 L 0.6475673913955688 13.08047771453857 C 0.7841188311576843 13.21735095977783 0.966655433177948 13.29248237609863 1.160849809646606 13.29248237609863 C 1.355368375778198 13.29248237609863 1.537797212600708 13.21735095977783 1.674348473548889 13.08047771453857 L 6.63878059387207 8.116259574890137 L 11.60299491882324 13.08047771453857 C 11.7397632598877 13.21735095977783 11.92208290100098 13.29248237609863 12.11638450622559 13.29248237609863 L 12.11660099029541 13.29248237609863 C 12.31101226806641 13.29248237609863 12.49333095550537 13.21735095977783 12.63010025024414 13.08047771453857 L 13.0651216506958 12.64556312561035 C 13.2016716003418 12.50890254974365 13.27702045440674 12.32647514343262 13.27702045440674 12.1320629119873 C 13.27702045440674 11.93765163421631 13.2016716003418 11.75533294677734 13.0651216506958 11.61856460571289 L 8.101014137268066 6.654239177703857 Z" fill="#3f3d56" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                            width: 13.28,
                                            height: 13.28,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                dividerwidget('Preferences'),
                                settingsWidget2(title: 'Notifications and sounds', svg: 'bell'),
                                settingsWidget2(title: 'Privacy and security', svg: 'lockk'),
                                settingsWidget2(title: 'Data and Storage', svg: 'info'),
                                settingsWidget2(title: 'Chat configurations', svg: 'qs'),
                                settingsWidget2(title: 'Change Idiom', svg: 'subject'),
                                dividerwidget('App'),
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'Version 1.0.0',
                                    style: TextStyle(
                                      fontFamily: 'Open Sans',
                                      fontSize: 19.0,
                                      color: Color(0xff3F3D56),
                                    ),
                                  ),
                                ),
                                settingsWidget3(title: 'Legal', svg: 'back'),
                                settingsWidget3(title: 'Privacy Policy', svg: 'back'),
                                settingsWidget3(title: 'Terms and Conditions', svg: 'back'),
                                const SizedBox(
                                  height: 50,
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
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

  Padding dividerwidget(String? title) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox(
        // width: 305.0,
        height: 26.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              alignment: Alignment(0.0, 0.04),
              child: Container(
                width: width * 0.25,
                height: 1.0,
                color: Color(0xff3F3D56).withOpacity(0.15),
              ),
            ),
            Text(
              title!,
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 19.0,
                color: Color(0xff3F3D56),
              ),
              textAlign: TextAlign.center,
            ),
            Align(
              alignment: Alignment(0.0, 0.04),
              child: Container(
                width: width * 0.25,
                height: 1.0,
                color: Color(0xff3F3D56).withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding settingsWidget({String? title, String? detail}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color(0xffEFEFF2),
          border: Border.all(
            color: Color(0xffE1E1E5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 19.0,
                      color: Color(0xff3F3D56),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    detail!,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 19.0,
                      color: Color(0xff3F3D56),
                    ),
                  ),
                ],
              ),
              SvgPicture.string(
                // Path 14653
                '<svg viewBox="274.0 151.28 16.03 16.03" ><path transform="translate(165.81, 151.02)" d="M 122.8602752685547 0.9810683727264404 C 121.8998565673828 0.02064364030957222 120.3427734375 0.02064364030957222 119.3823394775391 0.9810683727264404 L 109.6325073242188 10.73090362548828 C 109.5656890869141 10.79772090911865 109.5174407958984 10.88055038452148 109.4922485351562 10.97148895263672 L 108.2101287841797 15.60027599334717 C 108.1573791503906 15.7900562286377 108.2109832763672 15.99328422546387 108.3501739501953 16.13268280029297 C 108.4895629882812 16.2718677520752 108.6927947998047 16.3254508972168 108.882568359375 16.2729377746582 L 113.5113677978516 14.99059200286865 C 113.602294921875 14.9654016494751 113.6851348876953 14.91715812683105 113.751953125 14.85033893585205 L 123.5015716552734 5.10028600692749 C 124.4604949951172 4.139222145080566 124.4604949951172 2.583410978317261 123.5015716552734 1.622346758842468 L 122.8602752685547 0.9810683727264404 Z M 110.8232574462891 11.08612632751465 L 118.8027648925781 3.106395483016968 L 121.376220703125 5.679837703704834 L 113.3964691162109 13.65956974029541 L 110.8232574462891 11.08612632751465 Z M 110.3091888427734 12.11763858795166 L 112.3651885986328 14.1738338470459 L 109.5212554931641 14.96177196502686 L 110.3091888427734 12.11763858795166 Z M 122.7287750244141 4.327488422393799 L 122.1492004394531 4.907075881958008 L 119.5755310058594 2.333414077758789 L 120.1553344726562 1.75382673740387 C 120.6888122558594 1.220351934432983 121.5538177490234 1.220351934432983 122.0872802734375 1.75382673740387 L 122.7287750244141 2.395108461380005 C 123.2613983154297 2.929224014282227 123.2613983154297 3.793583154678345 122.7287750244141 4.327488422393799 Z M 122.7287750244141 4.327488422393799" fill="#3f3d56" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                width: 16.03,
                height: 16.03,
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding settingsWidget2({String? title, String? svg}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color(0xffEFEFF2),
          border: Border.all(
            color: Color(0xffE1E1E5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 19.0,
                  color: Color(0xff3F3D56),
                ),
              ),
              SvgPicture.asset('assets/svgs/$svg.svg', color: Color(0xff173051).withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  Padding settingsWidget3({String? title, String? svg}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color(0xffEFEFF2),
          border: Border.all(
            color: Color(0xffE1E1E5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 19.0,
                  color: Color(0xff3F3D56),
                ),
              ),
              SvgPicture.asset(
                'assets/svgs/$svg.svg',
              )
              // color: Color(0xff173051).withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
