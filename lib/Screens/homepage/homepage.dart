import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:adobe_xd/page_link.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/homepage/Setupdata.dart';
import 'package:fiberchat/Screens/notifications/AllNotifications.dart';
import 'package:fiberchat/Screens/sharing_intent/SelectContactToShare.dart';
import 'package:fiberchat/Screens/splash_screen/splash_screen.dart';
import 'package:fiberchat/Screens/status/status.dart';
import 'package:fiberchat/Screens/vpn/vpn_setup.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/StatusProvider.dart';
import 'package:fiberchat/Services/Providers/call_history_provider.dart';
import 'package:fiberchat/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/phonenumberVariantsGenerator.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as local;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Models/DataModel.dart';
import '../../widgets/componentss/xd_component5231.dart';
import '../../widgets/componentss/xd_component5241.dart';
import '../../widgets/componentss/xd_component5251.dart';
import '../../widgets/componentss/xd_component5253.dart';
import '../../widgets/componentss/xd_component5301.dart';
import '../../widgets/componentss/xd_component5311.dart';
import '../../widgets/componentss/xd_component5321.dart';
import '../../widgets/componentss/xd_svgg.dart';
import '../Groups/AddContactsToGroup.dart';
import '../auth_screens/login.dart';
import '../call_history/callhistory.dart';
import '../contact_screens/SmartContactsPage.dart';
import '../recent_chats/RecentsChats.dart';
import '../safebox/xd_safe_bo_x.dart';
import '../search_chats/SearchRecentChat.dart';
import '../settings/settings.dart';
import '../wallet/xd_mainpage_crypto.dart';

class Homepage extends StatefulWidget {
  Homepage({required this.currentUserNo, required this.isSecuritySetupDone, required this.prefs, key})
      : super(key: key);
  final String? currentUserNo;
  final bool isSecuritySetupDone;
  final SharedPreferences prefs;
  @override
  State createState() => new HomepageState(currentUserNo: this.currentUserNo);
}

class HomepageState extends State<Homepage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  HomepageState({Key? key, this.currentUserNo}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }
  TabController? controllerIfcallallowed;
  TabController? controllerIfcallNotallowed;
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles = [];
  String? _sharedText;
  @override
  bool get wantKeepAlive => true;

  bool isFetching = true;
  List phoneNumberVariants = [];
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    if (currentUserNo != null && widget.currentUserNo != null)
      await FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(currentUserNo).update(
        {Dbkeys.lastSeen: true},
      );
  }

  void setLastSeen() async {
    if (currentUserNo != null && widget.currentUserNo != null)
      await FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(currentUserNo).update(
        {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch},
      );
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  StreamSubscription? spokenSubscription;
  List<StreamSubscription> unreadSubscriptions = List.from(<StreamSubscription>[]);

  List<StreamController> controllers = List.from(<StreamController>[]);
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String? deviceid;
  var mapDeviceInfo = {};
  String? maintainanceMessage;
  bool isNotAllowEmulator = false;
  bool? isblockNewlogins = false;
  bool? isApprovalNeededbyAdminForNewUser = false;
  String? accountApprovalMessage = 'Account Approved';
  String? accountstatus;
  String? accountactionmessage;
  String? userPhotourl;
  String? userFullname;
  String? joinedList;
  @override
  void initState() {
    listenToSharingintent();
    listenToNotification();
    super.initState();
    getSignedInUserOrRedirect();
    registerNotification();

    setdeviceinfo();
    controllerIfcallallowed = TabController(length: 4, vsync: this);
    controllerIfcallallowed!.index = 1;
    controllerIfcallNotallowed = TabController(length: 3, vsync: this);
    controllerIfcallNotallowed!.index = 1;

    Fiberchat.internetLookUp();
    WidgetsBinding.instance.addObserver(this);

    LocalAuthentication().canCheckBiometrics.then((res) {
      if (res) biometricEnabled = true;
    });
    getModel();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controllerIfcallallowed!.addListener(() {
        if (controllerIfcallallowed!.index == 2) {
          final statusProvider = Provider.of<StatusProvider>(context, listen: false);
          final contactsProvider = Provider.of<AvailableContactsProvider>(context, listen: false);
          statusProvider.searchContactStatus(
              widget.currentUserNo!, contactsProvider.joinedUserPhoneStringAsInServer);
        }
      });
      controllerIfcallNotallowed!.addListener(() {
        if (controllerIfcallNotallowed!.index == 2) {
          final statusProvider = Provider.of<StatusProvider>(context, listen: false);
          final contactsProvider = Provider.of<AvailableContactsProvider>(context, listen: false);
          statusProvider.searchContactStatus(
              widget.currentUserNo!, contactsProvider.joinedUserPhoneStringAsInServer);
        }
      });
    });
  }

  detectLocale() async {
    await Devicelocale.currentLocale.then((locale) async {
      if (locale == 'ja_JP' &&
          (widget.prefs.getBool('islanguageselected') == false ||
              widget.prefs.getBool('islanguageselected') == null)) {
        Locale _locale = await setLocale('ja');
        FiberchatWrapper.setLocale(context, _locale);
        setState(() {});
      }
    }).catchError((onError) {
      Fiberchat.toast(
        'Error occured while fetching Locale :$onError',
      );
    });
  }

  incrementSessionCount(String myphone) async {
    final StatusProvider statusProvider = Provider.of<StatusProvider>(context, listen: false);
    final AvailableContactsProvider contactsProvider =
        Provider.of<AvailableContactsProvider>(context, listen: false);
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiondashboard)
        .doc(DbPaths.docuserscount)
        .set(
            Platform.isAndroid
                ? {
                    Dbkeys.totalvisitsANDROID: FieldValue.increment(1),
                  }
                : {
                    Dbkeys.totalvisitsIOS: FieldValue.increment(1),
                  },
            SetOptions(merge: true));
    await FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(currentUserNo).set(
        Platform.isAndroid
            ? {
                Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
                Dbkeys.notificationStringsMap: getTranslateNotificationStringsMap(this.context),
                Dbkeys.totalvisitsANDROID: FieldValue.increment(1),
              }
            : {
                Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
                Dbkeys.notificationStringsMap: getTranslateNotificationStringsMap(this.context),
                Dbkeys.totalvisitsIOS: FieldValue.increment(1),
              },
        SetOptions(merge: true));
    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(10),
        true);
    await contactsProvider.fetchContacts(context, _cachedModel, myphone, widget.prefs,
        currentuserphoneNumberVariants: phoneNumberVariants);
    //  await statusProvider.searchContactStatus(
    //       myphone, contactsProvider.joinedUserPhoneStringAsInServer);
    statusProvider.triggerDeleteMyExpiredStatus(myphone);
    statusProvider.triggerDeleteOtherUsersExpiredStatus();
    if (_sharedFiles!.length > 0 || _sharedText != null) {
      triggerSharing();
    }
  }

  triggerSharing() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (_sharedText != null) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new SelectContactToShare(
                  prefs: widget.prefs,
                  model: _cachedModel!,
                  currentUserNo: currentUserNo,
                  sharedFiles: _sharedFiles!,
                  sharedText: _sharedText)));
    } else if (_sharedFiles != null) {
      if (_sharedFiles!.length > observer.maxNoOfFilesInMultiSharing) {
        Fiberchat.toast(
            getTranslated(context, 'maxnooffiles') + ' ' + '${observer.maxNoOfFilesInMultiSharing}');
      } else {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new SelectContactToShare(
                    prefs: widget.prefs,
                    model: _cachedModel!,
                    currentUserNo: currentUserNo,
                    sharedFiles: _sharedFiles!,
                    sharedText: _sharedText)));
      }
    }
  }

  listenToSharingintent() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value;
      });
    });
  }

  unsubscribeToNotification(String? userphone) async {
    if (userphone != null) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic('${userphone.replaceFirst(new RegExp(r'\+'), '')}');
    }

    await FirebaseMessaging.instance.unsubscribeFromTopic(Dbkeys.topicUSERS).catchError((err) {
      print(err.toString());
    });
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print(err.toString());
    });
  }

  void registerNotification() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  setdeviceinfo() async {
    if (Platform.isAndroid == true) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        deviceid = androidInfo.id + androidInfo.androidId;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: androidInfo.model,
          Dbkeys.deviceInfoOS: 'android',
          Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: androidInfo.id,
          Dbkeys.deviceInfoOSID: androidInfo.androidId,
          Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
          Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    } else if (Platform.isIOS == true) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: iosInfo.model,
          Dbkeys.deviceInfoOS: 'ios',
          Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
          Dbkeys.deviceInfoOSID: iosInfo.name,
          Dbkeys.deviceInfoOSVERSION: iosInfo.name,
          Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    }
  }

  getuid(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getUserDetails(currentUserNo);
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

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controllers.forEach((controller) {
      controller.close();
    });
    _filter.dispose();
    spokenSubscription?.cancel();
    _userQuery.close();
    cancelUnreadSubscriptions();
    setLastSeen();

    _intentDataStreamSubscription.cancel();
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  void listenToNotification() async {
    //FOR ANDROID  background notification is handled here whereas for iOS it is handled at the very top of main.dart ------
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandlerAndroid);
    }
    //ANDROID & iOS  OnMessage callback
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // ignore: unnecessary_null_comparison
      flutterLocalNotificationsPlugin..cancelAll();

      if (message.data['title'] != 'Call Ended' &&
          message.data['title'] != 'Missed Call' &&
          message.data['title'] != 'You have new message(s)' &&
          message.data['title'] != 'Incoming Video Call...' &&
          message.data['title'] != 'Incoming Audio Call...' &&
          message.data['title'] != 'Incoming Call ended' &&
          message.data['title'] != 'New message in Group') {
        Fiberchat.toast(getTranslated(this.context, 'newnotifications'));
      } else {
        // if (message.data['title'] == 'New message in Group') {
        //   var currentpeer =
        //       Provider.of<CurrentChatPeer>(this.context, listen: false);
        //   if (currentpeer.groupChatId != message.data['groupid']) {
        //     flutterLocalNotificationsPlugin..cancelAll();

        //     showOverlayNotification((context) {
        //       return Card(
        //         margin: const EdgeInsets.symmetric(horizontal: 4),
        //         child: SafeArea(
        //           child: ListTile(
        //             title: Text(
        //               message.data['titleMultilang'],
        //               maxLines: 1,
        //               overflow: TextOverflow.ellipsis,
        //             ),
        //             subtitle: Text(
        //               message.data['bodyMultilang'],
        //               maxLines: 2,
        //               overflow: TextOverflow.ellipsis,
        //             ),
        //             trailing: IconButton(
        //                 icon: Icon(Icons.close),
        //                 onPressed: () {
        //                   OverlaySupportEntry.of(context)!.dismiss();
        //                 }),
        //           ),
        //         ),
        //       );
        //     }, duration: Duration(milliseconds: 2000));
        //   }
        // } else

        if (message.data['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin..cancelAll();
        } else {
          if (message.data['title'] == 'Incoming Audio Call...' ||
              message.data['title'] == 'Incoming Video Call...') {
            final data = message.data;
            final title = data['title'];
            final body = data['body'];
            final titleMultilang = data['titleMultilang'];
            final bodyMultilang = data['bodyMultilang'];
            await _showNotificationWithDefaultSound(title, body, titleMultilang, bodyMultilang);
          } else if (message.data['title'] == 'You have new message(s)') {
            var currentpeer = Provider.of<CurrentChatPeer>(this.context, listen: false);
            if (currentpeer.peerid != message.data['peerid']) {
              // FlutterRingtonePlayer.playNotification();
              showOverlayNotification((context) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: SafeArea(
                    child: ListTile(
                      title: Text(
                        message.data['titleMultilang'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        message.data['bodyMultilang'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            OverlaySupportEntry.of(context)!.dismiss();
                          }),
                    ),
                  ),
                );
              }, duration: Duration(milliseconds: 2000));
            }
          } else {
            showOverlayNotification((context) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: SafeArea(
                  child: ListTile(
                    leading: Image.network(
                      message.data['image'],
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      message.data['titleMultilang'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      message.data['bodyMultilang'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context)!.dismiss();
                        }),
                  ),
                ),
              );
            }, duration: Duration(milliseconds: 2000));
          }
        }
      }
    });
    //ANDROID & iOS  onMessageOpenedApp callback
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      flutterLocalNotificationsPlugin..cancelAll();
      Map<String, dynamic> notificationData = message.data;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        if (notificationData['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin..cancelAll();
        } else if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'You have new message(s)' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'New message in Group') {
          flutterLocalNotificationsPlugin..cancelAll();

          Navigator.push(context, new MaterialPageRoute(builder: (context) => AllNotifications()));
        } else {
          flutterLocalNotificationsPlugin..cancelAll();
        }
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        flutterLocalNotificationsPlugin..cancelAll();
        Map<String, dynamic>? notificationData = message.data;
        if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'You have new message(s)' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'New message in Group') {
          flutterLocalNotificationsPlugin..cancelAll();

          Navigator.push(context, new MaterialPageRoute(builder: (context) => AllNotifications()));
        }
      }
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  Future setupAdminAppCompatibleDataForFirstTime() async {
//  These firestore documents will be automatically in the first run set if Admin app is required but not configured yet. You need to edit all the default settings through admin app-----
    await batchwrite().then((value) async {
      if (value == true) {
        await writeRequiredNewFieldsAllExistingUsers().then((result) async {
          if (result == true) {
            await FirebaseFirestore.instance
                .collection(Dbkeys.appsettings)
                .doc(Dbkeys.userapp)
                .update({Dbkeys.usersidesetupdone: true});

            Fiberchat.showRationale(getTranslated(this.context, 'loadingfailed'));
          } else {
            Fiberchat.showRationale(getTranslated(this.context, 'failedtoconfigure'));
          }
        });
        // ignore: unnecessary_null_comparison
      } else if (value == false || value == null) {
        Fiberchat.showRationale(getTranslated(this.context, 'failedtoconfigure'));
      }
    });
  }

  getSignedInUserOrRedirect() async {
    if (ConnectWithAdminApp == true) {
      await FirebaseFirestore.instance
          .collection(Dbkeys.appsettings)
          .doc(Dbkeys.userapp)
          .get()
          .then((doc) async {
        if (doc.exists && doc.data()!.containsKey(Dbkeys.usersidesetupdone)) {
          if (!doc.data()!.containsKey(Dbkeys.updateV7done)) {
            doc.reference.update({
              Dbkeys.maxNoOfFilesInMultiSharing: MaxNoOfFilesInMultiSharing,
              Dbkeys.maxNoOfContactsSelectForForward: MaxNoOfContactsSelectForForward,
              Dbkeys.appShareMessageStringAndroid: '',
              Dbkeys.appShareMessageStringiOS: '',
              Dbkeys.isCustomAppShareLink: false,
              Dbkeys.updateV7done: true,
            });
            Fiberchat.toast(getTranslated(this.context, 'erroroccured'));
          } else {
            setState(() {
              isblockNewlogins = doc[Dbkeys.isblocknewlogins];
              isApprovalNeededbyAdminForNewUser = doc[Dbkeys.isaccountapprovalbyadminneeded];
              accountApprovalMessage = doc[Dbkeys.accountapprovalmessage];
            });
            if (doc[Dbkeys.isemulatorallowed] == false &&
                mapDeviceInfo[Dbkeys.deviceInfoISPHYSICAL] == false) {
              setState(() {
                isNotAllowEmulator = true;
              });
            } else {
              if (doc[Platform.isAndroid
                      ? Dbkeys.isappunderconstructionandroid
                      : Platform.isIOS
                          ? Dbkeys.isappunderconstructionios
                          : Dbkeys.isappunderconstructionweb] ==
                  true) {
                await unsubscribeToNotification(widget.currentUserNo);
                maintainanceMessage = doc[Dbkeys.maintainancemessage];
                setState(() {});
              } else {
                final PackageInfo info = await PackageInfo.fromPlatform();
                double currentAppVersionInPhone = double.parse(info.version.trim().replaceAll(".", ""));
                double currentNewAppVersionInServer = double.parse(doc[Platform.isAndroid
                        ? Dbkeys.latestappversionandroid
                        : Platform.isIOS
                            ? Dbkeys.latestappversionios
                            : Dbkeys.latestappversionweb]
                    .trim()
                    .replaceAll(".", ""));

                if (currentAppVersionInPhone < currentNewAppVersionInServer) {
                  showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      String title = getTranslated(context, 'updateavl');
                      String message = getTranslated(context, 'updateavlmsg');

                      String btnLabel = getTranslated(context, 'updatnow');

                      return new WillPopScope(
                          onWillPop: () async => false,
                          child: AlertDialog(
                            title: Text(
                              title,
                              style: TextStyle(color: multiboxMainColor),
                            ),
                            content: Text(message),
                            actions: <Widget>[
                              TextButton(
                                  child: Text(
                                    btnLabel,
                                    style: TextStyle(color: fiberchatLightGreen),
                                  ),
                                  onPressed: () => launch(doc[Platform.isAndroid
                                      ? Dbkeys.newapplinkandroid
                                      : Platform.isIOS
                                          ? Dbkeys.newapplinkios
                                          : Dbkeys.newapplinkweb])),
                            ],
                          ));
                    },
                  );
                } else {
                  final observer = Provider.of<Observer>(this.context, listen: false);

                  observer.setObserver(
                    getuserAppSettingsDoc: doc.data(),
                    getandroidapplink: doc[Dbkeys.newapplinkandroid],
                    getiosapplink: doc[Dbkeys.newapplinkios],
                    getismediamessagingallowed: doc[Dbkeys.ismediamessageallowed],
                    getistextmessagingallowed: doc[Dbkeys.istextmessageallowed],
                    getiscallsallowed: doc[Dbkeys.iscallsallowed],
                    gettnc: doc[Dbkeys.tnc],
                    gettncType: doc[Dbkeys.tncTYPE],
                    getprivacypolicy: doc[Dbkeys.privacypolicy],
                    getprivacypolicyType: doc[Dbkeys.privacypolicyTYPE],
                    getis24hrsTimeformat: doc[Dbkeys.is24hrsTimeformat],
                    getmaxFileSizeAllowedInMB: doc[Dbkeys.maxFileSizeAllowedInMB],
                    getisPercentProgressShowWhileUploading:
                        doc[Dbkeys.isPercentProgressShowWhileUploading],
                    getisCallFeatureTotallyHide: doc[Dbkeys.isCallFeatureTotallyHide],
                    getgroupMemberslimit: doc[Dbkeys.groupMemberslimit],
                    getbroadcastMemberslimit: doc[Dbkeys.broadcastMemberslimit],
                    getstatusDeleteAfterInHours: doc[Dbkeys.statusDeleteAfterInHours],
                    getfeedbackEmail: doc[Dbkeys.feedbackEmail],
                    getisLogoutButtonShowInSettingsPage: doc[Dbkeys.isLogoutButtonShowInSettingsPage],
                    getisAllowCreatingGroups: doc[Dbkeys.isAllowCreatingGroups],
                    getisAllowCreatingBroadcasts: doc[Dbkeys.isAllowCreatingBroadcasts],
                    getisAllowCreatingStatus: doc[Dbkeys.isAllowCreatingStatus],
                    getmaxNoOfFilesInMultiSharing: doc[Dbkeys.maxNoOfFilesInMultiSharing],
                    getmaxNoOfContactsSelectForForward: doc[Dbkeys.maxNoOfContactsSelectForForward],
                    getappShareMessageStringAndroid: doc[Dbkeys.appShareMessageStringAndroid],
                    getappShareMessageStringiOS: doc[Dbkeys.appShareMessageStringiOS],
                    getisCustomAppShareLink: doc[Dbkeys.isCustomAppShareLink],
                  );

                  if (currentUserNo == null ||
                      currentUserNo!.isEmpty ||
                      widget.isSecuritySetupDone == false) {
                    await unsubscribeToNotification(widget.currentUserNo);
                    unawaited(Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new PhoneAuth(
                                  prefs: widget.prefs,
                                  accountApprovalMessage: accountApprovalMessage,
                                  isaccountapprovalbyadminneeded: isApprovalNeededbyAdminForNewUser,
                                  isblocknewlogins: isblockNewlogins,
                                  title: getTranslated(context, 'signin'),
                                  issecutitysetupdone: widget.isSecuritySetupDone,
                                ))));
                  } else {
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .doc(widget.currentUserNo ?? currentUserNo)
                        .get()
                        .then((userDoc) async {
                      if (deviceid != userDoc[Dbkeys.currentDeviceID] ||
                          !userDoc.data()!.containsKey(Dbkeys.currentDeviceID)) {
                        if (ConnectWithAdminApp == true) {
                          await unsubscribeToNotification(widget.currentUserNo);
                        }
                        await logout(context);
                      } else {
                        if (!userDoc.data()!.containsKey(Dbkeys.accountstatus)) {
                          await logout(context);
                        } else if (userDoc[Dbkeys.accountstatus] != Dbkeys.sTATUSallowed) {
                          setState(() {
                            accountstatus = userDoc[Dbkeys.accountstatus];
                            accountactionmessage = userDoc[Dbkeys.actionmessage];
                          });
                        } else {
                          getuid(context);
                          setIsActive();
                          String? fcmToken = await FirebaseMessaging.instance.getToken();

                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionusers)
                              .doc(currentUserNo)
                              .set({
                            Dbkeys.notificationTokens: [fcmToken],
                            Dbkeys.deviceDetails: mapDeviceInfo,
                            Dbkeys.currentDeviceID: deviceid,
                            Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                                countrycode: userDoc[Dbkeys.countryCode],
                                phonenumber: userDoc[Dbkeys.phoneRaw])
                          }, SetOptions(merge: true));
                          unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));

                          setState(() {
                            userFullname = userDoc[Dbkeys.nickname];
                            userPhotourl = userDoc[Dbkeys.photoUrl];
                            phoneNumberVariants = phoneNumberVariantsList(
                                countrycode: userDoc[Dbkeys.countryCode],
                                phonenumber: userDoc[Dbkeys.phoneRaw]);
                            isFetching = false;
                          });

                          incrementSessionCount(userDoc[Dbkeys.phone]);
                        }
                      }
                    });
                  }
                }
              }
            }
          }
        } else {
          await setupAdminAppCompatibleDataForFirstTime().then((result) {
            if (result == true) {
              Fiberchat.toast(getTranslated(this.context, 'erroroccured'));
            } else if (result == false) {
              Fiberchat.toast(
                'Error occured while writing setupAdminAppCompatibleDataForFirstTime().Please restart the app.',
              );
            }
          });
        }
      }).catchError((err) {
        Fiberchat.toast(
          'Error occured while fetching appsettings/userapp. ERROR: $err',
        );
      });
    } else {
      await FirebaseFirestore.instance.collection('version').doc('userapp').get().then((doc) async {
        if (doc.exists) {
          if (!doc.data()!.containsKey("profile_set_done")) {
            await FirebaseFirestore.instance.collection(DbPaths.collectionusers).get().then((ds) async {
              // ignore: unnecessary_null_comparison
              if (ds != null) {
                ds.docs.forEach((dc) {
                  if (dc.data().containsKey(Dbkeys.phone) && dc.data().containsKey(Dbkeys.countryCode)) {
                    dc.reference.set({
                      Dbkeys.phoneRaw: dc[Dbkeys.phone].toString().substring(
                          dc[Dbkeys.countryCode].toString().length, dc[Dbkeys.phone].toString().length)
                    }, SetOptions(merge: true));
                  }
                });
              }
            });
            await FirebaseFirestore.instance.collection('version').doc('userapp').set({
              'profile_set_done': true,
            }, SetOptions(merge: true));
          }

          final PackageInfo info = await PackageInfo.fromPlatform();
          double currentAppVersionInPhone = double.parse(info.version.trim().replaceAll(".", ""));
          double currentNewAppVersionInServer = double.parse(doc['version'].trim().replaceAll(".", ""));

          if (currentAppVersionInPhone < currentNewAppVersionInServer) {
            showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                String title = getTranslated(context, 'updateavl');
                String message = getTranslated(context, 'updateavlmsg');

                String btnLabel = getTranslated(context, 'updatnow');
                // String btnLabelCancel = "Later";
                return new WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: Text(
                        title,
                        style: TextStyle(color: multiboxMainColor),
                      ),
                      content: Text(message),
                      actions: <Widget>[
                        // ignore: deprecated_member_use
                        FlatButton(
                          child: Text(
                            btnLabel,
                            style: TextStyle(color: fiberchatLightGreen),
                          ),
                          onPressed: () =>
                              Platform.isAndroid ? launch(doc['url']) : launch(RateAppUrlIOS),
                        ),
                      ],
                    ));
              },
            );
          } else {
            if (currentUserNo == null ||
                currentUserNo!.isEmpty ||
                widget.isSecuritySetupDone == false ||
                // ignore: unnecessary_null_comparison
                widget.isSecuritySetupDone == null)
              unawaited(Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new PhoneAuth(
                            prefs: widget.prefs,
                            accountApprovalMessage: accountApprovalMessage,
                            isaccountapprovalbyadminneeded: isApprovalNeededbyAdminForNewUser,
                            isblocknewlogins: isblockNewlogins,
                            title: getTranslated(context, 'signin'),
                            issecutitysetupdone: widget.isSecuritySetupDone,
                          ))));
            else {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(currentUserNo)
                  .get()
                  .then((userDoc) async {
                // ignore: unnecessary_null_comparison
                if (userDoc != null) {
                  if (deviceid != userDoc[Dbkeys.currentDeviceID] ||
                      !userDoc.data()!.containsKey(Dbkeys.currentDeviceID)) {
                    await logout(context);
                  } else {
                    getuid(context);
                    setIsActive();
                    String? fcmToken = await FirebaseMessaging.instance.getToken();

                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .doc(currentUserNo)
                        .set({
                      Dbkeys.notificationTokens: [fcmToken],
                      Dbkeys.deviceDetails: mapDeviceInfo,
                      Dbkeys.currentDeviceID: deviceid,
                    }, SetOptions(merge: true));
                    unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
                  }
                }
              });
            }
          }
        } else {
          await FirebaseFirestore.instance
              .collection('version')
              .doc('userapp')
              .set({'version': '1.0.0', 'url': 'https://www.google.com/'}, SetOptions(merge: true));
          Fiberchat.toast(
            getTranslated(context, 'setup'),
          );
        }
      }).catchError((err) {
        print('FETCHING ERROR AT INITIAL STARTUP: $err');
        Fiberchat.toast(
          getTranslated(context, 'loadingfailed') + err.toString(),
        );
      });
    }
  }

  String? currentUserNo;

  StreamController<String> _userQuery = new StreamController<String>.broadcast();

  DateTime? currentBackPressTime = DateTime.now();
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime!) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fiberchat.toast('Double Tap To Go Back');
      return Future.value(false);
    } else {
      if (!isAuthenticating) setLastSeen();
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final observer = Provider.of<Observer>(context, listen: true);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return isNotAllowEmulator == true
        ? errorScreen('Emulator Not Allowed.', ' Please use any real device & Try again.')
        : accountstatus != null
            ? errorScreen(accountstatus, accountactionmessage)
            : ConnectWithAdminApp == true && maintainanceMessage != null
                ? errorScreen('App Under maintainance', maintainanceMessage)
                : ConnectWithAdminApp == true && isFetching == true
                    ? Splashscreen()
                    : PickupLayout(
                        scaffold: Fiberchat.getNTPWrappedWidget(
                          WillPopScope(
                            onWillPop: onWillPop,
                            child: SafeArea(
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
                                                            image:
                                                                AssetImage('assets/images/app_icon.png'),
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(
                                                      flex: 2,
                                                    ),
                                                    SizedBox(
                                                      height: 28,
                                                      width: 28,
                                                      child: XDComponent5301(),
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
                                                            prefs: widget.prefs,
                                                            isSecuritySetupDone:
                                                                widget.isSecuritySetupDone,
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
                                                    PageLink(
                                                      links: [
                                                        PageLinkInfo(
                                                          transition: LinkTransition.Fade,
                                                          ease: Curves.easeOut,
                                                          duration: 0.3,

                                                          // pageBuilder: () => XDMainpageLocation(),
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
                                                                    if (observer.isAllowCreatingGroups ==
                                                                        false) {
                                                                      Fiberchat.showRationale(
                                                                          getTranslated(
                                                                              this.context, 'disabled'));
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
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                VpnSetup()));
                                                                  },
                                                                  child: Text(
                                                                    "VPN",
                                                                    style: TextStyle(
                                                                      color: Colors.grey[700],
                                                                    ),
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
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                                  vertical: 5),
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
                                                    child: RecentChats(
                                                      prefs: widget.prefs,
                                                      currentUserNo: widget.currentUserNo,
                                                      isSecuritySetupDone: widget.isSecuritySetupDone,
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
                                        Pin(size: 56.0, middle: 0.6733),
                                        child: PageLink(
                                          links: [
                                            PageLinkInfo(
                                              transition: LinkTransition.Fade,
                                              ease: Curves.easeOut,
                                              duration: 0.3,
                                              pageBuilder: () => CallHistory(
                                                userphone: widget.currentUserNo,
                                                prefs: widget.prefs,
                                              ),
                                            ),
                                          ],
                                          child: XDComponent5231(),
                                        ),
                                      ),
                                      Pinned.fromPins(
                                        Pin(size: 56.0, end: 17.0),
                                        Pin(size: 56.0, end: 98.0),
                                        child: InkWell(
                                          onTap: () => Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) => new SmartContactsPage(
                                                      onTapCreateGroup: () {
                                                        if (observer.isAllowCreatingGroups == false) {
                                                          Fiberchat.showRationale(
                                                              getTranslated(this.context, 'disabled'));
                                                        } else {
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      AddContactsToGroup(
                                                                        currentUserNo:
                                                                            widget.currentUserNo,
                                                                        model: _cachedModel,
                                                                        biometricEnabled: false,
                                                                        prefs: widget.prefs,
                                                                        isAddingWhileCreatingGroup: true,
                                                                      )));
                                                        }
                                                      },
                                                      prefs: widget.prefs,
                                                      biometricEnabled: biometricEnabled,
                                                      currentUserNo: currentUserNo!,
                                                      model: _cachedModel!))),
                                          child: XDComponent5251(),
                                        ),
                                      ),
                                      Pinned.fromPins(
                                        Pin(size: 56.0, end: 17.0),
                                        Pin(size: 56.0, middle: 0.7725),
                                        child: PageLink(
                                          links: [
                                            PageLinkInfo(
                                              transition: LinkTransition.Fade,
                                              ease: Curves.easeOut,
                                              duration: 0.3,
                                              pageBuilder: () => Status(
                                                  currentUserFullname: userFullname,
                                                  currentUserPhotourl: userPhotourl,
                                                  phoneNumberVariants: this.phoneNumberVariants,
                                                  currentUserNo: currentUserNo,
                                                  model: _cachedModel,
                                                  biometricEnabled: biometricEnabled,
                                                  prefs: widget.prefs),
                                            ),
                                          ],
                                          child: const XDComponent5241(),
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
                                              pageBuilder: () => XDSafeBOX(),
                                            ),
                                          ],
                                          child: XDComponent5253(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
  }
}

Future<dynamic> myBackgroundMessageHandlerAndroid(RemoteMessage message) async {
  if (message.data['title'] == 'Call Ended' || message.data['title'] == 'Missed Call') {
    flutterLocalNotificationsPlugin..cancelAll();
    final data = message.data;
    final titleMultilang = data['titleMultilang'];
    final bodyMultilang = data['bodyMultilang'];

    await _showNotificationWithDefaultSound(
        'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
  } else {
    if (message.data['title'] == 'You have new message(s)' ||
        message.data['title'] == 'New message in Group') {
      //-- need not to do anythig for these message type as it will be automatically popped up.

    } else if (message.data['title'] == 'Incoming Audio Call...' ||
        message.data['title'] == 'Incoming Video Call...') {
      final data = message.data;
      final title = data['title'];
      final body = data['body'];
      final titleMultilang = data['titleMultilang'];
      final bodyMultilang = data['bodyMultilang'];

      await _showNotificationWithDefaultSound(title, body, titleMultilang, bodyMultilang);
    }
  }

  return Future<void>.value();
}

// Future<dynamic> myBackgroundMessageHandlerIos(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (message.data['title'] == 'Call Ended') {
//     final data = message.data;

//     final titleMultilang = data['titleMultilang'];
//     final bodyMultilang = data['bodyMultilang'];
//     flutterLocalNotificationsPlugin..cancelAll();
//     await _showNotificationWithDefaultSound(
//         'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
//   } else {
//     if (message.data['title'] == 'You have new message(s)') {
//     } else if (message.data['title'] == 'Incoming Audio Call...' ||
//         message.data['title'] == 'Incoming Video Call...') {
//       final data = message.data;
//       final title = data['title'];
//       final body = data['body'];
//       final titleMultilang = data['titleMultilang'];
//       final bodyMultilang = data['bodyMultilang'];
//       await _showNotificationWithDefaultSound(
//           title, body, titleMultilang, bodyMultilang);
//     }
//   }

//   return Future<void>.value();
// }

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future _showNotificationWithDefaultSound(
    String? title, String? message, String? titleMultilang, String? bodyMultilang) async {
  if (Platform.isAndroid) {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var androidPlatformChannelSpecifics = title == 'Missed Call' || title == 'Call Ended'
      ? local.AndroidNotificationDetails('channel_id', 'channel_name', 'channel_description',
          importance: local.Importance.max,
          priority: local.Priority.high,
          sound: RawResourceAndroidNotificationSound('whistle2'),
          playSound: true,
          ongoing: true,
          visibility: NotificationVisibility.public,
          timeoutAfter: 28000)
      : local.AndroidNotificationDetails('channel_id', 'channel_name', 'channel_description',
          sound: RawResourceAndroidNotificationSound('ringtone'),
          playSound: true,
          ongoing: true,
          importance: local.Importance.max,
          priority: local.Priority.high,
          visibility: NotificationVisibility.public,
          timeoutAfter: 28000);
  var iOSPlatformChannelSpecifics = local.IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    sound: title == 'Missed Call' || title == 'Call Ended' ? '' : 'ringtone.caf',
    presentSound: true,
  );
  var platformChannelSpecifics = local.NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(
    0,
    '$titleMultilang',
    '$bodyMultilang',
    platformChannelSpecifics,
    payload: 'payload',
  )
      .catchError((err) {
    print('ERROR DISPLAYING NOTIFICATION: $err');
  });
}

Widget errorScreen(String? title, String? subtitle) {
  return Scaffold(
    backgroundColor: multiboxMainColor,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              size: 60,
              color: Colors.yellowAccent,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              '$title',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: fiberchatWhite, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '$subtitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17, color: fiberchatWhite.withOpacity(0.7), fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    ),
  );
}
