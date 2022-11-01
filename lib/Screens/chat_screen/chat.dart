// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adobe_xd/page_link.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/chat_screen/Widget/bubble.dart';
import 'package:fiberchat/Screens/chat_screen/utils/audioPlayback.dart';
import 'package:fiberchat/Screens/chat_screen/utils/deleteChatMedia.dart';
import 'package:fiberchat/Screens/chat_screen/utils/downloadMedia.dart';
import 'package:fiberchat/Screens/chat_screen/utils/message.dart';
import 'package:fiberchat/Screens/chat_screen/utils/photo_view.dart';
import 'package:fiberchat/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat/Screens/contact_screens/ContactsSelect.dart';
import 'package:fiberchat/Screens/contact_screens/SelectContactsToForward.dart';
import 'package:fiberchat/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:fiberchat/Screens/profile_settings/profile_view.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat/Services/Providers/seen_provider.dart';
import 'package:fiberchat/Services/Providers/seen_state.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/call_utilities.dart';
import 'package:fiberchat/Utils/chat_controller.dart';
import 'package:fiberchat/Utils/crc.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/permissions.dart';
import 'package:fiberchat/Utils/save.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/AudioRecorder/Audiorecord.dart';
import 'package:fiberchat/widgets/CountryPicker/CountryCode.dart';
import 'package:fiberchat/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:fiberchat/widgets/MultiImagePicker/multiImagePicker.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:fiberchat/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:fiberchat/widgets/VideoPicker/VideoPicker.dart';
import 'package:fiberchat/widgets/VideoPicker/VideoPreview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../widgets/componentss/xd_component5321.dart';
import '../settings/settings.dart';

hidekeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

class ChatScreen extends StatefulWidget {
  final String? peerNo, currentUserNo;
  final DataModel model;
  final int unread;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  ChatScreen({
    Key? key,
    required this.currentUserNo,
    required this.peerNo,
    required this.model,
    required this.prefs,
    required this.unread,
    required this.isSharingIntentForwarded,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  });

  @override
  State createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  bool isReplyKeyboard = false;

  Map<String, dynamic>? replyDoc;
  String? peerAvatar, peerNo, currentUserNo, privateKey, sharedSecret;
  late bool locked, hidden;
  Map<String, dynamic>? peer, currentUser;
  int? chatStatus, unread;
  GlobalKey<State> _keyLoader = new GlobalKey<State>(debugLabel: 'qqqeqeqsseaadsqeqe');

  String? chatId;
  bool isMessageLoading = true;
  bool typing = false;
  late File thumbnailFile;
  File? pickedFile;
  bool isLoading = true;
  bool isgeneratingSomethingLoader = false;
  int tempSendIndex = 0;
  String? imageUrl;
  SeenState? seenState;
  List<Message> messages = new List.from(<Message>[]);
  List<Map<String, dynamic>> _savedMessageDocs = new List.from(<Map<String, dynamic>>[]);

  int? uploadTimestamp;

  StreamSubscription? seenSubscription, msgSubscription, deleteUptoSubscription;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController realtime = new ScrollController();
  final ScrollController saved = new ScrollController();
  late DataModel _cachedModel;

  Duration? duration;
  Duration? position;

  // AudioPlayer audioPlayer = AudioPlayer();

  String? localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText => duration != null ? duration.toString().split('.').first : '';

  get positionText => position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    _cachedModel = widget.model;
    peerNo = widget.peerNo;
    currentUserNo = widget.currentUserNo;
    unread = widget.unread;
    // initAudioPlayer();
    // _load();
    Fiberchat.internetLookUp();

    updateLocalUserData(_cachedModel);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var currentpeer = Provider.of<CurrentChatPeer>(this.context, listen: false);
      currentpeer.setpeer(newpeerid: widget.peerNo);
      seenState = new SeenState(false);
      WidgetsBinding.instance.addObserver(this);
      chatId = '';
      unread = widget.unread;
      isLoading = false;
      imageUrl = '';
      loadSavedMessages();
      readLocal(this.context);
    });
  }

  updateLocalUserData(model) {
    peer = model.userData[peerNo];
    currentUser = _cachedModel.currentUser;
    if (currentUser != null && peer != null) {
      hidden = currentUser![Dbkeys.hidden] != null && currentUser![Dbkeys.hidden].contains(peerNo);
      locked = currentUser![Dbkeys.locked] != null && currentUser![Dbkeys.locked].contains(peerNo);
      chatStatus = peer![Dbkeys.chatStatus];
      peerAvatar = peer![Dbkeys.photoUrl];
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen();
    // audioPlayer.stop();
    msgSubscription?.cancel();
    seenSubscription?.cancel();
    deleteUptoSubscription?.cancel();
  }

  void setLastSeen() async {
    if (chatStatus != ChatStatus.blocked.index) {
      if (chatId != null) {
        await FirebaseFirestore.instance.collection(DbPaths.collectionmessages).doc(chatId).update(
          {'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
        );
      }
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Fiberchat.toast(
        getTranslated(this.context, 'waitingpeer'),
      );
      return false;
    }
  }

  String decryptWithCRC(String input) {
    try {
      if (input.contains(Dbkeys.crcSeperator)) {
        int idx = input.lastIndexOf(Dbkeys.crcSeperator);
        String msgPart = input.substring(0, idx);
        String crcPart = input.substring(idx + 1);
        int? crc = int.tryParse(crcPart);
        if (crc != null) {
          msgPart = cryptor.decrypt(encrypt.Encrypted.fromBase64(msgPart), iv: iv);
          if (CRC32.compute(msgPart) == crc) return msgPart;
        }
      }
    } on FormatException {
      Fiberchat.toast(getTranslated(this.context, 'msgnotload'));
      return '';
    }
    Fiberchat.toast(getTranslated(this.context, 'msgnotload'));
    return '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .set({'$currentUserNo': true}, SetOptions(merge: true));
  }

  dynamic lastSeen;

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  readLocal(
    BuildContext context,
  ) async {
    try {
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await e2ee.X25519().calculateSharedSecret(e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(peer![Dbkeys.publicKey], true)))
          .toBase64();
      final key = encrypt.Key.fromBase64(sharedSecret!);
      cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
    } catch (e) {
      sharedSecret = null;
    }
    try {
      seenState!.value = widget.prefs.getInt(getLastSeenKey());
    } catch (e) {
      seenState!.value = false;
    }
    chatId = Fiberchat.getChatId(currentUserNo, peerNo);
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty && typing == false) {
        lastSeen = peerNo;
        FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(currentUserNo).update(
          {Dbkeys.lastSeen: peerNo},
        );
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        lastSeen = true;
        FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(currentUserNo).update(
          {Dbkeys.lastSeen: true},
        );
        typing = false;
      }
    });
    setIsActive();
    seenSubscription = FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      // ignore: unnecessary_null_comparison
      if (doc != null && mounted && doc.data()!.containsKey(peerNo)) {
        seenState!.value = doc[peerNo!] ?? false;
        if (seenState!.value is int) {
          widget.prefs.setInt(getLastSeenKey(), seenState!.value);
        }
      }
    });
    loadMessagesAndListen();
  }

  String getLastSeenKey() {
    return "$peerNo-${Dbkeys.lastSeen}";
  }

  int? thumnailtimestamp;
  getFileData(File image, {int? timestamp, int? totalFiles}) {
    final observer = Provider.of<Observer>(this.context, listen: false);

    setStateIfMounted(() {
      pickedFile = image;
    });

    return observer.isPercentProgressShowWhileUploading
        ? (totalFiles == null
            ? uploadFileWithProgressIndicator(
                false,
                timestamp: timestamp,
              )
            : totalFiles == 1
                ? uploadFileWithProgressIndicator(
                    false,
                    timestamp: timestamp,
                  )
                : uploadFile(false, timestamp: timestamp))
        : uploadFile(false, timestamp: timestamp);
  }

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });

    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 30);

    thumbnailFile = File(path!);

    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });

    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  getWallpaper(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      _cachedModel.setWallpaper(peerNo, image);
    }
    return Future.value(false);
  }

  String? videometadata;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        currentUserNo, isthumbnail == false ? '$uploadTimestamp' : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    TaskSnapshot uploading = await reference.putFile(isthumbnail == true ? thumbnailFile : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Fiberchat.toast('Sending failed !');
        print('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(widget.currentUserNo).set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance.collection(DbPaths.collectiondashboard).doc(DbPaths.docchatdata).set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    return uploading.ref.getDownloadURL();
  }

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

    String fileName = getFileName(
        currentUserNo, isthumbnail == false ? '$uploadTimestamp' : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    UploadTask uploading = reference.putFile(isthumbnail == true ? thumbnailFile : pickedFile!);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // side: BorderSide(width: 5, color: Colors.green)),
                  key: _keyLoader,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslated(context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslated(context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Fiberchat.toast('Sending failed !');
        print('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance.collection(DbPaths.collectionusers).doc(widget.currentUserNo).set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance.collection(DbPaths.collectiondashboard).doc(DbPaths.docchatdata).set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Fiberchat.toast(
          'Location permissions are pdenied. Please go to settings & allow location tracking permission.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        Fiberchat.toast(
            'Location permissions are pdenied. Please go to settings & allow location tracking permission.');
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Fiberchat.toast(
            'Location permissions are pdenied. Please go to settings & allow location tracking permission.');
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Fiberchat.toast(
        getTranslated(this.context, 'detectingloc'),
      );
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void onSendMessage(BuildContext context, String content, MessageType type, int? timestamp,
      {bool isForward = false}) async {
    if (content.trim() != '') {
      try {
        content = content.trim();
        if (chatStatus == null || chatStatus == 4) ChatController.request(currentUserNo, peerNo, chatId);
        textEditingController.clear();
        final encrypted = encryptWithCRC(content);
        if (encrypted is String) {
          Future messaging = FirebaseFirestore.instance
              .collection(DbPaths.collectionmessages)
              .doc(chatId)
              .collection(chatId!)
              .doc('$timestamp')
              .set({
            Dbkeys.from: currentUserNo,
            Dbkeys.to: peerNo,
            Dbkeys.timestamp: timestamp,
            Dbkeys.content: encrypted,
            Dbkeys.messageType: type.index,
            Dbkeys.hasSenderDeleted: false,
            Dbkeys.hasRecipientDeleted: false,
            Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
            Dbkeys.isReply: isReplyKeyboard,
            Dbkeys.replyToMsgDoc: replyDoc,
            Dbkeys.isForward: isForward
          }, SetOptions(merge: true));

          _cachedModel.addMessage(peerNo, timestamp, messaging);
          var tempDoc = {
            Dbkeys.timestamp: timestamp,
            Dbkeys.to: peerNo,
            Dbkeys.messageType: type.index,
            Dbkeys.content: content,
            Dbkeys.from: currentUserNo,
            Dbkeys.hasSenderDeleted: false,
            Dbkeys.hasRecipientDeleted: false,
            Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
            Dbkeys.isReply: isReplyKeyboard,
            Dbkeys.replyToMsgDoc: replyDoc,
            Dbkeys.isForward: isForward
          };

          setStateIfMounted(() {
            isReplyKeyboard = false;
            replyDoc = null;
            messages = List.from(messages)
              ..add(Message(
                buildTempMessage(context, type, content, timestamp, messaging, tempDoc),
                onTap: (tempDoc[Dbkeys.from] == widget.currentUserNo &&
                            tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                        true
                    ? () {}
                    : type == MessageType.image
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoViewWrapper(
                                    message: content,
                                    tag: timestamp.toString(),
                                    imageProvider: CachedNetworkImageProvider(content),
                                  ),
                                ));
                          }
                        : null,
                onDismiss: tempDoc[Dbkeys.content] == '' || tempDoc[Dbkeys.content] == null
                    ? () {}
                    : () {
                        setStateIfMounted(() {
                          isReplyKeyboard = true;
                          replyDoc = tempDoc;
                        });
                        HapticFeedback.heavyImpact();
                        keyboardFocusNode.requestFocus();
                      },
                onDoubleTap: () {
                  // save(tempDoc);
                },
                onLongPress: () {
                  if (tempDoc.containsKey(Dbkeys.hasRecipientDeleted) &&
                      tempDoc.containsKey(Dbkeys.hasSenderDeleted)) {
                    if ((tempDoc[Dbkeys.from] == widget.currentUserNo &&
                            tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                        false) {
                      //--Show Menu only if message is not deleted by current user already
                      contextMenuNew(this.context, tempDoc, true);
                    }
                  } else {
                    contextMenuOld(context, tempDoc);
                  }
                },
                from: currentUserNo,
                timestamp: timestamp,
              ));
          });

          unawaited(
              realtime.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut));

          // _playPopSound();
        } else {
          Fiberchat.toast('Nothing to encrypt');
        }
      } on Exception catch (_) {
        print('Exception caught!');
      }
    }
  }

  delete(int? ts) {
    setStateIfMounted(() {
      messages.removeWhere((msg) => msg.timestamp == ts);
      messages = List.from(messages);
    });
  }

  updateDeleteBySenderField(int? ts, updateDoc, context) {
    setStateIfMounted(() {
      int i = messages.indexWhere((msg) => msg.timestamp == ts);
      var child = buildTempMessage(context, MessageType.text, updateDoc[Dbkeys.content],
          updateDoc[Dbkeys.timestamp], true, updateDoc);
      var timestamp = messages[i].timestamp;
      var from = messages[i].from;
      // var onTap = messages[i].onTap;
      var onDoubleTap = messages[i].onDoubleTap;
      var onDismiss = messages[i].onDismiss;
      var onLongPress = () {};
      if (i >= 0) {
        messages.removeWhere((msg) => msg.timestamp == ts);
        messages.insert(
            i,
            Message(child,
                timestamp: timestamp,
                from: from,
                onTap: () {},
                onDoubleTap: onDoubleTap,
                onDismiss: onDismiss,
                onLongPress: onLongPress));
      }
      messages = List.from(messages);
    });
  }

  contextMenuForSavedMessage(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    List<Widget> tiles = List.from(<Widget>[]);
    tiles.add(ListTile(
        dense: true,
        leading: Icon(Icons.delete_outline),
        title: Text(
          getTranslated(this.context, 'delete'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          Save.deleteMessage(peerNo, doc);
          _savedMessageDocs.removeWhere((msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
          setStateIfMounted(() {
            _savedMessageDocs = List.from(_savedMessageDocs);
          });
          Navigator.pop(context);
        }));
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  //-- New context menu with Delete for Me & Delete For Everyone feature
  contextMenuNew(contextForDialog, Map<String, dynamic> mssgDoc, bool isTemp, {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    //####################----------------------- Delete Msgs for SENDER ---------------------------------------------------
    if ((mssgDoc[Dbkeys.from] == currentUserNo && mssgDoc[Dbkeys.hasSenderDeleted] == false) &&
        saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete_outline),
          title: Text(
            getTranslated(contextForDialog, 'dltforme'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            Fiberchat.toast(getTranslated(contextForDialog, 'deleting'));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('${mssgDoc[Dbkeys.timestamp]}')
                .get()
                .then((chatDoc) async {
              if (!chatDoc.exists) {
                Fiberchat.toast('Please reload this screen !');
              } else if (chatDoc.exists) {
                Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                if (realtimeDoc[Dbkeys.hasRecipientDeleted] == true) {
                  if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                          ? mssgDoc[Dbkeys.isbroadcast]
                          : false) ==
                      true) {
                    // -------Delete broadcast message completely as recipient has already deleted
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionmessages)
                        .doc(chatId)
                        .collection(chatId!)
                        .doc('${realtimeDoc[Dbkeys.timestamp]}')
                        .delete();
                    delete(realtimeDoc[Dbkeys.timestamp]);
                    Save.deleteMessage(peerNo, realtimeDoc);
                    _savedMessageDocs
                        .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                    setStateIfMounted(() {
                      _savedMessageDocs = List.from(_savedMessageDocs);
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.maybePop(
                        contextForDialog,
                      );
                      Fiberchat.toast(
                        getTranslated(contextForDialog, 'deleted'),
                      );
                      hidekeyboard(
                        contextForDialog,
                      );
                    });
                  } else {
                    // -------Delete message completely as recipient has already deleted
                    await deleteMsgMedia(realtimeDoc, chatId!).then((isDeleted) async {
                      if (isDeleted == false || isDeleted == null) {
                        Fiberchat.toast('Could not delete. Please try again!');
                      } else {
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs
                            .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Navigator.maybePop(
                            contextForDialog,
                          );
                          Fiberchat.toast(
                            getTranslated(contextForDialog, 'deleted'),
                          );
                          hidekeyboard(contextForDialog);
                        });
                      }
                    });
                  }
                } else {
                  //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                  FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId!)
                      .doc('${realtimeDoc[Dbkeys.timestamp]}')
                      .set({Dbkeys.hasSenderDeleted: true}, SetOptions(merge: true));

                  Save.deleteMessage(peerNo, mssgDoc);
                  _savedMessageDocs
                      .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                  setStateIfMounted(() {
                    _savedMessageDocs = List.from(_savedMessageDocs);
                  });

                  Map<String, dynamic> tempDoc = realtimeDoc;
                  setStateIfMounted(() {
                    tempDoc[Dbkeys.hasSenderDeleted] = true;
                  });
                  updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp], tempDoc, contextForDialog);

                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.maybePop(contextForDialog);
                    Fiberchat.toast(
                      getTranslated(contextForDialog, 'deleted'),
                    );
                    hidekeyboard(contextForDialog);
                  });
                }
              }
            });
          }));

      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete),
          title: Text(
            getTranslated(contextForDialog, 'dltforeveryone'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                    ? mssgDoc[Dbkeys.isbroadcast]
                    : false) ==
                true) {
              // -------Delete broadcast message completely for everyone
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .collection(chatId!)
                  .doc('${mssgDoc[Dbkeys.timestamp]}')
                  .delete();
              delete(mssgDoc[Dbkeys.timestamp]);
              Save.deleteMessage(peerNo, mssgDoc);
              _savedMessageDocs.removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
              setStateIfMounted(() {
                _savedMessageDocs = List.from(_savedMessageDocs);
              });
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.maybePop(contextForDialog);
                Fiberchat.toast(
                  getTranslated(contextForDialog, 'deleted'),
                );
                hidekeyboard(contextForDialog);
              });
            } else {
              // -------Delete message completely for everyone
              Fiberchat.toast(
                getTranslated(contextForDialog, 'deleting'),
              );
              await deleteMsgMedia(mssgDoc, chatId!).then((isDeleted) async {
                if (isDeleted == false || isDeleted == null) {
                  Fiberchat.toast('Could not delete. Please try again!');
                } else {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId!)
                      .doc('${mssgDoc[Dbkeys.timestamp]}')
                      .delete();
                  delete(mssgDoc[Dbkeys.timestamp]);
                  Save.deleteMessage(peerNo, mssgDoc);
                  _savedMessageDocs
                      .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                  setStateIfMounted(() {
                    _savedMessageDocs = List.from(_savedMessageDocs);
                  });
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.maybePop(contextForDialog);
                    Fiberchat.toast(
                      getTranslated(contextForDialog, 'deleted'),
                    );
                    hidekeyboard(contextForDialog);
                  });
                }
              });
            }
          }));
    }
    //####################-------------------- Delete Msgs for RECIPIENTS---------------------------------------------------
    if ((mssgDoc[Dbkeys.to] == currentUserNo && mssgDoc[Dbkeys.hasRecipientDeleted] == false) &&
        saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete_outline),
          title: Text(
            getTranslated(contextForDialog, 'dltforme'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            Fiberchat.toast(
              getTranslated(contextForDialog, 'deleting'),
            );
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('${mssgDoc[Dbkeys.timestamp]}')
                .get()
                .then((chatDoc) async {
              if (!chatDoc.exists) {
                Fiberchat.toast('Please reload this screen !');
              } else if (chatDoc.exists) {
                Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                if (realtimeDoc[Dbkeys.hasSenderDeleted] == true) {
                  if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                          ? mssgDoc[Dbkeys.isbroadcast]
                          : false) ==
                      true) {
                    // -------Delete broadcast message completely as sender has already deleted
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionmessages)
                        .doc(chatId)
                        .collection(chatId!)
                        .doc('${realtimeDoc[Dbkeys.timestamp]}')
                        .delete();
                    delete(realtimeDoc[Dbkeys.timestamp]);
                    Save.deleteMessage(peerNo, realtimeDoc);
                    _savedMessageDocs
                        .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                    setStateIfMounted(() {
                      _savedMessageDocs = List.from(_savedMessageDocs);
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.maybePop(contextForDialog);
                      Fiberchat.toast(
                        getTranslated(contextForDialog, 'deleted'),
                      );
                      hidekeyboard(contextForDialog);
                    });
                  } else {
                    // -------Delete message completely as sender has already deleted
                    await deleteMsgMedia(realtimeDoc, chatId!).then((isDeleted) async {
                      if (isDeleted == false || isDeleted == null) {
                        Fiberchat.toast('Could not delete. Please try again!');
                      } else {
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs
                            .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Navigator.maybePop(contextForDialog);
                          Fiberchat.toast(
                            getTranslated(contextForDialog, 'deleted'),
                          );
                          hidekeyboard(contextForDialog);
                        });
                      }
                    });
                  }
                } else {
                  //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                  FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId!)
                      .doc('${realtimeDoc[Dbkeys.timestamp]}')
                      .set({Dbkeys.hasRecipientDeleted: true}, SetOptions(merge: true));

                  Save.deleteMessage(peerNo, mssgDoc);
                  _savedMessageDocs
                      .removeWhere((msg) => msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                  setStateIfMounted(() {
                    _savedMessageDocs = List.from(_savedMessageDocs);
                  });
                  if (isTemp == true) {
                    Map<String, dynamic> tempDoc = realtimeDoc;
                    setStateIfMounted(() {
                      tempDoc[Dbkeys.hasRecipientDeleted] = true;
                    });
                    updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp], tempDoc, contextForDialog);
                  }
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.maybePop(contextForDialog);
                    Fiberchat.toast(
                      getTranslated(contextForDialog, 'deleted'),
                    );
                    hidekeyboard(contextForDialog);
                  });
                }
              }
            });
          }));
    }
    if (mssgDoc.containsKey(Dbkeys.broadcastID) && mssgDoc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.block),
          title: Text(
            getTranslated(contextForDialog, 'blockbroadcast'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Fiberchat.toast(
              getTranslated(contextForDialog, 'plswait'),
            );
            Future.delayed(const Duration(milliseconds: 200), () {
              FirebaseFirestore.instance
                  .collection(DbPaths.collectionbroadcasts)
                  .doc(mssgDoc[Dbkeys.broadcastID])
                  .update({
                Dbkeys.broadcastMEMBERSLIST: FieldValue.arrayRemove([widget.currentUserNo]),
                Dbkeys.broadcastBLACKLISTED: FieldValue.arrayUnion([widget.currentUserNo]),
              }).then((value) {
                Navigator.pop(contextForDialog);
                hidekeyboard(contextForDialog);
                Fiberchat.toast(
                  getTranslated(contextForDialog, 'blockedbroadcast'),
                );
              }).catchError((error) {
                Navigator.pop(contextForDialog);

                hidekeyboard(contextForDialog);
              });
            });
          }));
    }

    //####################--------------------- ALL BELOW DIALOG TILES FOR COMMON SENDER & RECIPIENT-------------------------###########################------------------------------
    // if (((mssgDoc[Dbkeys.from] == currentUserNo &&
    //             mssgDoc[Dbkeys.hasSenderDeleted] == false) ||
    //         (mssgDoc[Dbkeys.to] == currentUserNo &&
    //             mssgDoc[Dbkeys.hasRecipientDeleted] == false)) &&
    //     saved == false) {
    //   tiles.add(ListTile(
    //       dense: true,
    //       leading: Icon(Icons.save_outlined),
    //       title: Text(
    //         getTranslated(contextForDialog, 'save'),
    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //       ),
    //       onTap: () {
    //         save(mssgDoc);
    //         hidekeyboard(contextForDialog);
    //         Navigator.pop(contextForDialog);
    //       }));
    // }
    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index &&
        !mssgDoc.containsKey(Dbkeys.broadcastID)) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.content_copy),
          title: Text(
            getTranslated(contextForDialog, 'copy'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: mssgDoc[Dbkeys.content]));
            Navigator.pop(contextForDialog);
            hidekeyboard(contextForDialog);
            Fiberchat.toast(
              getTranslated(contextForDialog, 'copied'),
            );
          }));
    }
    if (((mssgDoc[Dbkeys.from] == currentUserNo && mssgDoc[Dbkeys.hasSenderDeleted] == false) ||
            (mssgDoc[Dbkeys.to] == currentUserNo && mssgDoc[Dbkeys.hasRecipientDeleted] == false)) ==
        true) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.share, size: 22),
          title: Text(
            getTranslated(contextForDialog, 'forward'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            Navigator.of(contextForDialog).pop();
            Navigator.push(
                contextForDialog,
                MaterialPageRoute(
                    builder: (contextForDialog) => SelectContactsToForward(
                        messageOwnerPhone: widget.peerNo!,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model,
                        prefs: widget.prefs,
                        onSelect: (selectedlist) async {
                          if (selectedlist.length > 0) {
                            setStateIfMounted(() {
                              isgeneratingSomethingLoader = true;
                              tempSendIndex = 0;
                            });

                            String? privateKey = await storage.read(key: Dbkeys.privateKey);

                            sendForwardMessageEach(0, selectedlist, privateKey!, mssgDoc);
                          }
                        })));
          }));
    }

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  sendForwardMessageEach(
      int index, List<DocumentSnapshot<dynamic>> list, String privateKey, var mssgDoc) async {
    if (index > list.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
        Navigator.of(this.context).pop();
      });
    } else {
      setStateIfMounted(() {
        tempSendIndex = index;
      });
      if (list[index].data()!.containsKey(Dbkeys.groupNAME)) {
        try {
          Map<dynamic, dynamic> groupDoc = list[tempSendIndex].data();
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          FirebaseFirestore.instance
              .collection(DbPaths.collectiongroups)
              .doc(groupDoc[Dbkeys.groupID])
              .collection(DbPaths.collectiongroupChats)
              .doc(timestamp.toString() + '--' + widget.currentUserNo!)
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserNo!,
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgTYPE: mssgDoc[Dbkeys.messageType],
            Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
            Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
            Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
            Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
            Dbkeys.isReply: false,
            Dbkeys.replyToMsgDoc: null,
            Dbkeys.isForward: true
          }, SetOptions(merge: true)).then((value) {
            unawaited(
                realtime.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut));
            // _playPopSound();
            FirebaseFirestore.instance
                .collection(DbPaths.collectiongroups)
                .doc(groupDoc[Dbkeys.groupID])
                .update(
              {Dbkeys.groupLATESTMESSAGETIME: timestamp},
            );
          }).then((value) {
            if (list.last[Dbkeys.groupID] == list[tempSendIndex][Dbkeys.groupID]) {
              Fiberchat.toast(
                getTranslated(this.context, 'sent'),
              );
              setStateIfMounted(() {
                isgeneratingSomethingLoader = false;
              });
              Navigator.of(this.context).pop();
            } else {
              sendForwardMessageEach(tempSendIndex + 1, list, privateKey, mssgDoc);
            }
          });
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Fiberchat.toast('Failed to send');
        }
      } else {
        try {
          String? sharedSecret = (await e2ee.X25519().calculateSharedSecret(
                  e2ee.Key.fromBase64(privateKey, false),
                  e2ee.Key.fromBase64(list[tempSendIndex][Dbkeys.publicKey], true)))
              .toBase64();
          final key = encrypt.Key.fromBase64(sharedSecret);
          cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
          String content = mssgDoc[Dbkeys.content];
          final encrypted = encryptWithCRC(content);
          if (encrypted is String) {
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            var chatId = Fiberchat.getChatId(widget.currentUserNo, list[tempSendIndex][Dbkeys.phone]);
            if (content.trim() != '') {
              Map<String, dynamic>? targetPeer =
                  widget.model.userData[list[tempSendIndex][Dbkeys.phone]];
              if (targetPeer == null) {
                await ChatController.request(currentUserNo, list[tempSendIndex][Dbkeys.phone],
                    Fiberchat.getChatId(widget.currentUserNo, list[tempSendIndex][Dbkeys.phone]));
              }

              await FirebaseFirestore.instance.collection(DbPaths.collectionmessages).doc(chatId).set({
                widget.currentUserNo!: true,
                list[index][Dbkeys.phone]: list[tempSendIndex][Dbkeys.lastSeen],
              }, SetOptions(merge: true)).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(list[tempSendIndex][Dbkeys.phone])
                    .collection(Dbkeys.chatsWith)
                    .doc(Dbkeys.chatsWith)
                    .set({
                  widget.currentUserNo!: 4,
                }, SetOptions(merge: true));
                await widget.model.addMessage(list[tempSendIndex][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId)
                    .doc('$timestamp2')
                    .set({
                  Dbkeys.from: widget.currentUserNo!,
                  Dbkeys.to: list[tempSendIndex][Dbkeys.phone],
                  Dbkeys.timestamp: timestamp2,
                  Dbkeys.content: encrypted,
                  Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                  Dbkeys.hasSenderDeleted: false,
                  Dbkeys.hasRecipientDeleted: false,
                  Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                  Dbkeys.isReply: false,
                  Dbkeys.replyToMsgDoc: null,
                  Dbkeys.isForward: true
                }, SetOptions(merge: true));
                await widget.model.addMessage(list[tempSendIndex][Dbkeys.phone], timestamp2, messaging);
              }).then((value) {
                if (list.last[Dbkeys.phone] == list[tempSendIndex][Dbkeys.phone]) {
                  Fiberchat.toast(
                    getTranslated(this.context, 'sent'),
                  );
                  setStateIfMounted(() {
                    isgeneratingSomethingLoader = false;
                  });
                  Navigator.of(this.context).pop();
                } else {
                  sendForwardMessageEach(tempSendIndex + 1, list, privateKey, mssgDoc);
                }
              });
            }
          } else {
            setStateIfMounted(() {
              isgeneratingSomethingLoader = false;
            });
            Fiberchat.toast('Nothing to send');
          }
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Fiberchat.toast('Failed to Forward message. Error:$e');
        }
      }
    }
  }

  contextMenuOld(BuildContext context, Map<String, dynamic> doc, {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    // if (saved == false && !doc.containsKey(Dbkeys.broadcastID)) {
    //   tiles.add(ListTile(
    //       dense: true,
    //       leading: Icon(Icons.save_outlined),
    //       title: Text(
    //         getTranslated(this.context, 'save'),
    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //       ),
    //       onTap: () {
    //         save(doc);
    //         hidekeyboard(context);
    //         Navigator.pop(context);
    //       }));
    // }
    if ((doc[Dbkeys.from] != currentUserNo) && saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete),
          title: Text(
            getTranslated(this.context, 'dltforme'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('${doc[Dbkeys.timestamp]}')
                .update({Dbkeys.hasRecipientDeleted: true});
            Save.deleteMessage(peerNo, doc);
            _savedMessageDocs.removeWhere((msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });

            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.maybePop(context);
              Fiberchat.toast(
                getTranslated(this.context, 'deleted'),
              );
            });
          }));
    }

    if (doc[Dbkeys.messageType] == MessageType.text.index) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.content_copy),
          title: Text(
            getTranslated(context, 'copy'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: doc[Dbkeys.content]));
            Navigator.pop(context);
            Fiberchat.toast(
              getTranslated(this.context, 'copied'),
            );
          }));
    }
    if (doc.containsKey(Dbkeys.broadcastID) && doc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.block),
          title: Text(
            getTranslated(this.context, 'blockbroadcast'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Fiberchat.toast(
              getTranslated(this.context, 'plswait'),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              FirebaseFirestore.instance
                  .collection(DbPaths.collectionbroadcasts)
                  .doc(doc[Dbkeys.broadcastID])
                  .update({
                Dbkeys.broadcastMEMBERSLIST: FieldValue.arrayRemove([widget.currentUserNo]),
                Dbkeys.broadcastBLACKLISTED: FieldValue.arrayUnion([widget.currentUserNo]),
              }).then((value) {
                Fiberchat.toast(
                  getTranslated(this.context, 'blockedbroadcast'),
                );
                hidekeyboard(context);
                Navigator.pop(context);
              }).catchError((error) {
                Fiberchat.toast(
                  getTranslated(this.context, 'blockedbroadcast'),
                );
                Navigator.pop(context);
                hidekeyboard(context);
              });
            });
          }));
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  save(Map<String, dynamic> doc) async {
    Fiberchat.toast(
      getTranslated(this.context, 'saved'),
    );
    if (!_savedMessageDocs.any((_doc) => _doc[Dbkeys.timestamp] == doc[Dbkeys.timestamp])) {
      String? content;
      if (doc[Dbkeys.messageType] == MessageType.image.index) {
        content = doc[Dbkeys.content].toString().startsWith('http')
            ? await Save.getBase64FromImage(imageUrl: doc[Dbkeys.content] as String?)
            : doc[Dbkeys.content]; // if not a url, it is a base64 from saved messages
      } else {
        // If text
        content = doc[Dbkeys.content];
      }
      doc[Dbkeys.content] = content;
      Save.saveMessage(peerNo, doc);
      _savedMessageDocs.add(doc);
      setStateIfMounted(() {
        _savedMessageDocs = List.from(_savedMessageDocs);
      });
    }
  }

  Widget selectablelinkify(String? text, double? fontsize) {
    return SelectableLinkify(
      style: TextStyle(fontSize: fontsize, color: Colors.black87),
      text: text ?? "",
      onOpen: (link) async {
        if (await canLaunch(link.url)) {
          await launch(link.url);
        } else {
          throw 'Could not launch $link';
        }
      },
      //   Text(
      // text ?? "",
      // style: TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 16),
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child: Row(
                                  mainAxisAlignment:
                                      isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Icon(
                                  Icons.share,
                                  size: 12,
                                  color: fiberchatGrey.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(getTranslated(this.context, 'forwarded'),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: fiberchatGrey.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13))
                              ])),
                          SizedBox(
                            height: 10,
                          ),
                          selectablelinkify(doc[Dbkeys.content], 16),
                        ],
                      )
                    : selectablelinkify(doc[Dbkeys.content], 16)
                : selectablelinkify(doc[Dbkeys.content], 16)
        : selectablelinkify(doc[Dbkeys.content], 16);
  }

  Widget getTempTextMessage(
    String message,
    Map<String, dynamic> doc,
  ) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(message, 16)
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child: Row(
                                  mainAxisAlignment:
                                      isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Icon(
                                  Icons.share,
                                  size: 12,
                                  color: fiberchatGrey.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(getTranslated(this.context, 'forwarded'),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: fiberchatGrey.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13))
                              ])),
                          SizedBox(
                            height: 10,
                          ),
                          selectablelinkify(message, 16)
                        ],
                      )
                    : selectablelinkify(message, 16)
                : selectablelinkify(message, 16)
        : selectablelinkify(message, 16);
  }

  Widget getLocationMessage(Map<String, dynamic> doc, String? message, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return InkWell(
      onTap: () {
        launch(message!);
      },
      child: doc.containsKey(Dbkeys.isForward) == true
          ? doc[Dbkeys.isForward] == true
              ? Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        child: Row(
                            mainAxisAlignment:
                                isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Icon(
                            Icons.share,
                            size: 12,
                            color: fiberchatGrey.withOpacity(0.5),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(getTranslated(this.context, 'forwarded'),
                              maxLines: 1,
                              style: TextStyle(
                                  color: fiberchatGrey.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 13))
                        ])),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      'assets/images/mapview.jpg',
                    )
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                )
          : Image.asset(
              'assets/images/mapview.jpg',
            ),
    );
  }

  Widget getAudiomessage(BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment: isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment:
                              isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: Platform.isIOS
                  ? () {
                      launch(message.split('-BREAK-')[0]);
                    }
                  : () async {
                      await downloadFile(
                        context: _scaffold.currentContext!,
                        fileName: 'Recording_' + message.split('-BREAK-')[1] + '.mp3',
                        isonlyview: false,
                        keyloader: _keyLoader,
                        uri: message.split('-BREAK-')[0],
                      );
                    },
              url: message.split('-BREAK-')[0],
            ),
          )
        ],
      ),
    );
  }

  Widget getDocmessage(BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        crossAxisAlignment: isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment:
                              isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          ListTile(
            contentPadding: EdgeInsets.all(4),
            isThreeLine: false,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(7.0),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.insert_drive_file,
                size: 25,
                color: Colors.white,
              ),
            ),
            title: Text(
              message.split('-BREAK-')[1],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(height: 1.4, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ),
          Divider(
            height: 3,
          ),
          message.split('-BREAK-')[1].endsWith('.pdf')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ignore: deprecated_member_use
                    FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                title: message.split('-BREAK-')[1],
                                url: message.split('-BREAK-')[0],
                              ),
                            ),
                          );
                        },
                        child: Text(getTranslated(this.context, 'preview'),
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue[400]))),
                    // ignore: deprecated_member_use
                    FlatButton(
                        onPressed: Platform.isIOS
                            ? () {
                                launch(message.split('-BREAK-')[0]);
                              }
                            : () async {
                                await downloadFile(
                                  context: _scaffold.currentContext!,
                                  fileName: message.split('-BREAK-')[1],
                                  isonlyview: false,
                                  keyloader: _keyLoader,
                                  uri: message.split('-BREAK-')[0],
                                );
                              },
                        child: Text(getTranslated(this.context, 'download'),
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue[400]))),
                  ],
                )
              //ignore: deprecated_member_use
              : FlatButton(
                  onPressed: Platform.isIOS
                      ? () {
                          launch(message.split('-BREAK-')[0]);
                        }
                      : () async {
                          await downloadFile(
                            context: _scaffold.currentContext!,
                            fileName: message.split('-BREAK-')[1],
                            isonlyview: false,
                            keyloader: _keyLoader,
                            uri: message.split('-BREAK-')[0],
                          );
                        },
                  child: Text(getTranslated(this.context, 'download'),
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return Container(
      child: Column(
        crossAxisAlignment: isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment:
                              isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          saved
              ? Material(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Save.getImageFromBase64(doc[Dbkeys.content]).image, fit: BoxFit.cover),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 102 : 200.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    padding: EdgeInsets.all(80.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: (context, str, error) => Material(
                    child: Image.asset(
                      'assets/images/img_not_available.jpeg',
                      width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                      height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: doc[Dbkeys.content],
                  width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  fit: BoxFit.cover,
                ),
        ],
      ),
    );
  }

  Widget getTempImageMessage({String? url}) {
    return url == null
        ? Container(
            child: Image.file(
              pickedFile!,
              width: url!.contains('giphy') ? 120 : 200.0,
              height: url.contains('giphy') ? 120 : 200.0,
              fit: BoxFit.cover,
            ),
          )
        : getImageMessage({Dbkeys.content: url});
  }

  Widget getVideoMessage(BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta = jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return InkWell(
      onTap: () {
        Navigator.push(
            this.context,
            new MaterialPageRoute(
                builder: (context) => new PreviewVideo(
                      isdownloadallowed: true,
                      filename: message.split('-BREAK-')[1],
                      id: null,
                      videourl: message.split('-BREAK-')[0],
                      aspectratio: meta!["width"] / meta["height"],
                    )));
      },
      child: Column(
        crossAxisAlignment: isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment:
                              isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          Container(
            color: Colors.blueGrey,
            height: 197,
            width: 197,
            child: Stack(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                    width: 197,
                    height: 197,
                    padding: EdgeInsets.all(80.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(0.0),
                      ),
                    ),
                  ),
                  errorWidget: (context, str, error) => Material(
                    child: Image.asset(
                      'assets/images/img_not_available.jpeg',
                      width: 197,
                      height: 197,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(0.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: message.split('-BREAK-')[1],
                  width: 197,
                  height: 197,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  height: 197,
                  width: 197,
                ),
                Center(
                  child: Icon(Icons.play_circle_fill_outlined, color: Colors.white70, size: 65),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getContactMessage(BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 250,
      height: 130,
      child: Column(
        crossAxisAlignment: isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment:
                              isMe == true ? MainAxisAlignment.start : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          ListTile(
            isThreeLine: false,
            leading: customCircleAvatar(url: null),
            title: Text(
              message.split('-BREAK-')[0],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(height: 1.4, fontWeight: FontWeight.w700, color: Colors.blue[400]),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                message.split('-BREAK-')[1],
                style: TextStyle(height: 1.4, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
          ),
          Divider(
            height: 7,
          ),
          // ignore: deprecated_member_use
          Row(
            children: [
              FlatButton(
                onPressed: () async {
                  String peer = message.split('-BREAK-')[1];
                  String? peerphone;
                  bool issearching = true;
                  bool issearchraw = false;
                  bool isUser = false;
                  String? formattedphone;

                  setStateIfMounted(() {
                    peerphone = peer.replaceAll(new RegExp(r'-'), '');
                    peerphone!.trim();
                  });

                  formattedphone = peerphone;

                  if (!peerphone!.startsWith('+')) {
                    if ((peerphone!.length > 11)) {
                      CountryCodes.forEach((code) {
                        if (peerphone!.startsWith(code) && issearching == true) {
                          setStateIfMounted(() {
                            formattedphone = peerphone!.substring(code.length, peerphone!.length);
                            issearchraw = true;
                            issearching = false;
                          });
                        }
                      });
                    } else {
                      setStateIfMounted(() {
                        setStateIfMounted(() {
                          issearchraw = true;
                          formattedphone = peerphone;
                        });
                      });
                    }
                  } else {
                    setStateIfMounted(() {
                      issearchraw = false;
                      formattedphone = peerphone;
                    });
                  }

                  Query<Map<String, dynamic>> query = issearchraw == true
                      ? FirebaseFirestore.instance
                          .collection(DbPaths.collectionusers)
                          .where(Dbkeys.phoneRaw, isEqualTo: formattedphone ?? peerphone)
                          .limit(1)
                      : FirebaseFirestore.instance
                          .collection(DbPaths.collectionusers)
                          .where(Dbkeys.phone, isEqualTo: formattedphone ?? peerphone)
                          .limit(1);

                  await query.get().then((user) {
                    setStateIfMounted(() {
                      isUser = user.docs.length == 0 ? false : true;
                    });
                    if (isUser) {
                      Map<String, dynamic> peer = user.docs[0].data();
                      widget.model.addUser(user.docs[0]);
                      Navigator.pushReplacement(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ChatScreen(
                                  isSharingIntentForwarded: false,
                                  prefs: widget.prefs,
                                  unread: 0,
                                  currentUserNo: widget.currentUserNo,
                                  model: widget.model,
                                  peerNo: peer[Dbkeys.phone])));
                    } else {
                      Query<Map<String, dynamic>> queryretrywithoutzero = issearchraw == true
                          ? FirebaseFirestore.instance
                              .collection(DbPaths.collectionusers)
                              .where(Dbkeys.phoneRaw,
                                  isEqualTo: formattedphone == null
                                      ? peerphone!.substring(1, peerphone!.length)
                                      : formattedphone!.substring(1, formattedphone!.length))
                              .limit(1)
                          : FirebaseFirestore.instance
                              .collection(DbPaths.collectionusers)
                              .where(Dbkeys.phoneRaw,
                                  isEqualTo: formattedphone == null
                                      ? peerphone!.substring(1, peerphone!.length)
                                      : formattedphone!.substring(1, formattedphone!.length))
                              .limit(1);
                      queryretrywithoutzero.get().then((user) {
                        setStateIfMounted(() {
                          isLoading = false;
                          isUser = user.docs.length == 0 ? false : true;
                        });
                        if (isUser) {
                          Map<String, dynamic> peer = user.docs[0].data();
                          widget.model.addUser(user.docs[0]);
                          Navigator.pushReplacement(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new ChatScreen(
                                      isSharingIntentForwarded: true,
                                      prefs: widget.prefs,
                                      unread: 0,
                                      currentUserNo: widget.currentUserNo,
                                      model: widget.model,
                                      peerNo: peer[Dbkeys.phone])));
                        }
                      });
                    }
                  });

                  // ignore: unnecessary_null_comparison
                  if (isUser == null || isUser == false) {
                    Fiberchat.toast(getTranslated(this.context, 'usernotjoined') + ' $Appname');
                  }
                },
                child: Text(
                  getTranslated(this.context, 'msg'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[400],
                  ),
                ),
              ),
              Spacer(),
              !isMe
                  ? TextButton(
                      onPressed: () async {
                        final TextEditingController contactNameController = TextEditingController();
                        final TextEditingController contactNumberController = TextEditingController();
                        contactNameController.text = message.split('-BREAK-')[0];
                        contactNumberController.text = message.split('-BREAK-')[1];
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 20,
                                    ),
                                    child: Text(
                                      "Save Contact",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        // color: Colors.blue[400],
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 20,
                                      bottom: 10,
                                    ),
                                    child: TextFormField(
                                      controller: contactNameController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        label: Text("Name"),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: TextFormField(
                                      controller: contactNumberController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        label: Text("Mobile Number"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        await ContactsService.addContact(
                                          Contact(
                                            givenName: contactNameController.text.trim(),
                                            phones: [
                                              Item(
                                                label: "Mobile",
                                                value: contactNumberController.text.trim(),
                                              ),
                                            ],
                                          ),
                                        );
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Contact Saved!"),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(left: 10, bottom: 20),
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.blue[400],
                                        ),
                                        child: Text(
                                          "Save Contact",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        getTranslated(this.context, 'savecontact'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400],
                        ),
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  _onEmojiSelected(Emoji emoji) {
    // String text = textEditingController.text;
    // TextSelection textSelection = textEditingController.selection;
    // String newText =
    //     text.replaceRange(textSelection.start, textSelection.end, emoji.emoji);
    // final emojiLength = emoji.emoji.length;
    // textEditingController.text = newText;
    // textEditingController.selection = textSelection.copyWith(
    //   baseOffset: textSelection.start + emojiLength,
    //   extentOffset: textSelection.start + emojiLength,
    // );
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
  }

  Widget buildMessage(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false, List<Message>? savedMsgs}) {
    final observer = Provider.of<Observer>(context, listen: false);
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    bool isContinuing;
    if (savedMsgs == null)
      isContinuing = messages.isNotEmpty ? messages.last.from == doc[Dbkeys.from] : false;
    else {
      isContinuing = savedMsgs.isNotEmpty ? savedMsgs.last.from == doc[Dbkeys.from] : false;
    }
    return SeenProvider(
      timestamp: doc[Dbkeys.timestamp].toString(),
      data: seenState,
      child: Bubble(
        mssgDoc: doc,
        is24hrsFormat: observer.is24hrsTimeformat,
        isMssgDeleted: (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                doc.containsKey(Dbkeys.hasSenderDeleted))
            ? isMe
                ? (doc[Dbkeys.from] == widget.currentUserNo ? doc[Dbkeys.hasSenderDeleted] : false)
                : (doc[Dbkeys.from] != widget.currentUserNo ? doc[Dbkeys.hasRecipientDeleted] : false)
            : false,
        isBroadcastMssg: doc.containsKey(Dbkeys.isbroadcast) == true ? doc[Dbkeys.isbroadcast] : false,
        messagetype: doc[Dbkeys.messageType] == MessageType.text.index
            ? MessageType.text
            : doc[Dbkeys.messageType] == MessageType.contact.index
                ? MessageType.contact
                : doc[Dbkeys.messageType] == MessageType.location.index
                    ? MessageType.location
                    : doc[Dbkeys.messageType] == MessageType.image.index
                        ? MessageType.image
                        : doc[Dbkeys.messageType] == MessageType.video.index
                            ? MessageType.video
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? MessageType.doc
                                : doc[Dbkeys.messageType] == MessageType.audio.index
                                    ? MessageType.audio
                                    : MessageType.text,
        child: doc[Dbkeys.messageType] == MessageType.text.index
            ? getTextMessage(isMe, doc, saved)
            : doc[Dbkeys.messageType] == MessageType.location.index
                ? getLocationMessage(doc, doc[Dbkeys.content], saved: false)
                : doc[Dbkeys.messageType] == MessageType.doc.index
                    ? getDocmessage(context, doc, doc[Dbkeys.content], saved: false)
                    : doc[Dbkeys.messageType] == MessageType.audio.index
                        ? getAudiomessage(context, doc, doc[Dbkeys.content], isMe: isMe, saved: false)
                        : doc[Dbkeys.messageType] == MessageType.video.index
                            ? getVideoMessage(context, doc, doc[Dbkeys.content], saved: false)
                            : doc[Dbkeys.messageType] == MessageType.contact.index
                                ? getContactMessage(context, doc, doc[Dbkeys.content], saved: false)
                                : getImageMessage(
                                    doc,
                                    saved: saved,
                                  ),
        isMe: isMe,
        timestamp: doc[Dbkeys.timestamp],
        delivered: _cachedModel.getMessageStatus(peerNo, doc[Dbkeys.timestamp]),
        isContinuing: isContinuing,
      ),
    );
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Flexible(
      child: Container(
          // width: 280,
          height: 70,
          margin: EdgeInsets.only(left: 0, right: 0),
          decoration: BoxDecoration(
              color: fiberchatWhite.withOpacity(0.55),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: fiberchatGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: doc[Dbkeys.from] == currentUserNo ? multiboxMainColor : Colors.purple,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text(
                              doc[Dbkeys.from] == currentUserNo
                                  ? getTranslated(this.context, 'you')
                                  : Fiberchat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.from] == currentUserNo
                                      ? multiboxMainColor
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          doc[Dbkeys.messageType] == MessageType.text.index
                              ? Text(
                                  doc[Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign:  doc[Dbkeys.from] == currentUserNo? TextAlign.end: TextAlign.start,
                                  maxLines: 2,
                                )
                              : doc[Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 70),
                                      child: Text(
                                        doc[Dbkeys.content].split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                                  : Text(
                                      getTranslated(
                                          this.context,
                                          doc[Dbkeys.messageType] == MessageType.image.index
                                              ? 'nim'
                                              : doc[Dbkeys.messageType] == MessageType.video.index
                                                  ? 'nvm'
                                                  : doc[Dbkeys.messageType] == MessageType.audio.index
                                                      ? 'nam'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType.contact.index
                                                          ? 'ncm'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType.location.index
                                                              ? 'nlm'
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType.doc.index
                                                                  ? 'ndm'
                                                                  : ''),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                        ],
                      ),
                    ))
                  ])),
              doc[Dbkeys.messageType] == MessageType.text.index ||
                      doc[Dbkeys.messageType] == MessageType.location.index
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : doc[Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 74.0,
                            height: 74.0,
                            padding: EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
                                  ),
                                  width: doc[Dbkeys.content].contains('giphy') ? 60 : 60.0,
                                  height: doc[Dbkeys.content].contains('giphy') ? 60 : 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: doc[Dbkeys.messageType] == MessageType.video.index
                                    ? ''
                                    : doc[Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : doc[Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 74.0,
                                  height: 74.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 74,
                                        width: 74,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) => Container(
                                                child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(fiberchatBlue),
                                                ),
                                                width: 74,
                                                height: 74,
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, str, error) => Material(
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                              imageUrl: doc[Dbkeys.content].split('-BREAK-')[1],
                                              width: 74,
                                              height: 74,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color: Colors.black.withOpacity(0.4),
                                              height: 74,
                                              width: 74,
                                            ),
                                            Center(
                                              child: Icon(Icons.play_circle_fill_outlined,
                                                  color: Colors.white70, size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 74.0,
                                  height: 74.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: doc[Dbkeys.messageType] == MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : doc[Dbkeys.messageType] == MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : doc[Dbkeys.messageType] == MessageType.location.index
                                                      ? Colors.red[700]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType.contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 74,
                                          width: 74,
                                          child: Icon(
                                            doc[Dbkeys.messageType] == MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : doc[Dbkeys.messageType] == MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : doc[Dbkeys.messageType] ==
                                                            MessageType.location.index
                                                        ? Icons.location_on
                                                        : doc[Dbkeys.messageType] ==
                                                                MessageType.contact.index
                                                            ? Icons.contact_page_sharp
                                                            : Icons.insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
            ],
          )),
    );
  }

  Widget buildReplyMessageForInput(
    BuildContext context,
  ) {
    return Flexible(
      child: Container(
          height: 80,
          margin: EdgeInsets.only(left: 15, right: 70),
          decoration:
              BoxDecoration(color: fiberchatWhite, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: fiberchatGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            replyDoc![Dbkeys.from] == currentUserNo ? multiboxMainColor : Colors.purple,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text(
                              replyDoc![Dbkeys.from] == currentUserNo
                                  ? getTranslated(this.context, 'you')
                                  : Fiberchat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.from] == currentUserNo
                                      ? multiboxMainColor
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          replyDoc![Dbkeys.messageType] == MessageType.text.index
                              ? Text(
                                  replyDoc![Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              : replyDoc![Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      width: MediaQuery.of(context).size.width - 125,
                                      padding: const EdgeInsets.only(right: 55),
                                      child: Text(
                                        replyDoc![Dbkeys.content].split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
                                  : Text(
                                      getTranslated(
                                          this.context,
                                          replyDoc![Dbkeys.messageType] == MessageType.image.index
                                              ? 'nim'
                                              : replyDoc![Dbkeys.messageType] == MessageType.video.index
                                                  ? 'nvm'
                                                  : replyDoc![Dbkeys.messageType] ==
                                                          MessageType.audio.index
                                                      ? 'nam'
                                                      : replyDoc![Dbkeys.messageType] ==
                                                              MessageType.contact.index
                                                          ? 'ncm'
                                                          : replyDoc![Dbkeys.messageType] ==
                                                                  MessageType.location.index
                                                              ? 'nlm'
                                                              : replyDoc![Dbkeys.messageType] ==
                                                                      MessageType.doc.index
                                                                  ? 'ndm'
                                                                  : ''),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                        ],
                      ),
                    ))
                  ])),
              replyDoc![Dbkeys.messageType] == MessageType.text.index
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : replyDoc![Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 84.0,
                            height: 84.0,
                            padding: EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
                                  ),
                                  width: replyDoc![Dbkeys.content].contains('giphy') ? 60 : 60.0,
                                  height: replyDoc![Dbkeys.content].contains('giphy') ? 60 : 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: replyDoc![Dbkeys.messageType] == MessageType.video.index
                                    ? ''
                                    : replyDoc![Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : replyDoc![Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 84,
                                        width: 84,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) => Container(
                                                child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(fiberchatBlue),
                                                ),
                                                width: 84,
                                                height: 84,
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, str, error) => Material(
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                              imageUrl: replyDoc![Dbkeys.content].split('-BREAK-')[1],
                                              width: 84,
                                              height: 84,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color: Colors.black.withOpacity(0.4),
                                              height: 84,
                                              width: 84,
                                            ),
                                            Center(
                                              child: Icon(Icons.play_circle_fill_outlined,
                                                  color: Colors.white70, size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: replyDoc![Dbkeys.messageType] == MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : replyDoc![Dbkeys.messageType] == MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : replyDoc![Dbkeys.messageType] ==
                                                          MessageType.location.index
                                                      ? Colors.red[700]
                                                      : replyDoc![Dbkeys.messageType] ==
                                                              MessageType.contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 84,
                                          width: 84,
                                          child: Icon(
                                            replyDoc![Dbkeys.messageType] == MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : replyDoc![Dbkeys.messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : replyDoc![Dbkeys.messageType] ==
                                                            MessageType.location.index
                                                        ? Icons.location_on
                                                        : replyDoc![Dbkeys.messageType] ==
                                                                MessageType.contact.index
                                                            ? Icons.contact_page_sharp
                                                            : Icons.insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
              Positioned(
                right: 7,
                top: 7,
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      HapticFeedback.heavyImpact();
                      isReplyKeyboard = false;
                      hidekeyboard(context);
                    });
                  },
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: new Icon(
                      Icons.close,
                      color: Colors.blueGrey,
                      size: 13,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget buildTempMessage(
      BuildContext context, MessageType type, content, timestamp, delivered, tempDoc) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    final bool isMe = true;
    return SeenProvider(
      timestamp: timestamp.toString(),
      data: seenState,
      child: Bubble(
        mssgDoc: tempDoc,
        is24hrsFormat: observer.is24hrsTimeformat,
        isMssgDeleted: ((tempDoc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    tempDoc.containsKey(Dbkeys.hasSenderDeleted)) ==
                true)
            ? (isMe == true
                ? (tempDoc[Dbkeys.from] == widget.currentUserNo
                    ? tempDoc[Dbkeys.hasSenderDeleted]
                    : false)
                : (tempDoc[Dbkeys.from] != widget.currentUserNo
                    ? tempDoc[Dbkeys.hasRecipientDeleted]
                    : false))
            : false,
        isBroadcastMssg: false,
        messagetype: type,
        child: type == MessageType.text
            ? getTempTextMessage(content, tempDoc)
            : type == MessageType.location
                ? getLocationMessage(tempDoc, content, saved: false)
                : type == MessageType.doc
                    ? getDocmessage(context, tempDoc, content, saved: false)
                    : type == MessageType.audio
                        ? getAudiomessage(context, tempDoc, content, saved: false, isMe: isMe)
                        : type == MessageType.video
                            ? getVideoMessage(this.context, tempDoc, content, saved: false)
                            : type == MessageType.contact
                                ? getContactMessage(context, tempDoc, content, saved: false)
                                : getTempImageMessage(url: content),
        isMe: isMe,
        timestamp: timestamp,
        delivered: delivered,
        isContinuing: messages.isNotEmpty && messages.last.from == currentUserNo,
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child:
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue)),
              ),
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatBlack.withOpacity(0.6)
                  : fiberchatWhite.withOpacity(0.6),
            )
          : Container(),
    );
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child:
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue)),
              ),
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatBlack.withOpacity(0.6)
                  : fiberchatWhite.withOpacity(0.6),
            )
          : Container(),
    );
  }

  shareMedia(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Container(
            padding: EdgeInsets.all(12),
            height: 250,
            child: Column(children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiDocumentPicker(
                                          title: getTranslated(this.context, 'pickdoc'),
                                          callback: getFileData,
                                          writeMessage: (String? url, int time) async {
                                            if (url != null) {
                                              String finalUrl = url +
                                                  '-BREAK-' +
                                                  basename(pickedFile!.path).toString();
                                              onSendMessage(
                                                  this.context, finalUrl, MessageType.doc, time);
                                            }
                                          },
                                        )));
                          },
                          elevation: .5,
                          fillColor: Colors.indigo,
                          child: Icon(
                            Icons.file_copy,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'doc'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HybridVideoPicker(
                                          title: getTranslated(this.context, 'pickvideo'),
                                          callback: getFileData,
                                        ))).then((url) async {
                              if (url != null) {
                                Fiberchat.toast(
                                  getTranslated(this.context, 'plswait'),
                                );
                                String thumbnailurl = await getThumbnail(url);
                                onSendMessage(
                                    context,
                                    url + '-BREAK-' + thumbnailurl + '-BREAK-' + videometadata,
                                    MessageType.video,
                                    thumnailtimestamp);
                                Fiberchat.toast(getTranslated(this.context, 'sent'));
                              } else {}
                            });
                          },
                          elevation: .5,
                          fillColor: Colors.pink[600],
                          child: Icon(
                            Icons.video_collection_sharp,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'video'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiImagePicker(
                                          title: getTranslated(this.context, 'pickimage'),
                                          callback: getFileData,
                                          writeMessage: (String? url, int time) async {
                                            if (url != null) {
                                              onSendMessage(this.context, url, MessageType.image, time);
                                            }
                                          },
                                        )));
                          },
                          elevation: .5,
                          fillColor: Colors.purple,
                          child: Icon(
                            Icons.image_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'image'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);

                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AudioRecord(
                                          title: getTranslated(this.context, 'record'),
                                          callback: getFileData,
                                        ))).then((url) {
                              if (url != null) {
                                onSendMessage(context, url + '-BREAK-' + uploadTimestamp.toString(),
                                    MessageType.audio, uploadTimestamp);
                              } else {}
                            });
                          },
                          elevation: .5,
                          fillColor: Colors.yellow[900],
                          child: Icon(
                            Icons.mic_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'audio'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            await _determinePosition().then(
                              (location) async {
                                var locationstring =
                                    'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                                onSendMessage(context, locationstring, MessageType.location,
                                    DateTime.now().millisecondsSinceEpoch);
                                setStateIfMounted(() {});
                                Fiberchat.toast(
                                  getTranslated(this.context, 'sent'),
                                );
                              },
                            );
                          },
                          elevation: .5,
                          fillColor: Colors.cyan[700],
                          child: Icon(
                            Icons.location_on,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'location'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContactsSelect(
                                        currentUserNo: widget.currentUserNo,
                                        model: widget.model,
                                        biometricEnabled: false,
                                        prefs: widget.prefs,
                                        onSelect: (name, phone) {
                                          onSendMessage(
                                              context,
                                              '$name-BREAK-$phone',
                                              MessageType.contact,
                                              DateTime.now().millisecondsSinceEpoch);
                                        })));
                          },
                          elevation: .5,
                          fillColor: Colors.blue[800],
                          child: Icon(
                            Icons.person,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'contact'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ]),
          );
        });
  }

  FocusNode keyboardFocusNode = new FocusNode();
  Widget buildInputAndroid(
      BuildContext context, bool isemojiShowing, Function refreshThisInput, bool keyboardVisible) {
    final observer = Provider.of<Observer>(context, listen: true);
    if (chatStatus == ChatStatus.requested.index) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          getTranslated(this.context, 'accept') + '${peer![Dbkeys.nickname]} ?',
          style: TextStyle(color: fiberchatBlack),
        ),
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
              child: Text(getTranslated(this.context, 'rjt')),
              onPressed: () {
                ChatController.block(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.blocked.index;
                });
              }),
          // ignore: deprecated_member_use
          FlatButton(
              child:
                  Text(getTranslated(this.context, 'acpt'), style: TextStyle(color: multiboxMainColor)),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
    return Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
      isReplyKeyboard == true
          ? buildReplyMessageForInput(
              context,
            )
          : SizedBox(),
      Container(
        margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: Container(
                margin: EdgeInsets.only(
                  left: 10,
                ),
                decoration: BoxDecoration(
                    color: Color(0xffEFEFF2), borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () {
                          refreshThisInput();
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          color: fiberchatGrey,
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        onTap: () {
                          if (isemojiShowing == true) {
                          } else {
                            keyboardFocusNode.requestFocus();
                          }
                        },
                        showCursor: true,
                        focusNode: keyboardFocusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(fontSize: 16.0, color: fiberchatBlack),
                        controller: textEditingController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
                          ),
                          hoverColor: Colors.transparent,
                          focusedBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide: BorderSide(color: Colors.transparent)),
                          contentPadding: EdgeInsets.fromLTRB(10, 4, 7, 4),
                          hintText: getTranslated(this.context, 'typmsg'),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                        width: textEditingController.text.isNotEmpty ? 10 : 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            textEditingController.text.isNotEmpty
                                ? SizedBox()
                                : SizedBox(
                                    width: 30,
                                    child: IconButton(
                                      icon: new Icon(
                                        Icons.attachment_outlined,
                                        color: fiberchatGrey,
                                      ),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: observer.ismediamessagingallowed == false
                                          ? () {
                                              Fiberchat.showRationale(
                                                  getTranslated(this.context, 'mediamssgnotallowed'));
                                            }
                                          : chatStatus == ChatStatus.blocked.index
                                              ? () {
                                                  Fiberchat.toast(getTranslated(this.context, 'unlck'));
                                                }
                                              : () {
                                                  hidekeyboard(context);
                                                  shareMedia(context);
                                                },
                                      color: fiberchatWhite,
                                    ),
                                  ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
            // Button send message
            Container(
              height: 47,
              width: 47,
              // alignment: Alignment.center,
              margin: EdgeInsets.only(left: 6, right: 10),
              decoration: BoxDecoration(
                  color: DESIGN_TYPE == Themetype.whatsapp ? Color(0xffD4AF36) : fiberchatLightGreen,
                  // border: Border.all(
                  //   color: Colors.red[500],
                  // ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: IconButton(
                  icon: new Icon(
                    textEditingController.text.length == 0 || isMessageLoading == true
                        ? Icons.mic
                        : Icons.send,
                    color: fiberchatWhite.withOpacity(0.99),
                  ),
                  onPressed: observer.ismediamessagingallowed == true
                      ? textEditingController.text.length == 0 || isMessageLoading == true
                          ? () {
                              hidekeyboard(context);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AudioRecord(
                                            title: getTranslated(this.context, 'record'),
                                            callback: getFileData,
                                          ))).then((url) {
                                if (url != null) {
                                  onSendMessage(context, url + '-BREAK-' + uploadTimestamp.toString(),
                                      MessageType.audio, uploadTimestamp);
                                } else {}
                              });
                            }
                          : observer.istextmessagingallowed == false
                              ? () {
                                  Fiberchat.showRationale(
                                      getTranslated(this.context, 'textmssgnotallowed'));
                                }
                              : chatStatus == ChatStatus.blocked.index
                                  ? null
                                  : () => onSendMessage(context, textEditingController.text,
                                      MessageType.text, DateTime.now().millisecondsSinceEpoch)
                      : () {
                          Fiberchat.showRationale(getTranslated(this.context, 'mediamssgnotallowed'));
                        },
                  color: fiberchatWhite,
                ),
              ),
            ),
          ],
        ),
        width: double.infinity,
        height: 60.0,
        decoration: new BoxDecoration(
          // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.transparent,
        ),
      ),
      isemojiShowing == true && keyboardVisible == false
          ? Offstage(
              offstage: !isemojiShowing,
              child: SizedBox(
                height: 300,
                child: EmojiPicker(
                    onEmojiSelected: (emojipic.Category category, Emoji emoji) {
                      _onEmojiSelected(emoji);
                    },
                    onBackspacePressed: _onBackspacePressed,
                    config: Config(
                        columns: 7,
                        emojiSizeMax: 32.0,
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        initCategory: emojipic.Category.RECENT,
                        bgColor: Color(0xFFF2F2F2),
                        indicatorColor: multiboxMainColor,
                        iconColor: Colors.grey,
                        iconColorSelected: multiboxMainColor,
                        progressIndicatorColor: Colors.blue,
                        backspaceColor: multiboxMainColor,
                        showRecentsTab: true,
                        recentsLimit: 28,
                        noRecents: Text('No Recents',style: TextStyle(fontSize: 20, color: Colors.black26),),

                        categoryIcons: CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL)),
              ),
            )
          : SizedBox(),
    ]);
  }

  Widget buildInputIos(
    BuildContext context,
  ) {
    final observer = Provider.of<Observer>(context, listen: true);
    if (chatStatus == ChatStatus.requested.index) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          getTranslated(this.context, 'accept') + '${peer![Dbkeys.nickname]} ?',
          style: TextStyle(color: fiberchatBlack),
        ),
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
              child: Text(getTranslated(this.context, 'rjt')),
              onPressed: () {
                ChatController.block(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.blocked.index;
                });
              }),
          // ignore: deprecated_member_use
          FlatButton(
              child:
                  Text(getTranslated(this.context, 'acpt'), style: TextStyle(color: multiboxMainColor)),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
    return Container(
      margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: 10,
              ),
              decoration: BoxDecoration(
                  color: fiberchatWhite,
                  // border: Border.all(
                  //   color: Colors.red[500],
                  // ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: new Icon(
                            Icons.attachment_outlined,
                            color: fiberchatGrey,
                          ),
                          padding: EdgeInsets.all(0.0),
                          onPressed: observer.ismediamessagingallowed == false
                              ? () {
                                  Fiberchat.showRationale(
                                      getTranslated(this.context, 'mediamssgnotallowed'));
                                }
                              : chatStatus == ChatStatus.blocked.index
                                  ? () {
                                      Fiberchat.toast(getTranslated(this.context, 'unlck'));
                                    }
                                  : () {
                                      hidekeyboard(context);
                                      shareMedia(context);
                                    },
                          color: fiberchatWhite,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      style: TextStyle(fontSize: 18.0, color: fiberchatBlack),
                      controller: textEditingController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderRadius: BorderRadius.circular(1),
                          borderSide: BorderSide(color: Colors.transparent, width: 1.5),
                        ),
                        hoverColor: Colors.transparent,
                        focusedBorder: OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderRadius: BorderRadius.circular(1),
                          borderSide: BorderSide(color: Colors.transparent, width: 1.5),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1),
                            borderSide: BorderSide(color: Colors.transparent)),
                        contentPadding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                        hintText: getTranslated(this.context, 'typmsg'),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Button send message
          Container(
            height: 47,
            width: 47,
            // alignment: Alignment.center,
            margin: EdgeInsets.only(left: 6, right: 10),
            decoration: BoxDecoration(
                color: DESIGN_TYPE == Themetype.whatsapp ? Color(0xffD4AF36) : fiberchatLightGreen,
                // border: Border.all(
                //   color: Colors.red[500],
                // ),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: IconButton(
                icon: new Icon(
                  textEditingController.text.length == 0 || isMessageLoading == true
                      ? Icons.mic
                      : Icons.send,
                  color: fiberchatWhite.withOpacity(0.99),
                ),
                onPressed: observer.ismediamessagingallowed == true
                    ? textEditingController.text.length == 0 || isMessageLoading == true
                        ? () {
                            hidekeyboard(context);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AudioRecord(
                                          title: getTranslated(this.context, 'record'),
                                          callback: getFileData,
                                        ))).then((url) {
                              if (url != null) {
                                onSendMessage(context, url + '-BREAK-' + uploadTimestamp.toString(),
                                    MessageType.audio, uploadTimestamp);
                              } else {}
                            });
                          }
                        : observer.istextmessagingallowed == false
                            ? () {
                                Fiberchat.showRationale(
                                    getTranslated(this.context, 'textmssgnotallowed'));
                              }
                            : chatStatus == ChatStatus.blocked.index
                                ? null
                                : () => onSendMessage(context, textEditingController.text,
                                    MessageType.text, DateTime.now().millisecondsSinceEpoch)
                    : () {
                        Fiberchat.showRationale(getTranslated(this.context, 'mediamssgnotallowed'));
                      },
                color: fiberchatWhite,
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 60.0,
      decoration: new BoxDecoration(
        // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
        color: Colors.transparent,
      ),
    );
  }

  bool empty = true;

  loadMessagesAndListen() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .collection(chatId!)
        .orderBy(Dbkeys.timestamp)
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        empty = false;
        docs.docs.forEach((doc) {
          Map<String, dynamic> _doc = Map.from(doc.data());
          int? ts = _doc[Dbkeys.timestamp];
          _doc[Dbkeys.content] = decryptWithCRC(_doc[Dbkeys.content]);
          messages.add(Message(buildMessage(this.context, _doc),
              onDismiss: _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                  ? () {}
                  : () {
                      setStateIfMounted(() {
                        isReplyKeyboard = true;
                        replyDoc = _doc;
                      });
                      HapticFeedback.heavyImpact();
                      keyboardFocusNode.requestFocus();
                    },
              onTap:
                  (_doc[Dbkeys.from] == widget.currentUserNo && _doc[Dbkeys.hasSenderDeleted] == true) ==
                          true
                      ? () {}
                      : _doc[Dbkeys.messageType] == MessageType.image.index
                          ? () {
                              Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewWrapper(
                                      message: _doc[Dbkeys.content],
                                      tag: ts.toString(),
                                      imageProvider: CachedNetworkImageProvider(_doc[Dbkeys.content]),
                                    ),
                                  ));
                            }
                          : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID) ? () {} : () {}, onLongPress: () {
            if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                _doc.containsKey(Dbkeys.hasSenderDeleted)) {
              if ((_doc[Dbkeys.from] == widget.currentUserNo && _doc[Dbkeys.hasSenderDeleted] == true) ==
                  false) {
                //--Show Menu only if message is not deleted by current user already
                contextMenuNew(this.context, _doc, false);
              }
            } else {
              contextMenuOld(this.context, _doc);
            }
          }, from: _doc[Dbkeys.from], timestamp: ts));

          if (doc.data()[Dbkeys.timestamp] == docs.docs.last.data()[Dbkeys.timestamp]) {
            setStateIfMounted(() {
              isMessageLoading = false;
              // print('All message loaded..........');
            });
          }
        });
      } else {
        setStateIfMounted(() {
          isMessageLoading = false;
          // print('All message loaded..........');
        });
      }
      if (mounted) {
        setStateIfMounted(() {
          messages = List.from(messages);
        });
      }
      msgSubscription = FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId!)
          .where(Dbkeys.from, isEqualTo: peerNo)
          .snapshots()
          .listen((query) {
        if (empty == true || query.docs.length != query.docChanges.length) {
          //----below action triggers when peer new message arrives
          query.docChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex && doc.type == DocumentChangeType.added;

            //  &&
            //     query.docs[doc.oldIndex][Dbkeys.timestamp] !=
            //         query.docs[doc.newIndex][Dbkeys.timestamp];
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);
            int? ts = _doc[Dbkeys.timestamp];
            _doc[Dbkeys.content] = decryptWithCRC(_doc[Dbkeys.content]);

            messages.add(Message(
              buildMessage(this.context, _doc),
              onDismiss: _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                  ? () {}
                  : () {
                      setStateIfMounted(() {
                        isReplyKeyboard = true;
                        replyDoc = _doc;
                      });
                      HapticFeedback.heavyImpact();
                      keyboardFocusNode.requestFocus();
                    },
              onLongPress: () {
                if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    _doc.containsKey(Dbkeys.hasSenderDeleted)) {
                  if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      false) {
                    //--Show Menu only if message is not deleted by current user already
                    contextMenuNew(this.context, _doc, false);
                  }
                } else {
                  contextMenuOld(this.context, _doc);
                }
              },
              onTap:
                  (_doc[Dbkeys.from] == widget.currentUserNo && _doc[Dbkeys.hasSenderDeleted] == true) ==
                          true
                      ? () {}
                      : _doc[Dbkeys.messageType] == MessageType.image.index
                          ? () {
                              Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewWrapper(
                                      message: _doc[Dbkeys.content],
                                      tag: ts.toString(),
                                      imageProvider: CachedNetworkImageProvider(_doc[Dbkeys.content]),
                                    ),
                                  ));
                            }
                          : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                  ? () {}
                  : () {
                      // save(_doc);
                    },
              from: _doc[Dbkeys.from],
              timestamp: ts,
            ));
          });
          //----below action triggers when peer message get deleted
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.removed;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere((element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) messages.removeAt(i);
            Save.deleteMessage(peerNo, _doc);
            _savedMessageDocs.removeWhere((msg) => msg[Dbkeys.timestamp] == _doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });
          }); //----below action triggers when peer message gets modified
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.modified;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere((element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) {
              messages.removeAt(i);
              setStateIfMounted(() {});
              int? ts = _doc[Dbkeys.timestamp];
              _doc[Dbkeys.content] = decryptWithCRC(_doc[Dbkeys.content]);
              messages.insert(
                  i,
                  Message(
                    buildMessage(this.context, _doc),
                    onLongPress: () {
                      if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                          _doc.containsKey(Dbkeys.hasSenderDeleted)) {
                        if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            false) {
                          //--Show Menu only if message is not deleted by current user already
                          contextMenuNew(this.context, _doc, false);
                        }
                      } else {
                        contextMenuOld(this.context, _doc);
                      }
                    },
                    onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            true
                        ? () {}
                        : _doc[Dbkeys.messageType] == MessageType.image.index
                            ? () {
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoViewWrapper(
                                        message: _doc[Dbkeys.content],
                                        tag: ts.toString(),
                                        imageProvider: CachedNetworkImageProvider(_doc[Dbkeys.content]),
                                      ),
                                    ));
                              }
                            : null,
                    onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                        ? () {}
                        : () {
                            // save(_doc);
                          },
                    from: _doc[Dbkeys.from],
                    timestamp: ts,
                    onDismiss: _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                        ? () {}
                        : () {
                            setStateIfMounted(() {
                              isReplyKeyboard = true;
                              replyDoc = _doc;
                            });
                            HapticFeedback.heavyImpact();
                            keyboardFocusNode.requestFocus();
                          },
                  ));
            }
          });
          if (mounted) {
            setStateIfMounted(() {
              messages = List.from(messages);
            });
          }
        }
      });

      //----sharing intent action:

      if (widget.isSharingIntentForwarded == true) {
        if (widget.sharedText != null) {
          onSendMessage(
              this.context, widget.sharedText!, MessageType.text, DateTime.now().millisecondsSinceEpoch);
        } else if (widget.sharedFiles != null) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = true;
          });
          uploadEach(0);
        }
      }
    });
  }

  int currentUploadingIndex = 0;
  uploadEach(
    int index,
  ) async {
    File file = new File(widget.sharedFiles![index].path);
    String fileName = file.path.split('/').last;

    print(fileName);
    if (index > widget.sharedFiles!.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await getFileData(File(widget.sharedFiles![index].path),
              timestamp: messagetime, totalFiles: widget.sharedFiles!.length)
          .then((imageUrl) async {
        if (imageUrl != null) {
          MessageType type = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? MessageType.image
              : fileName.contains('.mp4')
                  ? MessageType.video
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? MessageType.audio
                      : MessageType.doc;
          String? thumbnailurl;
          if (type == MessageType.video) {
            thumbnailurl = await getThumbnail(imageUrl);

            setStateIfMounted(() {});
          }

          String finalUrl = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? imageUrl
              : fileName.contains('.mp4')
                  ? imageUrl + '-BREAK-' + thumbnailurl + '-BREAK-' + videometadata
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? imageUrl + '-BREAK-' + uploadTimestamp.toString()
                      : imageUrl + '-BREAK-' + basename(pickedFile!.path).toString();
          onSendMessage(this.context, finalUrl, type, messagetime);
        }
      }).then((value) {
        if (widget.sharedFiles!.last == widget.sharedFiles![index]) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
        } else {
          uploadEach(currentUploadingIndex + 1);
        }
      });
    }
  }

  void loadSavedMessages() {
    if (_savedMessageDocs.isEmpty) {
      Save.getSavedMessages(peerNo).then((_msgDocs) {
        // ignore: unnecessary_null_comparison
        if (_msgDocs != null) {
          setStateIfMounted(() {
            _savedMessageDocs = _msgDocs;
          });
        }
      });
    }
  }

  List<Widget> sortAndGroupSavedMessages(BuildContext context, List<Map<String, dynamic>> _msgs) {
    _msgs.sort((a, b) => a[Dbkeys.timestamp] - b[Dbkeys.timestamp]);
    List<Message> _savedMessages = new List.from(<Message>[]);
    List<Widget> _groupedSavedMessages = new List.from(<Widget>[]);
    _msgs.forEach((msg) {
      _savedMessages.add(Message(buildMessage(context, msg, saved: true, savedMsgs: _savedMessages),
          saved: true, from: msg[Dbkeys.from], onDoubleTap: () {}, onLongPress: () {
        contextMenuForSavedMessage(context, msg);
      },
          onDismiss: null,
          onTap:
              (msg[Dbkeys.from] == widget.currentUserNo && msg[Dbkeys.hasSenderDeleted] == true) == true
                  ? () {}
                  : msg[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  tag: "saved_" + msg[Dbkeys.timestamp].toString(),
                                  imageProvider: msg[Dbkeys.content]
                                          .toString()
                                          .startsWith('http') // See if it is an online or saved
                                      ? CachedNetworkImageProvider(msg[Dbkeys.content])
                                      : Save.getImageFromBase64(msg[Dbkeys.content]).image,
                                  message: msg[Dbkeys.content],
                                ),
                              ));
                        }
                      : null,
          timestamp: msg[Dbkeys.timestamp]));
    });

    _groupedSavedMessages
        .add(Center(child: Chip(label: Text(getTranslated(this.context, 'savedconv')))));

    groupBy<Message, String>(_savedMessages, (msg) {
      return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
    }).forEach((when, _actualMessages) {
      _groupedSavedMessages.add(Center(
          child: Chip(
        label: Text(
          when,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      )));
      _actualMessages.forEach((msg) {
        _groupedSavedMessages.add(msg.child);
      });
    });
    return _groupedSavedMessages;
  }

//-- GROUP BY DATE ---
  List<Widget> getGroupedMessages() {
    List<Widget> _groupedMessages = new List.from(<Widget>[
      Card(
        elevation: 0.5,
        color: Color(0xffFFF2BE),
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.5, right: 4),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xff78754A),
                        size: 14,
                      ),
                    ),
                  ),
                  TextSpan(
                      text: getTranslated(this.context, 'chatencryption'),
                      style: TextStyle(
                          color: Color(0xff78754A),
                          height: 1.3,
                          fontSize: 13,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            )),
      ),
    ]);
    int count = 0;
    groupBy<Message, String>(messages, (msg) {
      return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
    }).forEach((when, _actualMessages) {
      _groupedMessages.add(Center(
          child: Chip(
        backgroundColor: Colors.blue[50],
        label: Text(
          when,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      )));
      _actualMessages.forEach((msg) {
        count++;
        if (unread != 0 && (messages.length - count) == unread! - 1) {
          _groupedMessages.add(Center(
              child: Chip(
            backgroundColor: Colors.blueGrey[50],
            label: Text('$unread' + getTranslated(this.context, 'unread')),
          )));
          unread = 0;
        }
        _groupedMessages.add(msg.child);
      });
    });
    return _groupedMessages.reversed.toList();
  }

  Widget buildSavedMessages(
    BuildContext context,
  ) {
    return Flexible(
        child: ListView(
      padding: EdgeInsets.all(10.0),
      children: _savedMessageDocs.isEmpty
          ? [
              Padding(
                  padding: EdgeInsets.only(top: 200.0),
                  child: Text(getTranslated(this.context, 'nosave'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18)))
            ]
          : sortAndGroupSavedMessages(context, _savedMessageDocs),
      controller: saved,
    ));
  }

  Widget buildMessages(
    BuildContext context,
  ) {
    if (chatStatus == ChatStatus.blocked.index) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          getTranslated(this.context, 'unblock') + ' ${peer![Dbkeys.nickname]}?',
          style: TextStyle(color: fiberchatBlack),
        ),
        actions: <Widget>[
          myElevatedButton(
              color: fiberchatWhite,
              child: Text(
                getTranslated(this.context, 'cancel'),
                style: TextStyle(color: fiberchatBlack),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          myElevatedButton(
              color: fiberchatLightGreen,
              child: Text(
                getTranslated(this.context, 'unblock'),
                style: TextStyle(color: fiberchatWhite),
              ),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
    return Flexible(
        child: chatId == '' || messages.isEmpty || sharedSecret == null
            ? ListView(
                children: <Widget>[
                  Card(),
                  Padding(
                      padding: EdgeInsets.only(top: 200.0),
                      child: sharedSecret == null || isMessageLoading == true
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffD4AF36))),
                            )
                          : Text(getTranslated(this.context, 'sayhi'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatGrey,
                                  fontSize: 18))),
                ],
                controller: realtime,
              )
            : ListView(
                padding: EdgeInsets.all(10.0),
                children: getGroupedMessages(),
                controller: realtime,
                reverse: true,
              ));
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day)
      when = getTranslated(this.context, 'today');
    else if (date.day == now.subtract(Duration(days: 1)).day)
      when = getTranslated(this.context, 'yesterday');
    else
      when = DateFormat.MMMd().format(date);
    return when;
  }

  getPeerStatus(val) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (val is bool && val == true) {
      return getTranslated(this.context, 'online');
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = observer.is24hrsTimeformat == false
              ? DateFormat.jm().format(date)
              : DateFormat('HH:mm').format(date),
          when = getWhen(date);
      return getTranslated(this.context, 'lastseen') + ' $when, $at';
    } else if (val is String) {
      if (val == currentUserNo) return getTranslated(this.context, 'typing');
      return getTranslated(this.context, 'online');
    }
    return getTranslated(this.context, 'loading');
  }

  bool isBlocked() {
    return chatStatus == ChatStatus.blocked.index;
  }

  call(
    BuildContext context,
    bool isvideocall,
  ) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
      currentuseruid: widget.currentUserNo,
      fromDp: myphotoUrl,
      toDp: peer!["photoUrl"],
      fromUID: widget.currentUserNo,
      fromFullname: mynickname,
      toUID: widget.peerNo,
      toFullname: peer!["nickname"],
      context: context,
      isvideocall: isvideocall,
    );
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        // hidekeyboard(this.context);
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return PickupLayout(
      scaffold: Fiberchat.getNTPWrappedWidget(
        WillPopScope(
          onWillPop: isgeneratingSomethingLoader == true
              ? () async {
                  return Future.value(false);
                }
              : isemojiShowing == true
                  ? () {
                      setState(() {
                        isemojiShowing = false;
                        keyboardFocusNode.unfocus();
                      });
                      return Future.value(false);
                    }
                  : () async {
                      setLastSeen();
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                        var currentpeer = Provider.of<CurrentChatPeer>(this.context, listen: false);
                        currentpeer.setpeer(newpeerid: '');
                        if (lastSeen == peerNo)
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionusers)
                              .doc(currentUserNo)
                              .update(
                            {Dbkeys.lastSeen: true},
                          );
                      });

                      return Future.value(true);
                    },
          child: ScopedModel<DataModel>(
            model: _cachedModel,
            child: ScopedModelDescendant<DataModel>(
              builder: (context, child, _model) {
                _cachedModel = _model;
                updateLocalUserData(_model);
                return peer != null
                    ? SafeArea(
                        child: Scaffold(
                          key: _scaffold,
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
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ProfileView(
                                                                peer!,
                                                                widget.currentUserNo,
                                                                _cachedModel,
                                                                widget.prefs)));
                                                  },
                                                  child: Container(
                                                    height: 100,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child: Stack(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment.center,
                                                                child: SizedBox(
                                                                  height: 40,
                                                                  width: 40,
                                                                  child: CachedNetworkImage(
                                                                    imageUrl:
                                                                        peer![Dbkeys.photoUrl] ?? '',
                                                                    imageBuilder:
                                                                        (context, imageProvider) =>
                                                                            Container(
                                                                      height: 40,
                                                                      width: 40,
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.circle,
                                                                        image: DecorationImage(
                                                                            image: imageProvider,
                                                                            fit: BoxFit.cover),
                                                                      ),
                                                                    ),
                                                                    placeholder: (context, url) =>
                                                                        Container(
                                                                      height: 40,
                                                                      width: 40,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: Icon(Icons.person,
                                                                          color: fiberchatGrey
                                                                              .withOpacity(0.5),
                                                                          size: 30),
                                                                    ),
                                                                    errorWidget: (context, url, error) =>
                                                                        Container(
                                                                      height: 40,
                                                                      width: 40,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: Icon(Icons.person,
                                                                          color: fiberchatGrey
                                                                              .withOpacity(0.5),
                                                                          size: 30),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned.fill(
                                                                child: SvgPicture.string(
                                                                  '<svg viewBox="0.0 0.0 67.28 67.28" ><path  d="M 33.63834762573242 67.27748107910156 C 29.0972728729248 67.27748107910156 24.69199752807617 66.38806915283203 20.5449047088623 64.63395690917969 C 16.53929328918457 62.93969345092773 12.94186019897461 60.51418685913086 9.852548599243164 57.42483520507812 C 6.763243198394775 54.33547592163086 4.337770462036133 50.73796844482422 2.64351224899292 46.73224258422852 C 0.8894066214561462 42.58503723144531 0 38.17961502075195 0 33.63834762573242 C 0 29.09726142883301 0.8894066214561462 24.69199562072754 2.64351224899292 20.54490280151367 C 4.337761878967285 16.5393009185791 6.763235092163086 12.9418773651123 9.852548599243164 9.852547645568848 C 12.9418773651123 6.763235092163086 16.5393009185791 4.337761878967285 20.5449047088623 2.64351224899292 C 24.69199752807617 0.8894066214561462 29.09726333618164 5.820766091346741e-11 33.63834762573242 5.820766091346741e-11 C 38.17961502075195 5.820766091346741e-11 42.58503723144531 0.8894066214561462 46.73224258422852 2.64351224899292 C 50.73796844482422 4.337770938873291 54.33547973632812 6.763243675231934 57.42483520507812 9.852547645568848 C 60.51418685913086 12.94186019897461 62.93969345092773 16.53929138183594 64.63395690917969 20.54490280151367 C 66.38806915283203 24.69199562072754 67.27748107910156 29.09727096557617 67.27748107910156 33.63834762573242 C 67.27748107910156 38.17961502075195 66.38806915283203 42.58503723144531 64.63395690917969 46.73224258422852 C 62.93967819213867 50.73796844482422 60.51418304443359 54.33547592163086 57.42483520507812 57.42483520507812 C 54.33547973632812 60.51417922973633 50.73796844482422 62.93967819213867 46.73224258422852 64.63395690917969 C 42.58503723144531 66.38806915283203 38.17961502075195 67.27748107910156 33.63834762573242 67.27748107910156 Z M 33.63834762573242 2.943296670913696 C 16.71304321289062 2.943296670913696 2.943296909332275 16.71304130554199 2.943296909332275 33.63834762573242 C 2.943296909332275 50.5640869140625 16.71304321289062 64.33418273925781 33.63834762573242 64.33418273925781 C 50.5640869140625 64.33418273925781 64.33418273925781 50.5640869140625 64.33418273925781 33.63834762573242 C 64.33418273925781 16.71304130554199 50.5640869140625 2.943296670913696 33.63834762573242 2.943296670913696 Z" fill="#d4af36" fill-opacity="0.3" stroke="none" stroke-width="1" stroke-opacity="0.3" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          Fiberchat.getNickname(peer!)!,
                                                          style: TextStyle(
                                                            fontFamily: 'Open Sans',
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          softWrap: false,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Container(
                                                          width: 12.0,
                                                          height: 12.0,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: const Color(
                                                              0xFF52CC56,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
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
                                                        height: 23, width: 26, child: XDComponent5321()),
                                                    itemBuilder: (context) => [
                                                          PopupMenuItem(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                        opaque: false,
                                                                        pageBuilder: (context, a1, a2) =>
                                                                            XDSettings(
                                                                              currentUserNo:
                                                                                  widget.currentUserNo,
                                                                              prefs: widget.prefs,
                                                                            )));
                                                              },
                                                              child: Text(
                                                                "See Profile",
                                                                style: TextStyle(
                                                                  color: Colors.grey[700],
                                                                ),
                                                              ),
                                                            ),
                                                            value: 1,
                                                          ),
                                                          PopupMenuItem(
                                                            child: InkWell(
                                                              onTap: observer.iscallsallowed == false
                                                                  ? () {
                                                                      Fiberchat.showRationale(
                                                                          getTranslated(this.context,
                                                                              'callnotallowed'));
                                                                    }
                                                                  : () async {
                                                                      await Permissions
                                                                              .cameraAndMicrophonePermissionsGranted()
                                                                          .then((isgranted) {
                                                                        if (isgranted == true) {
                                                                          call(
                                                                            context,
                                                                            false,
                                                                          );
                                                                        } else {
                                                                          Fiberchat.showRationale(
                                                                              getTranslated(
                                                                                  this.context, 'pmc'));
                                                                          Navigator.push(
                                                                              context,
                                                                              new MaterialPageRoute(
                                                                                  builder: (context) =>
                                                                                      OpenSettings()));
                                                                        }
                                                                      }).catchError((onError) {
                                                                        Fiberchat.showRationale(
                                                                            getTranslated(
                                                                                this.context, 'pmc'));
                                                                        Navigator.push(
                                                                            context,
                                                                            new MaterialPageRoute(
                                                                                builder: (context) =>
                                                                                    OpenSettings()));
                                                                      });
                                                                    },
                                                              child: Text(
                                                                "Call",
                                                                style: TextStyle(
                                                                  color: Colors.grey[700],
                                                                ),
                                                              ),
                                                            ),
                                                            value: 2,
                                                          ),
                                                          PopupMenuItem(
                                                            child: InkWell(
                                                              onTap: observer.iscallsallowed == false
                                                                  ? () {
                                                                      Fiberchat.showRationale(
                                                                          getTranslated(this.context,
                                                                              'callnotallowed'));
                                                                    }
                                                                  : () async {
                                                                      await Permissions
                                                                              .cameraAndMicrophonePermissionsGranted()
                                                                          .then((isgranted) {
                                                                        if (isgranted == true) {
                                                                          call(
                                                                            context,
                                                                            true,
                                                                          );
                                                                        } else {
                                                                          Fiberchat.showRationale(
                                                                              getTranslated(
                                                                                  this.context, 'pmc'));
                                                                          Navigator.push(
                                                                              context,
                                                                              new MaterialPageRoute(
                                                                                  builder: (context) =>
                                                                                      OpenSettings()));
                                                                        }
                                                                      }).catchError((onError) {
                                                                        Fiberchat.showRationale(
                                                                            getTranslated(
                                                                                this.context, 'pmc'));
                                                                        Navigator.push(
                                                                            context,
                                                                            new MaterialPageRoute(
                                                                                builder: (context) =>
                                                                                    OpenSettings()));
                                                                      });
                                                                    },
                                                              child: Text(
                                                                "Video Call",
                                                                style: TextStyle(
                                                                  color: Colors.grey[700],
                                                                ),
                                                              ),
                                                            ),
                                                            value: 3,
                                                          ),
                                                          PopupMenuItem(
                                                            child: Text(
                                                              "Send Crypto",
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
                                                                  "Search",
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
                                                                ChatController.block(
                                                                    currentUserNo, peerNo);
                                                              },
                                                              child: Text(
                                                                "Block",
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
                                                                  // pageBuilder: () => XDSettings(),
                                                                ),
                                                              ],
                                                              child: Text(
                                                                "Mute",
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
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                        vertical: 5),
                                                                    child: Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                        color: Colors.grey[700],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                            value: 8,
                                                          ),
                                                        ]),
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
                                          child: Stack(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (context, a1, a2) => ProfileView(
                                                              peer!,
                                                              widget.currentUserNo,
                                                              _cachedModel,
                                                              widget.prefs)));
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                                      child: Fiberchat.avatar(peer, radius: 20),
                                                    ),
                                                    SizedBox(
                                                      width: 7,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(this.context).size.width /
                                                              2.3,
                                                          child: Text(
                                                            Fiberchat.getNickname(peer!)!,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: DESIGN_TYPE == Themetype.whatsapp
                                                                    ? fiberchatWhite
                                                                    : fiberchatBlack,
                                                                fontSize: 17.0,
                                                                fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        chatId != null
                                                            ? Text(
                                                                getPeerStatus(peer![Dbkeys.lastSeen]),
                                                                style: TextStyle(
                                                                    color:
                                                                        DESIGN_TYPE == Themetype.whatsapp
                                                                            ? fiberchatWhite
                                                                            : fiberchatGrey,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w400),
                                                              )
                                                            : Text(
                                                                'loading…',
                                                                style: TextStyle(
                                                                    color:
                                                                        DESIGN_TYPE == Themetype.whatsapp
                                                                            ? fiberchatWhite
                                                                            : fiberchatGrey,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w400),
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Stack(
                                                children: <Widget>[
                                                  // new Container(
                                                  //   decoration:
                                                  //       new BoxDecoration(
                                                  //     color: DESIGN_TYPE ==
                                                  //             Themetype.whatsapp
                                                  //         ? fiberchatChatbackground
                                                  //         : fiberchatWhite,
                                                  //     image:
                                                  //         new DecorationImage(
                                                  //             image:
                                                  // AssetImage(
                                                  //         "assets/images/background.png")
                                                  //                 Image.file(File(peer![
                                                  //                         Dbkeys
                                                  //                             .wallpaper]))
                                                  //                     .image,
                                                  //             fit:
                                                  //                 BoxFit.cover),
                                                  //   ),
                                                  // ),
                                                  PageView(
                                                    children: <Widget>[
                                                      Column(
                                                        children: [
                                                          // List of messages

                                                          buildMessages(context),
                                                          // Input content
                                                          isBlocked()
                                                              ? Container()
                                                              : Platform.isAndroid
                                                                  ? buildInputAndroid(
                                                                      context,
                                                                      isemojiShowing,
                                                                      refreshInput,
                                                                      _keyboardVisible)
                                                                  : buildInputIos(context)
                                                        ],
                                                      ),
                                                      // Column(
                                                      //   children: [
                                                      //     // List of saved messages
                                                      //     buildSavedMessages(context)
                                                      //   ],
                                                      // ),
                                                    ],
                                                  ),

                                                  // Loading
                                                  buildLoading()
                                                ],
                                              ),
                                              buildLoadingThumbnail(),
                                            ],
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
                      )
                    : Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
