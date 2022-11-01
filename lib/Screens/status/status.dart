import 'dart:io';
import 'package:adobe_xd/pinned.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/status/StatusView.dart';
import 'package:fiberchat/Screens/status/components/ImagePicker/image_picker.dart';
import 'package:fiberchat/Screens/status/components/TextStatus/textStatus.dart';
import 'package:fiberchat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:fiberchat/Screens/status/components/circleBorder.dart';
import 'package:fiberchat/Screens/status/components/formatStatusTime.dart';
import 'package:fiberchat/Screens/status/components/showViewers.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/Providers/StatusProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat/Configs/Enum.dart';

import '../../widgets/componentss/xd_component5271.dart';

class Status extends StatefulWidget {
  const Status({
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.phoneNumberVariants,
    required this.currentUserFullname,
    required this.currentUserPhotourl,
  });
  final String? currentUserNo;
  final String? currentUserFullname;
  final String? currentUserPhotourl;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final List phoneNumberVariants;

  @override
  _StatusState createState() => new _StatusState();
}

class _StatusState extends State<Status> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

  late Stream myStatusUpdates;

  @override
  initState() {
    super.initState();
    myStatusUpdates = FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .doc(widget.currentUserNo)
        .snapshots();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  uploadFile(
      {required File file,
      String? caption,
      double? duration,
      required String type,
      required String filename}) async {
    final observer = Provider.of<Observer>(context, listen: false);
    final StatusProvider statusProvider =
        Provider.of<StatusProvider>(context, listen: false);
    statusProvider.setIsLoading(true);
    int uploadTimestamp = DateTime.now().millisecondsSinceEpoch;

    Reference reference = FirebaseStorage.instance
        .ref()
        .child('+00_STATUS_MEDIA/${widget.currentUserNo}/$filename');
    await reference.putFile(file).then((uploadTask) async {
      String url = await uploadTask.ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionnstatus)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.statusITEMSLIST: FieldValue.arrayUnion([
          type == Dbkeys.statustypeVIDEO
              ? {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                  Dbkeys.statusItemDURATION: duration,
                }
              : {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                }
        ]),
        Dbkeys.statusPUBLISHERPHONE: widget.currentUserNo,
        Dbkeys.statusPUBLISHERPHONEVARIANTS: widget.phoneNumberVariants,
        Dbkeys.statusVIEWERLIST: [],
        Dbkeys.statusVIEWERLISTWITHTIME: [],
        Dbkeys.statusPUBLISHEDON: DateTime.now(),
        // uploadTimestamp,
        Dbkeys.statusEXPIRININGON: DateTime.now()
            .add(Duration(hours: observer.statusDeleteAfterInHours)),
        // .millisecondsSinceEpoch,
      }, SetOptions(merge: true)).then((value) {
        statusProvider.setIsLoading(false);
      });
    }).onError((error, stackTrace) {
      statusProvider.setIsLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final observer = Provider.of<Observer>(context, listen: true);
    final contactsProvider =
        Provider.of<AvailableContactsProvider>(context, listen: true);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: widget.model!,
      child: ScopedModelDescendant<DataModel>(builder: (context, child, model) {
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
                                    'Status',
                                    style: TextStyle(
                                      fontFamily: 'Open Sans',
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(),
                                  SvgPicture.string(
                                    '<svg viewBox="0.0 0.0 35.0 35.0" ><path transform="translate(9901.0, -708.0)" d="M -9883.5 742.99951171875 C -9888.1748046875 742.99951171875 -9892.5703125 741.1792602539062 -9895.8759765625 737.8739624023438 C -9899.1806640625 734.5684204101562 -9901.0009765625 730.1735229492188 -9901.0009765625 725.4989013671875 C -9901.0009765625 720.8253173828125 -9899.1806640625 716.4312133789062 -9895.8759765625 713.1260375976562 C -9892.5693359375 709.8209838867188 -9888.1748046875 708.0007934570312 -9883.5 708.0007934570312 C -9878.8251953125 708.0007934570312 -9874.4306640625 709.8209838867188 -9871.125 713.1260375976562 C -9867.8203125 716.43115234375 -9866 720.8252563476562 -9866 725.4989013671875 C -9866 730.173583984375 -9867.8203125 734.5684814453125 -9871.125 737.8739624023438 C -9874.4296875 741.1792602539062 -9878.8251953125 742.99951171875 -9883.5 742.99951171875 Z M -9879.7802734375 729.9094848632812 L -9879.779296875 729.9100952148438 L -9875.7919921875 733.9000854492188 C -9875.7001953125 733.99169921875 -9875.5751953125 734.0442504882812 -9875.447265625 734.0442504882812 C -9875.31640625 734.0442504882812 -9875.1943359375 733.9930419921875 -9875.1015625 733.9000854492188 C -9874.9140625 733.7096557617188 -9874.9140625 733.3997802734375 -9875.1015625 733.2094116210938 L -9879.08984375 729.2186889648438 C -9876.6025390625 726.357177734375 -9876.826171875 722.089111328125 -9879.5986328125 719.5005493164062 C -9880.9013671875 718.287841796875 -9882.59765625 717.6199951171875 -9884.375 717.6199951171875 C -9886.2470703125 717.6199951171875 -9888.005859375 718.3487548828125 -9889.3291015625 719.6719970703125 C -9892.013671875 722.35302734375 -9892.087890625 726.6260986328125 -9889.4990234375 729.4000854492188 C -9888.1787109375 730.81640625 -9886.3115234375 731.6287231445312 -9884.3740234375 731.6287231445312 C -9882.6865234375 731.6287231445312 -9881.0546875 731.0183715820312 -9879.78125 729.9100952148438 L -9879.7802734375 729.9094848632812 Z M -9884.3720703125 730.6474609375 C -9887.685546875 730.6449584960938 -9890.3857421875 727.9451904296875 -9890.390625 724.6292114257812 C -9890.390625 721.3120727539062 -9887.6904296875 718.6134643554688 -9884.3720703125 718.6134643554688 C -9881.0537109375 718.6134643554688 -9878.3544921875 721.3120727539062 -9878.3544921875 724.6292114257812 C -9878.3544921875 727.9476928710938 -9881.0537109375 730.6474609375 -9884.3720703125 730.6474609375 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
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
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(34.0),
                                topRight: Radius.circular(34.0),
                              ),
                            ),
                            child: RefreshIndicator(
                              onRefresh: () {
                                final statusProvider =
                                    Provider.of<StatusProvider>(context,
                                        listen: false);
                                final contactsProvider =
                                    Provider.of<AvailableContactsProvider>(
                                        context,
                                        listen: false);
                                statusProvider.searchContactStatus(
                                    widget.currentUserNo!,
                                    contactsProvider
                                        .joinedUserPhoneStringAsInServer);
                                return Future.value(true);
                              },
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Consumer<StatusProvider>(
                                    builder:
                                        (context, statusProvider, _child) =>
                                            Stack(
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              StreamBuilder(
                                                  stream: myStatusUpdates,
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return InkWell(
                                                        onTap: () {},
                                                        child: ListTile(
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          minLeadingWidth: 0,
                                                          leading: Stack(
                                                            children: <Widget>[
                                                              customCircleAvatar(
                                                                  radius: 35),
                                                            ],
                                                          ),
                                                          title: Text(
                                                            getTranslated(
                                                                context,
                                                                'mystatus'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Open Sans',
                                                              fontSize: 17,
                                                              color: Color(
                                                                  0xff3f3d56),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            softWrap: false,
                                                          ),
                                                          subtitle: Text(
                                                            getTranslated(
                                                                context,
                                                                'loading'),
                                                            style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontFamily:
                                                                  'Open Sans',
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0x993f3d56),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                            .hasData &&
                                                        snapshot.data.exists) {
                                                      int seen = !snapshot.data
                                                              .data()
                                                              .containsKey(widget
                                                                  .currentUserNo)
                                                          ? 0
                                                          : 0;
                                                      if (snapshot.data
                                                          .data()
                                                          .containsKey(widget
                                                              .currentUserNo)) {
                                                        snapshot.data[Dbkeys
                                                                .statusITEMSLIST]
                                                            .forEach((status) {
                                                          if (snapshot
                                                              .data[widget
                                                                  .currentUserNo]
                                                              .contains(status[
                                                                  Dbkeys
                                                                      .statusItemID])) {
                                                            seen = seen + 1;
                                                          }
                                                        });
                                                      }

                                                      return ListTile(
                                                        minLeadingWidth: 0.0,
                                                        contentPadding:
                                                            EdgeInsets.all(0.0),
                                                        leading: Stack(
                                                          children: <Widget>[
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StatusView(
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo!,
                                                                      statusDoc:
                                                                          snapshot
                                                                              .data,
                                                                      postedbyFullname:
                                                                          widget.currentUserFullname ??
                                                                              '',
                                                                      postedbyPhotourl:
                                                                          widget
                                                                              .currentUserPhotourl,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child:
                                                                  CircularBorder(
                                                                totalitems: snapshot
                                                                    .data[Dbkeys
                                                                        .statusITEMSLIST]
                                                                    .length,
                                                                totalseen: seen,
                                                                width: 2.5,
                                                                size: 65,
                                                                color: snapshot
                                                                            .data
                                                                            .data()
                                                                            .containsKey(widget
                                                                                .currentUserNo) ==
                                                                        true
                                                                    ? snapshot.data[Dbkeys.statusITEMSLIST].length >
                                                                            0
                                                                        ? Colors
                                                                            .teal
                                                                            .withOpacity(
                                                                                0.8)
                                                                        : Colors
                                                                            .grey
                                                                            .withOpacity(
                                                                                0.8)
                                                                    : Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.8),
                                                                icon: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: snapshot.data[Dbkeys.statusITEMSLIST][snapshot.data[Dbkeys.statusITEMSLIST].length - 1][Dbkeys
                                                                              .statusItemTYPE] ==
                                                                          Dbkeys
                                                                              .statustypeTEXT
                                                                      ? Container(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child: Icon(
                                                                              Icons.text_fields,
                                                                              color: Colors.white54),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(int.parse(snapshot.data[Dbkeys.statusITEMSLIST][snapshot.data[Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemBGCOLOR], radix: 16)),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                        )
                                                                      : snapshot.data[Dbkeys.statusITEMSLIST][snapshot.data[Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] ==
                                                                              Dbkeys.statustypeVIDEO
                                                                          ? Container(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              child: Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.black87,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: snapshot.data[Dbkeys.statusITEMSLIST][snapshot.data[Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                              imageBuilder: (context, imageProvider) => Container(
                                                                                width: 50.0,
                                                                                height: 50.0,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                ),
                                                                              ),
                                                                              placeholder: (context, url) => Container(
                                                                                width: 50.0,
                                                                                height: 50.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey[300],
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Container(
                                                                                width: 50.0,
                                                                                height: 50.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey[300],
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        title: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StatusView(
                                                                              currentUserNo: widget.currentUserNo!,
                                                                              statusDoc: snapshot.data,
                                                                              postedbyFullname: widget.currentUserFullname ?? '',
                                                                              postedbyPhotourl: widget.currentUserPhotourl,
                                                                            )));
                                                          },
                                                          child: Text(
                                                            getTranslated(
                                                                context,
                                                                'mystatus'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Open Sans',
                                                              fontSize: 17,
                                                              color: Color(
                                                                  0xff3f3d56),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                        subtitle: InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          StatusView(
                                                                            currentUserNo:
                                                                                widget.currentUserNo!,
                                                                            statusDoc:
                                                                                snapshot.data,
                                                                            postedbyFullname:
                                                                                widget.currentUserFullname ?? '',
                                                                            postedbyPhotourl:
                                                                                widget.currentUserPhotourl,
                                                                          )));
                                                            },
                                                            child: Text(
                                                              getTranslated(
                                                                  context,
                                                                  'taptoview'),
                                                              style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontFamily:
                                                                    'Open Sans',
                                                                fontSize: 13,
                                                                color: Color(
                                                                    0x993f3d56),
                                                              ),
                                                            )),
                                                        trailing: Container(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          width: 90,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              InkWell(
                                                                onTap: snapshot
                                                                            .data[Dbkeys.statusVIEWERLISTWITHTIME]
                                                                            .length >
                                                                        0
                                                                    ? () {
                                                                        showViewers(
                                                                            context,
                                                                            snapshot.data,
                                                                            contactsProvider.filtered);
                                                                      }
                                                                    : () {},
                                                                child: Row(
                                                                  children: [
                                                                    Icon(Icons
                                                                        .visibility),
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      ' ${snapshot.data[Dbkeys.statusVIEWERLIST].length}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  deleteOptions(
                                                                      context,
                                                                      snapshot
                                                                          .data);
                                                                },
                                                                child: SizedBox(
                                                                    width: 25,
                                                                    child: Icon(
                                                                        Icons
                                                                            .edit)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    } else if (!snapshot
                                                            .hasData ||
                                                        !snapshot.data.exists) {
                                                      return InkWell(
                                                        onTap:
                                                            observer.isAllowCreatingStatus ==
                                                                    false
                                                                ? () {
                                                                    Fiberchat.showRationale(getTranslated(
                                                                        this.context,
                                                                        'disabled'));
                                                                  }
                                                                : () {
                                                                    showMediaOptions(
                                                                        phoneVariants:
                                                                            widget
                                                                                .phoneNumberVariants,
                                                                        context:
                                                                            context,
                                                                        pickVideoCallback:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => StatusVideoEditor(
                                                                                        callback: (v, d, t) async {
                                                                                          Navigator.of(context).pop();
                                                                                          await uploadFile(duration: t, filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeVIDEO, file: d, caption: v);
                                                                                        },
                                                                                        title: getTranslated(context, 'createstatus'),
                                                                                      )));
                                                                        },
                                                                        pickImageCallback:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => StatusImageEditor(
                                                                                        callback: (v, d) async {
                                                                                          Navigator.of(context).pop();
                                                                                          await uploadFile(filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeIMAGE, file: d, caption: v);
                                                                                        },
                                                                                        title: getTranslated(context, 'createstatus'),
                                                                                      )));
                                                                        });
                                                                  },
                                                        child: ListTile(
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          minLeadingWidth: 0.0,
                                                          leading: Stack(
                                                            children: <Widget>[
                                                              customCircleAvatar(
                                                                  radius: 35),
                                                              Positioned(
                                                                bottom: 1.0,
                                                                right: 1.0,
                                                                child:
                                                                    Container(
                                                                  height: 20,
                                                                  width: 20,
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 15,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          title: Text(
                                                            getTranslated(
                                                                context,
                                                                'mystatus'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Open Sans',
                                                              fontSize: 17,
                                                              color: Color(
                                                                  0xff3f3d56),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            softWrap: false,
                                                          ),
                                                          subtitle: Text(
                                                            getTranslated(
                                                                context,
                                                                'taptoupdtstatus'),
                                                            style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontFamily:
                                                                  'Open Sans',
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0x993f3d56),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return InkWell(
                                                      onTap: () {},
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.all(0.0),
                                                        minLeadingWidth: 0.0,
                                                        leading: Stack(
                                                          children: <Widget>[
                                                            customCircleAvatar(
                                                                radius: 35),
                                                          ],
                                                        ),
                                                        title: Text(
                                                          getTranslated(context,
                                                              'mystatus'),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Open Sans',
                                                            fontSize: 17,
                                                            color: Color(
                                                                0xff3f3d56),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          softWrap: false,
                                                        ),
                                                        subtitle: Text(
                                                          getTranslated(context,
                                                              'loading'),
                                                          style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontFamily:
                                                                'Open Sans',
                                                            fontSize: 13,
                                                            color: Color(
                                                                0x993f3d56),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                        context, 'rcntupdates'),
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 13,
                                                  ),
                                                  statusProvider
                                                              .searchingcontactsstatus ==
                                                          true
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 17),
                                                          height: 15,
                                                          width: 15,
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(top: 0),
                                                              child: CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      1.5,
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      fiberchatBlue)),
                                                            ),
                                                          ),
                                                          color: Colors
                                                              .transparent)
                                                      : SizedBox()
                                                ],
                                              ),
                                              statusProvider
                                                          .searchingcontactsstatus ==
                                                      true
                                                  ? Expanded(
                                                      child: Container(
                                                          color: Colors.white),
                                                    )
                                                  : statusProvider
                                                              .contactsStatus
                                                              .length ==
                                                          0
                                                      ? Expanded(
                                                          child: Container(
                                                              child: Center(
                                                                child: Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 40,
                                                                        left:
                                                                            25,
                                                                        right:
                                                                            25,
                                                                        bottom:
                                                                            70),
                                                                    child: Text(
                                                                      getTranslated(
                                                                          context,
                                                                          'nostatus'),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0,
                                                                          color: fiberchatGrey.withOpacity(
                                                                              0.8),
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    )),
                                                              ),
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      : Expanded(
                                                          child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      0,
                                                                      8,
                                                                      8,
                                                                      8),
                                                              color:
                                                                  Colors.white,
                                                              child: ListView
                                                                  .builder(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                itemCount:
                                                                    statusProvider
                                                                        .contactsStatus
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        idx) {
                                                                  int seen = !statusProvider
                                                                          .contactsStatus[
                                                                              idx]
                                                                          .data()!
                                                                          .containsKey(
                                                                              widget.currentUserNo)
                                                                      ? 0
                                                                      : 0;
                                                                  if (statusProvider
                                                                      .contactsStatus[
                                                                          idx]
                                                                      .data()
                                                                      .containsKey(
                                                                          widget
                                                                              .currentUserNo)) {
                                                                    statusProvider
                                                                        .contactsStatus[
                                                                            idx]
                                                                            [
                                                                            Dbkeys
                                                                                .statusITEMSLIST]
                                                                        .forEach(
                                                                            (status) {
                                                                      if (statusProvider
                                                                          .contactsStatus[
                                                                              idx]
                                                                          .data()[widget
                                                                              .currentUserNo]
                                                                          .contains(
                                                                              status[Dbkeys.statusItemID])) {
                                                                        seen =
                                                                            seen +
                                                                                1;
                                                                      }
                                                                    });
                                                                  }
                                                                  return Consumer<
                                                                          AvailableContactsProvider>(
                                                                      builder: (context, contactsProvider, _child) => FutureBuilder<
                                                                              DocumentSnapshot>(
                                                                          future: contactsProvider.getUserDoc(statusProvider.contactsStatus[idx].data()[Dbkeys
                                                                              .statusPUBLISHERPHONE]),
                                                                          builder:
                                                                              (BuildContext context, AsyncSnapshot snapshot) {
                                                                            if (snapshot.hasData &&
                                                                                snapshot.data.exists) {
                                                                              return InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => StatusView(
                                                                                                callback: (statuspublisherphone) {
                                                                                                  FirebaseFirestore.instance.collection(DbPaths.collectionnstatus).doc(statuspublisherphone).get().then((doc) {
                                                                                                    if (doc.exists) {
                                                                                                      int i = statusProvider.contactsStatus.indexWhere((element) => element[Dbkeys.statusPUBLISHERPHONE] == statuspublisherphone);
                                                                                                      statusProvider.contactsStatus.removeAt(i);
                                                                                                      statusProvider.contactsStatus.insert(i, doc);
                                                                                                      setState(() {});
                                                                                                    }
                                                                                                  });
                                                                                                },
                                                                                                currentUserNo: widget.currentUserNo!,
                                                                                                statusDoc: statusProvider.contactsStatus[idx],
                                                                                                postedbyFullname: statusProvider.joinedUserPhoneStringAsInServer.elementAt(statusProvider.joinedUserPhoneStringAsInServer.toList().indexWhere((element) => statusProvider.contactsStatus[idx][Dbkeys.statusPUBLISHERPHONEVARIANTS].contains(element.phone))).name.toString(),
                                                                                                postedbyPhotourl: snapshot.data![Dbkeys.photoUrl],
                                                                                              )));
                                                                                },
                                                                                child: ListTile(
                                                                                  contentPadding: EdgeInsets.all(0.0),
                                                                                  leading: Padding(
                                                                                    padding: const EdgeInsets.only(left: 5),
                                                                                    child: CircularBorder(
                                                                                      totalitems: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length,
                                                                                      totalseen: seen,
                                                                                      width: 2.5,
                                                                                      size: 65,
                                                                                      color: statusProvider.contactsStatus[idx].data().containsKey(widget.currentUserNo)
                                                                                          ? statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length > 0
                                                                                              ? Colors.teal.withOpacity(0.8)
                                                                                              : Colors.grey.withOpacity(0.8)
                                                                                          : Colors.grey.withOpacity(0.8),
                                                                                      icon: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] == Dbkeys.statustypeTEXT
                                                                                          ? Container(
                                                                                              width: 50.0,
                                                                                              height: 50.0,
                                                                                              child: Icon(Icons.text_fields, color: Colors.white54),
                                                                                              decoration: BoxDecoration(
                                                                                                color: Color(int.parse(statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemBGCOLOR], radix: 16)),
                                                                                                shape: BoxShape.circle,
                                                                                              ),
                                                                                            )
                                                                                          : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] == Dbkeys.statustypeVIDEO
                                                                                              ? Container(
                                                                                                  width: 50.0,
                                                                                                  height: 50.0,
                                                                                                  child: Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.black87,
                                                                                                    shape: BoxShape.circle,
                                                                                                  ),
                                                                                                )
                                                                                              : CachedNetworkImage(
                                                                                                  imageUrl: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                                                  imageBuilder: (context, imageProvider) => Container(
                                                                                                    width: 50.0,
                                                                                                    height: 50.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      shape: BoxShape.circle,
                                                                                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                                    ),
                                                                                                  ),
                                                                                                  placeholder: (context, url) => Container(
                                                                                                    width: 50.0,
                                                                                                    height: 50.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Colors.grey[300],
                                                                                                      shape: BoxShape.circle,
                                                                                                    ),
                                                                                                  ),
                                                                                                  errorWidget: (context, url, error) => Container(
                                                                                                    width: 50.0,
                                                                                                    height: 50.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Colors.grey[300],
                                                                                                      shape: BoxShape.circle,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                    ),
                                                                                  ),
                                                                                  title: Text(
                                                                                    statusProvider.joinedUserPhoneStringAsInServer.elementAt(statusProvider.joinedUserPhoneStringAsInServer.toList().indexWhere((element) => statusProvider.contactsStatus[idx][Dbkeys.statusPUBLISHERPHONEVARIANTS].contains(element.phone.toString()))).name.toString(),
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Open Sans',
                                                                                      fontSize: 17,
                                                                                      color: Color(0xff3f3d56),
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                    softWrap: false,
                                                                                  ),
                                                                                  subtitle: Text(
                                                                                    getStatusTime(statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemID], this.context),
                                                                                    style: TextStyle(
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      fontFamily: 'Open Sans',
                                                                                      fontSize: 13,
                                                                                      color: Color(0x993f3d56),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }
                                                                            return InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => StatusView(
                                                                                              callback: (statuspublisherphone) {
                                                                                                FirebaseFirestore.instance.collection(DbPaths.collectionnstatus).doc(statuspublisherphone).get().then((doc) {
                                                                                                  if (doc.exists) {
                                                                                                    int i = statusProvider.contactsStatus.indexWhere((element) => element[Dbkeys.statusPUBLISHERPHONE] == statuspublisherphone);
                                                                                                    statusProvider.contactsStatus.removeAt(i);
                                                                                                    statusProvider.contactsStatus.insert(i, doc);
                                                                                                    setState(() {});
                                                                                                  }
                                                                                                });
                                                                                              },
                                                                                              currentUserNo: widget.currentUserNo!,
                                                                                              statusDoc: statusProvider.contactsStatus[idx],
                                                                                              postedbyFullname: statusProvider.joinedUserPhoneStringAsInServer.elementAt(statusProvider.joinedUserPhoneStringAsInServer.toList().indexWhere((element) => statusProvider.contactsStatus[idx][Dbkeys.statusPUBLISHERPHONEVARIANTS].contains(element.phone.toString()))).name.toString(),
                                                                                              postedbyPhotourl: null,
                                                                                            )));
                                                                              },
                                                                              child: ListTile(
                                                                                contentPadding: EdgeInsets.all(0.0),
                                                                                leading: CircularBorder(
                                                                                  totalitems: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length,
                                                                                  totalseen: seen,
                                                                                  width: 2.5,
                                                                                  size: 65,
                                                                                  color: statusProvider.contactsStatus[idx].data().containsKey(widget.currentUserNo)
                                                                                      ? statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length > 0
                                                                                          ? Colors.teal.withOpacity(0.8)
                                                                                          : Colors.grey.withOpacity(0.8)
                                                                                      : Colors.grey.withOpacity(0.8),
                                                                                  icon: Padding(
                                                                                    padding: const EdgeInsets.all(3.0),
                                                                                    child: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] == Dbkeys.statustypeTEXT
                                                                                        ? Container(
                                                                                            width: 50.0,
                                                                                            height: 50.0,
                                                                                            child: Icon(Icons.text_fields, color: Colors.white54),
                                                                                            decoration: BoxDecoration(
                                                                                              color: Color(int.parse(statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemBGCOLOR], radix: 16)),
                                                                                              shape: BoxShape.circle,
                                                                                            ),
                                                                                          )
                                                                                        : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] == Dbkeys.statustypeVIDEO
                                                                                            ? Container(
                                                                                                width: 50.0,
                                                                                                height: 50.0,
                                                                                                child: Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.black87,
                                                                                                  shape: BoxShape.circle,
                                                                                                ),
                                                                                              )
                                                                                            : CachedNetworkImage(
                                                                                                imageUrl: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                                                imageBuilder: (context, imageProvider) => Container(
                                                                                                  width: 50.0,
                                                                                                  height: 50.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    shape: BoxShape.circle,
                                                                                                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                                  ),
                                                                                                ),
                                                                                                placeholder: (context, url) => Container(
                                                                                                  width: 50.0,
                                                                                                  height: 50.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.grey[300],
                                                                                                    shape: BoxShape.circle,
                                                                                                  ),
                                                                                                ),
                                                                                                errorWidget: (context, url, error) => Container(
                                                                                                  width: 50.0,
                                                                                                  height: 50.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.grey[300],
                                                                                                    shape: BoxShape.circle,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                  ),
                                                                                ),
                                                                                title: Text(
                                                                                  statusProvider.joinedUserPhoneStringAsInServer.elementAt(statusProvider.joinedUserPhoneStringAsInServer.toList().indexWhere((element) => statusProvider.contactsStatus[idx][Dbkeys.statusPUBLISHERPHONEVARIANTS].contains(element.phone))).name.toString(),
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Open Sans',
                                                                                    fontSize: 17,
                                                                                    color: Color(0xff3f3d56),
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  softWrap: false,
                                                                                ),
                                                                                subtitle: Text(
                                                                                  getStatusTime(statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemID], this.context),
                                                                                  style: TextStyle(
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    fontFamily: 'Open Sans',
                                                                                    fontSize: 13,
                                                                                    color: Color(0x993f3d56),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }));
                                                                },
                                                              )),
                                                        ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          child: statusProvider.isLoading
                                              ? Container(
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                fiberchatBlue)),
                                                  ),
                                                  color: DESIGN_TYPE ==
                                                          Themetype.whatsapp
                                                      ? fiberchatBlack
                                                          .withOpacity(0.6)
                                                      : fiberchatWhite
                                                          .withOpacity(0.6))
                                              : Container(),
                                        )
                                      ],
                                    ),
                                  ),
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
                        onTap: observer.isAllowCreatingStatus == false
                            ? () {
                                Fiberchat.showRationale(
                                    getTranslated(this.context, 'disabled'));
                              }
                            : () async {
                                showMediaOptions(
                                    phoneVariants: widget.phoneNumberVariants,
                                    context: context,
                                    pickVideoCallback: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StatusVideoEditor(
                                                    callback: (v, d, t) async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await uploadFile(
                                                          filename: DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch
                                                              .toString(),
                                                          type: Dbkeys
                                                              .statustypeVIDEO,
                                                          file: d,
                                                          caption: v,
                                                          duration: t);
                                                    },
                                                    title: getTranslated(
                                                        context,
                                                        'createstatus'),
                                                  )));
                                    },
                                    pickImageCallback: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StatusImageEditor(
                                                    callback: (v, d) async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await uploadFile(
                                                          filename: DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch
                                                              .toString(),
                                                          type: Dbkeys
                                                              .statustypeIMAGE,
                                                          file: d,
                                                          caption: v);
                                                    },
                                                    title: getTranslated(
                                                        context,
                                                        'createstatus'),
                                                  )));
                                    });
                              },
                        child: XDComponent5271()),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ));
  }

  showMediaOptions(
      {required BuildContext context,
      required Function pickImageCallback,
      required Function pickVideoCallback,
      required List<dynamic> phoneVariants}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // return your layout
        return Consumer<StatusProvider>(
          builder: (context, statusProvider, _child) => Container(
            padding: EdgeInsets.all(12),
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // createTextCallback();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TextStatus(
                                currentuserNo: widget.currentUserNo!,
                                phoneNumberVariants: phoneVariants)));
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.text_fields,
                          size: 39,
                          color: fiberchatLightGreen,
                        ),
                        SizedBox(height: 3),
                        Text(
                          getTranslated(context, 'text'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: fiberchatBlack),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageCallback();
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 39,
                          color: fiberchatLightGreen,
                        ),
                        SizedBox(height: 3),
                        Text(
                          getTranslated(context, 'image'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: fiberchatBlack),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      pickVideoCallback();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_camera_back,
                            size: 39,
                            color: fiberchatLightGreen,
                          ),
                          SizedBox(height: 3),
                          Text(
                            getTranslated(context, 'video'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: fiberchatBlack),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  deleteOptions(BuildContext context, DocumentSnapshot myStatusDoc) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Consumer<StatusProvider>(
              builder: (context, statusProvider, _child) => Container(
                  padding: EdgeInsets.all(12),
                  height: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          getTranslated(context, 'myactstatus'),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        height: 96,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount:
                                myStatusDoc[Dbkeys.statusITEMSLIST].length,
                            itemBuilder: (context, int i) {
                              return Container(
                                height: 40,
                                margin: EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    myStatusDoc[Dbkeys.statusITEMSLIST][i]
                                                [Dbkeys.statusItemTYPE] ==
                                            Dbkeys.statustypeTEXT
                                        ? Container(
                                            width: 70.0,
                                            height: 70.0,
                                            child: Icon(Icons.text_fields,
                                                color: Colors.white54),
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  myStatusDoc[Dbkeys
                                                          .statusITEMSLIST][i][
                                                      Dbkeys.statusItemBGCOLOR],
                                                  radix: 16)),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : myStatusDoc[Dbkeys.statusITEMSLIST][i]
                                                    [Dbkeys.statusItemTYPE] ==
                                                Dbkeys.statustypeVIDEO
                                            ? Container(
                                                width: 70.0,
                                                height: 70.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                    Icons.play_circle_fill,
                                                    size: 29,
                                                    color: Colors.white54),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: myStatusDoc[
                                                        Dbkeys.statusITEMSLIST]
                                                    [i][Dbkeys.statusItemURL],
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  width: 70.0,
                                                  height: 70.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 70.0,
                                                  height: 70.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 70.0,
                                                  height: 70.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                    Positioned(
                                      top: 45.0,
                                      left: 45.0,
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          showDialog(
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: new Text(getTranslated(
                                                    this.context, 'dltstatus')),
                                                actions: [
                                                  // ignore: deprecated_member_use
                                                  FlatButton(
                                                    child: Text(
                                                      getTranslated(
                                                          context, 'cancel'),
                                                      style: TextStyle(
                                                          color:
                                                              multiboxMainColor,
                                                          fontSize: 18),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  // ignore: deprecated_member_use
                                                  FlatButton(
                                                    child: Text(
                                                      getTranslated(
                                                          context, 'delete'),
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Fiberchat.toast(
                                                          getTranslated(context,
                                                              'plswait'));
                                                      statusProvider
                                                          .setIsLoading(true);

                                                      if (myStatusDoc[Dbkeys
                                                                  .statusITEMSLIST][i]
                                                              [Dbkeys
                                                                  .statusItemTYPE] ==
                                                          Dbkeys
                                                              .statustypeTEXT) {
                                                        if (myStatusDoc[Dbkeys
                                                                    .statusITEMSLIST]
                                                                .length <
                                                            2) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionnstatus)
                                                              .doc(widget
                                                                  .currentUserNo)
                                                              .delete();
                                                        } else {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionnstatus)
                                                              .doc(widget
                                                                  .currentUserNo)
                                                              .update({
                                                            Dbkeys.statusITEMSLIST:
                                                                FieldValue
                                                                    .arrayRemove([
                                                              myStatusDoc[Dbkeys
                                                                  .statusITEMSLIST][i]
                                                            ])
                                                          });
                                                        }

                                                        statusProvider
                                                            .setIsLoading(
                                                                false);
                                                        Fiberchat.toast(
                                                            getTranslated(
                                                                this.context,
                                                                'dltscs'));
                                                      } else {
                                                        FirebaseStorage.instance
                                                            .refFromURL(myStatusDoc[
                                                                Dbkeys
                                                                    .statusITEMSLIST][i][Dbkeys
                                                                .statusItemURL])
                                                            .delete()
                                                            .then(
                                                                (value) async {
                                                          if (myStatusDoc[Dbkeys
                                                                      .statusITEMSLIST]
                                                                  .length <
                                                              2) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionnstatus)
                                                                .doc(widget
                                                                    .currentUserNo)
                                                                .delete();
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionnstatus)
                                                                .doc(widget
                                                                    .currentUserNo)
                                                                .update({
                                                              Dbkeys.statusITEMSLIST:
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                myStatusDoc[Dbkeys
                                                                    .statusITEMSLIST][i]
                                                              ])
                                                            });
                                                          }
                                                        }).then((value) {
                                                          statusProvider
                                                              .setIsLoading(
                                                                  false);
                                                          Fiberchat.toast(
                                                              getTranslated(
                                                                  this.context,
                                                                  'dltscs'));
                                                        }).catchError(
                                                                (onError) async {
                                                          statusProvider
                                                              .setIsLoading(
                                                                  false);
                                                          print('ERROR DELETING STATUS: ' +
                                                              onError
                                                                  .toString());

                                                          if (onError.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                              onError
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound2) ||
                                                              onError
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound3) ||
                                                              onError
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound4)) {
                                                            if (myStatusDoc[Dbkeys
                                                                        .statusITEMSLIST]
                                                                    .length <
                                                                2) {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectionnstatus)
                                                                  .doc(widget
                                                                      .currentUserNo)
                                                                  .delete();
                                                            } else {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectionnstatus)
                                                                  .doc(widget
                                                                      .currentUserNo)
                                                                  .update({
                                                                Dbkeys.statusITEMSLIST:
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  myStatusDoc[Dbkeys
                                                                      .statusITEMSLIST][i]
                                                                ])
                                                              });
                                                            }
                                                          }
                                                        });
                                                      }
                                                    },
                                                  )
                                                ],
                                              );
                                            },
                                            context: context,
                                          );
                                        },
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  )));
        });
  }
}
