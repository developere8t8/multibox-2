import 'package:fiberchat/Configs/Enum.dart';
import 'package:flutter/material.dart';

//*--App Colors : Replace with your own colours---
//-**********---------- Multibox Color Theme: -------------------------
final multiboxMainColor = Color(0xFF173051);
final fiberchatBlack = Color(0xFF1E1E1E);
final fiberchatBlue = Color(0xFFD4AF36);
// final multiboxMainColor =  Color(0xFF01826b);
final fiberchatLightGreen = Color(0xFFD4AF36);
// final multiboxMainColor =  Color(0xFF01826b);
final fiberchatteagreen = Color(0xFFe9fedf);
final fiberchatWhite = Colors.white;
final fiberchatGrey = Color(0xff85959f);
final fiberchatChatbackground = new Color(0xffe8ded5);
const DESIGN_TYPE = Themetype.whatsapp;
const IsSplashOnlySolidColor = false;
const SplashBackgroundSolidColor = Color(
    0xFFD4AF36); //applies this colors if "IsSplashOnlySolidColor" is set to true. Color Code: 0xFF005f56 for Whatsapp theme & 0xFFFFFFFF for messenger theme.

//-*********---------- MESSENGER Color Theme: ---------------// Remove below comments for Messenger theme //------------
// final fiberchatBlack = new Color(0xFF353f58);
// final fiberchatBlue = new Color(0xFF3d9df5);
// final multiboxMainColor = new Color(0xFF296ac6);
// final fiberchatLightGreen = new Color(0xFF036eff);
// final multiboxMainColor = new Color(0xFF06a2ff);
// final fiberchatteagreen = new Color(0xFFe0eaff);
// final fiberchatWhite = Colors.white;
// final fiberchatGrey = Colors.grey;
// final fiberchatChatbackground = new Color(0xffdde6ea);
// const DESIGN_TYPE = Themetype.messenger;
// const IsSplashOnlySolidColor = false;
// const SplashBackgroundSolidColor = Color(
//     0xFFFFFFFF); //applies this colors if "IsSplashOnlySolidColor" is set to true. Color Code: 0xFF005f56 for Whatsapp theme & 0xFFFFFFFF for messenger theme.

//*--Agora Configurations---
const Agora_APP_IDD =
    'da95cb613c944f9fa4222510f2e25a04'; // Grab it from: https://www.agora.io/en/
const dynamic Agora_TOKEN =
    null; // not required until you have planned to setup high level of authentication of users in Agora.

//*--Giphy Configurations---
const GiphyAPIKey =
    'PASTE_YOUR_GIPHY_API_KEY_HERE'; // Grab it from: https://developers.giphy.com/

//*--App Configurations---
const Appname =
    'Multiapp'; //app name shown evrywhere with the app where required
const DEFAULT_COUNTTRYCODE_ISO =
    'US'; //default country ISO 2 letter for login screen
const DEFAULT_COUNTTRYCODE_NUMBER =
    '+1'; //default country code number for login screen
const FONTFAMILY_NAME =
    'Open Sans'; // make sure you have registered the font in pubspec.yaml

//--WARNING----- PLEASE DONT EDIT THE BELOW LINES UNLESS YOU ARE A DEVELOPER -------
const SplashPath = 'assets/images/splash.jpeg';
const AppLogoPath = 'assets/images/applogo.png';
