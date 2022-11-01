import 'dart:async';
import 'dart:core';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/Passcode/passcode_screen.dart';

class Security extends StatefulWidget {
  final String? phoneNo, answer, title;
  final bool setPasscode, shouldPop;
  final SharedPreferences prefs;
  final Function onSuccess;

  Security(this.phoneNo,
      {this.shouldPop = false,
      this.setPasscode = false,
      this.answer,
      required this.title,
      required this.prefs,
      required this.onSuccess});

  @override
  _SecurityState createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? _passCode;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(this.context).size.width;
    var height = MediaQuery.of(this.context).size.height;
    return Fiberchat.getNTPWrappedWidget(
      WillPopScope(
        onWillPop: () {
          return Future.value(widget.shouldPop);
        },
        child: SafeArea(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: const Color(0xffffffff),
                body: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: SizedBox(
                      height: height,
                      width: width,
                      child: Stack(
                        children: <Widget>[
                          const Align(
                            alignment: Alignment(0.005, -0.119),
                            child: SizedBox(
                              width: 166.0,
                              height: 30.0,
                              child: Text(
                                'Security Code',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 22,
                                  color: Color(0xff173051),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: false,
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment(-0.004, 0.05),
                            child: Text(
                              'Create a Security Code, \nthis code will be request \nevery time you sign in.',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 18,
                                color: Color(0xff173051),
                                letterSpacing: 0.36,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(-0.004, -0.433),
                            child: SizedBox(
                                width: 128.0,
                                height: 128.0,
                                child: Image.asset('assets/images/lock.png')),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          // Align(
                          //     alignment: const Alignment(0.003, 0.3),
                          //     child: Container(
                          //       width: 320.0,
                          //       height: 47.0,
                          //       decoration: BoxDecoration(
                          //         color: const Color(0xffefeff2),
                          //         borderRadius: BorderRadius.circular(24.0),
                          //         border: Border.all(
                          //             width: 1.0,
                          //             color: const Color(0xffe1e1e5)),
                          //       ),
                          //       child: Center(
                          //         child: TextField(
                          //           maxLines: 1,
                          //           textAlign: TextAlign.center,
                          //           decoration: InputDecoration(
                          //               border: OutlineInputBorder(
                          //                 borderRadius:
                          //                     BorderRadius.circular(24.0),
                          //               ),
                          //               hintStyle: TextStyle(
                          //                 fontFamily: 'Open Sans',
                          //                 fontSize: 19,
                          //                 color: Colors.black.withOpacity(0.7),
                          //               ),
                          //               hintText: "Code",
                          //               disabledBorder: InputBorder.none,
                          //               enabledBorder: InputBorder.none),
                          //         ),
                          //       ),
                          //     )),
                          Align(
                            alignment: const Alignment(0.003, 0.47),
                            child: InkWell(
                              onTap: () {
                                if (widget.setPasscode) {
                                  if (_passCode == null)
                                    _showLockScreen();
                                  else if (_passCode != null) {
                                    var data = {
                                      Dbkeys.passcode:
                                          Fiberchat.getHashedString(_passCode!)
                                    };
                                    setState(() {
                                      isLoading = true;
                                    });
                                    widget.prefs
                                        .setInt(Dbkeys.passcodeTries, 0);
                                    widget.prefs.setInt(Dbkeys.answerTries, 0);
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionusers)
                                        .doc(widget.phoneNo)
                                        .update(data)
                                        .then((_) {
                                      Fiberchat.toast(getTranslated(
                                              this.context, 'welcometo') +
                                          ' $Appname!');
                                      widget.onSuccess(this.context);
                                    });
                                  }
                                  widget.prefs.setString(
                                      Dbkeys.isSecuritySetupDone,
                                      widget.phoneNo!);
                                } else {
                                  if (_formKey.currentState!.validate()) {
                                    var data = {};
                                    setState(() {
                                      isLoading = true;
                                    });
                                    widget.prefs
                                        .setInt(Dbkeys.passcodeTries, 0);
                                    widget.prefs.setInt(Dbkeys.answerTries, 0);
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionusers)
                                        .doc(widget.phoneNo)
                                        .update(data as Map<String, Object?>)
                                        .then((_) {
                                      widget.onSuccess(this.context);
                                    });
                                  }
                                  widget.prefs.setString(
                                      Dbkeys.isSecuritySetupDone,
                                      widget.phoneNo!);
                                }
                              },
                              child: Container(
                                width: 320.0,
                                height: 47.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22.0),
                                  color: const Color(0xFFD4AF36),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
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
                                        _passCode == null
                                            ? 'Set Code'
                                            : 'Proceed',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(fiberchatBlue)),
                        ),
                        color: fiberchatBlack.withOpacity(0.8))
                    : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = enteredPasscode.length == 4;
    _verificationNotifier.add(isValid);
    _passCode = null;
    if (isValid)
      setState(() {
        _passCode = enteredPasscode;
      });
  }

  _showLockScreen() {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            prefs: widget.prefs,
            onSubmit: null,
            wait: true,
            authentication: false,
            passwordDigits: 4,
            title: (getTranslated(this.context, 'enterpass')),
            passwordEnteredCallback: _onPasscodeEntered,
            cancelLocalizedText: getTranslated(this.context, 'cancel'),
            deleteLocalizedText: getTranslated(this.context, 'delete'),
            shouldTriggerVerification: _verificationNotifier.stream,
          ),
        ));
  }
}
