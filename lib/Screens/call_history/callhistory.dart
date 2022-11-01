import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/call_history/utils/InfiniteListView.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/call_history_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/call_utilities.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/permissions.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallHistory extends StatefulWidget {
  final String? userphone;
  final SharedPreferences prefs;
  CallHistory({required this.userphone, required this.prefs});
  @override
  _CallHistoryState createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  call(BuildContext context, bool isvideocall, var peer) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        currentuseruid: widget.userphone,
        fromDp: myphotoUrl,
        toDp: peer["photoUrl"],
        fromUID: widget.userphone,
        fromFullname: mynickname,
        toUID: peer['phone'],
        toFullname: peer["nickname"],
        context: context,
        isvideocall: isvideocall);
  }

  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Consumer<FirestoreDataProviderCALLHISTORY>(
      builder: (context, firestoreDataProvider, _) => SafeArea(
        child: Scaffold(
          key: _scaffold,
          floatingActionButton: firestoreDataProvider.recievedDocs.length == 0
              ? SizedBox()
              : FloatingActionButton(
                  backgroundColor: fiberchatWhite,
                  child: Icon(
                    Icons.delete,
                    size: 30.0,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text(getTranslated(context, 'clearlog')),
                          content: new Text(getTranslated(context, 'clearloglong')),
                          actions: [
                            // ignore: deprecated_member_use
                            FlatButton(
                              child: Text(
                                getTranslated(context, 'cancel'),
                                style: TextStyle(color: multiboxMainColor, fontSize: 18),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            // ignore: deprecated_member_use
                            FlatButton(
                              child: Text(
                                getTranslated(context, 'delete'),
                                style: TextStyle(color: Colors.red, fontSize: 18),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                Fiberchat.toast(getTranslated(context, 'plswait'));
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(widget.userphone)
                                    .collection(DbPaths.collectioncallhistory)
                                    .get()
                                    .then((snapshot) {
                                  for (DocumentSnapshot doc in snapshot.docs) {
                                    doc.reference.delete();
                                  }
                                }).then((value) {
                                  firestoreDataProvider.clearall();
                                  // Fiberchat.toast( 'All Logs Deleted!');
                                });
                              },
                            )
                          ],
                        );
                      },
                      context: context,
                    );
                  }),
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
                                  'Calls',
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
                          child: Consumer<AvailableContactsProvider>(
                            builder: (context, contactsProvider, _child) => InfiniteListView(
                              firestoreDataProviderCALLHISTORY: firestoreDataProvider,
                              datatype: 'CALLHISTORY',
                              refdata: FirebaseFirestore.instance
                                  .collection(DbPaths.collectionusers)
                                  .doc(widget.userphone)
                                  .collection(DbPaths.collectioncallhistory)
                                  .orderBy('TIME', descending: true)
                                  .limit(14),
                              list: ListView.builder(
                                  padding: EdgeInsets.only(bottom: 150),
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: firestoreDataProvider.recievedDocs.length,
                                  itemBuilder: (BuildContext context, int i) {
                                    var dc = firestoreDataProvider.recievedDocs[i];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          // padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                          // height: 40,
                                          child: FutureBuilder(
                                              future: contactsProvider.getUserDoc(dc['PEER']),
                                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                if (snapshot.hasData) {
                                                  var user = snapshot.data!.data();
                                                  return ListTile(
                                                    onLongPress: () {
                                                      List<Widget> tiles = List.from(<Widget>[]);

                                                      tiles.add(ListTile(
                                                          dense: true,
                                                          leading: Icon(Icons.delete),
                                                          title: Text(
                                                            getTranslated(context, 'delete'),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          onTap: () async {
                                                            Navigator.of(context).pop();

                                                            FirebaseFirestore.instance
                                                                .collection(DbPaths.collectionusers)
                                                                .doc(widget.userphone)
                                                                .collection(
                                                                    DbPaths.collectioncallhistory)
                                                                .doc(dc['TIME'].toString())
                                                                .delete();
                                                            Fiberchat.toast('Deleted!');
                                                            firestoreDataProvider.deleteSingle(dc);
                                                          }));

                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return SimpleDialog(children: tiles);
                                                          });
                                                    },
                                                    isThreeLine: false,
                                                    leading: Stack(
                                                      children: [
                                                        customCircleAvatar(
                                                            url: user['photoUrl'], radius: 22),
                                                        dc['STARTED'] == null || dc['ENDED'] == null
                                                            ? SizedBox(
                                                                height: 0,
                                                                width: 0,
                                                              )
                                                            : Positioned(
                                                                bottom: 0,
                                                                right: 0,
                                                                child: Container(
                                                                  padding:
                                                                      EdgeInsets.fromLTRB(6, 2, 6, 2),
                                                                  decoration: BoxDecoration(
                                                                      color: fiberchatLightGreen,
                                                                      borderRadius: BorderRadius.all(
                                                                          Radius.circular(20))),
                                                                  child: Text(
                                                                    dc['ENDED']
                                                                                .toDate()
                                                                                .difference(dc['STARTED']
                                                                                    .toDate())
                                                                                .inMinutes <
                                                                            1
                                                                        ? dc['ENDED']
                                                                                .toDate()
                                                                                .difference(dc['STARTED']
                                                                                    .toDate())
                                                                                .inSeconds
                                                                                .toString() +
                                                                            's'
                                                                        : dc['ENDED']
                                                                                .toDate()
                                                                                .difference(dc['STARTED']
                                                                                    .toDate())
                                                                                .inMinutes
                                                                                .toString() +
                                                                            'm',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 10),
                                                                  ),
                                                                ))
                                                      ],
                                                    ),
                                                    title: Text(
                                                      user['nickname'],
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          height: 1.4, fontWeight: FontWeight.w500),
                                                    ),
                                                    subtitle: Padding(
                                                      padding: const EdgeInsets.only(top: 3),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            dc['TYPE'] == 'INCOMING'
                                                                ? (dc['STARTED'] == null
                                                                    ? Icons.call_missed
                                                                    : Icons.call_received)
                                                                : (dc['STARTED'] == null
                                                                    ? Icons.call_made_rounded
                                                                    : Icons.call_made_rounded),
                                                            size: 15,
                                                            color: dc['TYPE'] == 'INCOMING'
                                                                ? (dc['STARTED'] == null
                                                                    ? Colors.redAccent
                                                                    : fiberchatLightGreen)
                                                                : (dc['STARTED'] == null
                                                                    ? Colors.redAccent
                                                                    : fiberchatLightGreen),
                                                          ),
                                                          SizedBox(
                                                            width: 7,
                                                          ),
                                                          Text(Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                                      dc["TIME"]))
                                                                  .MMMMd
                                                                  .toString() +
                                                              ', ' +
                                                              Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                                      dc["TIME"]))
                                                                  .Hm
                                                                  .toString()),
                                                          // Text(time)
                                                        ],
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                        icon: Icon(
                                                            dc['ISVIDEOCALL'] == true
                                                                ? Icons.video_call
                                                                : Icons.call,
                                                            color: multiboxMainColor,
                                                            size: 24),
                                                        onPressed: observer.iscallsallowed == false
                                                            ? () {
                                                                Fiberchat.showRationale(getTranslated(
                                                                    this.context, 'callnotallowed'));
                                                              }
                                                            : () async {
                                                                if (dc['ISVIDEOCALL'] == true) {
                                                                  //---Make a video call
                                                                  await Permissions
                                                                          .cameraAndMicrophonePermissionsGranted()
                                                                      .then((isgranted) {
                                                                    if (isgranted == true) {
                                                                      call(context, true, user);
                                                                    } else {
                                                                      Fiberchat.showRationale(
                                                                        getTranslated(context, 'pmc'),
                                                                      );
                                                                      Navigator.push(
                                                                          context,
                                                                          new MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  OpenSettings()));
                                                                    }
                                                                  }).catchError((onError) {
                                                                    Fiberchat.showRationale(
                                                                      getTranslated(context, 'pmc'),
                                                                    );
                                                                    Navigator.push(
                                                                        context,
                                                                        new MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                OpenSettings()));
                                                                  });
                                                                } else if (dc['ISVIDEOCALL'] == false) {
                                                                  //---Make a audio call
                                                                  await Permissions
                                                                          .cameraAndMicrophonePermissionsGranted()
                                                                      .then((isgranted) {
                                                                    if (isgranted == true) {
                                                                      call(context, false, user);
                                                                    } else {
                                                                      Fiberchat.showRationale(
                                                                        getTranslated(context, 'pmc'),
                                                                      );
                                                                      Navigator.push(
                                                                          context,
                                                                          new MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  OpenSettings()));
                                                                    }
                                                                  }).catchError((onError) {
                                                                    Fiberchat.showRationale(
                                                                      getTranslated(context, 'pmc'),
                                                                    );
                                                                    Navigator.push(
                                                                        context,
                                                                        new MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                OpenSettings()));
                                                                  });
                                                                }
                                                              }),
                                                  );
                                                }
                                                return ListTile(
                                                  onLongPress: () {
                                                    List<Widget> tiles = List.from(<Widget>[]);

                                                    tiles.add(ListTile(
                                                        dense: true,
                                                        leading: Icon(Icons.delete),
                                                        title: Text(
                                                          getTranslated(context, 'delete'),
                                                          style: TextStyle(
                                                              fontSize: 16, fontWeight: FontWeight.bold),
                                                        ),
                                                        onTap: () async {
                                                          Navigator.of(context).pop();
                                                          Fiberchat.toast(
                                                              getTranslated(context, 'plswait'));
                                                          FirebaseFirestore.instance
                                                              .collection(DbPaths.collectionusers)
                                                              .doc(widget.userphone)
                                                              .collection(DbPaths.collectioncallhistory)
                                                              .doc(dc['TIME'].toString())
                                                              .delete();
                                                          Fiberchat.toast('Deleted!');
                                                          firestoreDataProvider.deleteSingle(dc);
                                                        }));

                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return SimpleDialog(children: tiles);
                                                        });
                                                  },
                                                  isThreeLine: false,
                                                  leading: Stack(
                                                    children: [
                                                      customCircleAvatar(radius: 22),
                                                      dc['STARTED'] == null || dc['ENDED'] == null
                                                          ? SizedBox(
                                                              height: 0,
                                                              width: 0,
                                                            )
                                                          : Positioned(
                                                              bottom: 0,
                                                              right: 0,
                                                              child: Container(
                                                                padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                                                                decoration: BoxDecoration(
                                                                    color: fiberchatLightGreen,
                                                                    borderRadius: BorderRadius.all(
                                                                        Radius.circular(20))),
                                                                child: Text(
                                                                  dc['ENDED']
                                                                              .toDate()
                                                                              .difference(
                                                                                  dc['STARTED'].toDate())
                                                                              .inMinutes <
                                                                          1
                                                                      ? dc['ENDED']
                                                                              .toDate()
                                                                              .difference(
                                                                                  dc['STARTED'].toDate())
                                                                              .inSeconds
                                                                              .toString() +
                                                                          's'
                                                                      : dc['ENDED']
                                                                              .toDate()
                                                                              .difference(
                                                                                  dc['STARTED'].toDate())
                                                                              .inMinutes
                                                                              .toString() +
                                                                          'm',
                                                                  style: TextStyle(
                                                                      color: Colors.white, fontSize: 10),
                                                                ),
                                                              ))
                                                    ],
                                                  ),
                                                  title: Text(
                                                    contactsProvider.filtered!.entries
                                                                .toList()
                                                                .indexWhere((element) =>
                                                                    element.key == dc['PEER']) >=
                                                            0
                                                        ? contactsProvider.filtered!.entries
                                                            .toList()[contactsProvider.filtered!.entries
                                                                .toList()
                                                                .indexWhere((element) =>
                                                                    element.key == dc['PEER'])]
                                                            .value
                                                        : dc['PEER'],
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        height: 1.4, fontWeight: FontWeight.w500),
                                                  ),
                                                  subtitle: Padding(
                                                    padding: const EdgeInsets.only(top: 3),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          dc['TYPE'] == 'INCOMING'
                                                              ? (dc['STARTED'] == null
                                                                  ? Icons.call_missed
                                                                  : Icons.call_received)
                                                              : (dc['STARTED'] == null
                                                                  ? Icons.call_made_rounded
                                                                  : Icons.call_made_rounded),
                                                          size: 15,
                                                          color: dc['TYPE'] == 'INCOMING'
                                                              ? (dc['STARTED'] == null
                                                                  ? Colors.redAccent
                                                                  : fiberchatLightGreen)
                                                              : (dc['STARTED'] == null
                                                                  ? Colors.redAccent
                                                                  : fiberchatLightGreen),
                                                        ),
                                                        SizedBox(
                                                          width: 7,
                                                        ),
                                                        Text(Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                                    dc["TIME"]))
                                                                .MMMMd
                                                                .toString() +
                                                            ', ' +
                                                            Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                                    dc["TIME"]))
                                                                .Hm
                                                                .toString()),
                                                        // Text(time)
                                                      ],
                                                    ),
                                                  ),
                                                  trailing: IconButton(
                                                      icon: Icon(
                                                          dc['ISVIDEOCALL'] == true
                                                              ? Icons.video_call
                                                              : Icons.call,
                                                          color: multiboxMainColor,
                                                          size: 24),
                                                      onPressed: null),
                                                );
                                              }),
                                        ),
                                        Divider(
                                          height: 0,
                                        ),
                                      ],
                                    );
                                  }),
                            ),
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
      ),
    );
  }
}

Widget customCircleAvatar({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: Color(0xffE6E6E6),
      radius: radius ?? 30,
      child: Icon(
        Icons.person,
        color: Color(0xffCCCCCC),
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              backgroundImage: NetworkImage('$url'),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: Icon(
                Icons.person,
                color: Color(0xffCCCCCC),
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: Icon(
                Icons.person,
                color: Color(0xffCCCCCC),
              ),
            ));
  }
}

Widget customCircleAvatarGroup({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: Color(0xffE6E6E6),
      radius: radius ?? 30,
      child: Icon(
        Icons.people,
        color: Color(0xffCCCCCC),
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              backgroundImage: NetworkImage('$url'),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: Icon(
                Icons.people,
                color: Color(0xffCCCCCC),
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: Icon(
                Icons.people,
                color: Color(0xffCCCCCC),
              ),
            ));
  }
}

Widget customCircleAvatarBroadcast({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: Color(0xffE6E6E6),
      radius: radius ?? 30,
      child: Icon(
        Icons.campaign_sharp,
        color: Color(0xffCCCCCC),
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              backgroundImage: NetworkImage('$url'),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: Icon(
                Icons.campaign_sharp,
                color: Color(0xffCCCCCC),
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: Icon(
                Icons.campaign_sharp,
                color: Color(0xffCCCCCC),
              ),
            ));
  }
}
