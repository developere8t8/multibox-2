import 'package:flutter/material.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';

class VpnSetup extends StatefulWidget {
  const VpnSetup({Key? key}) : super(key: key);

  @override
  State<VpnSetup> createState() => _VpnSetupState();
}

class _VpnSetupState extends State<VpnSetup> {
  var state = FlutterVpnState.disconnected;
  CharonErrorState? charonState = CharonErrorState.NO_ERROR;
  bool isConnected = false;

  void connectVpn() {
    FlutterVpn.connectIkev2EAP(
      server: '143.110.229.255',
      username: 'openvpn',
      password: '861770',
    );
  }

//https://www.vpnbook.com/freevpn
//abend861770Utx
  void disconnectVpn() {
    FlutterVpn.connectIkev2EAP(
      server: '143.110.229.255',
      username: 'openvpn',
      password: '861770',
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((s) => setState(() => state = s));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 42),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back_rounded)),
                            Text(
                              isConnected == true
                                  ? 'Connected'
                                  : 'Disconnected',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Image.asset(
                            'assets/images/vpnsignal.png',
                            scale: 2.5,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Image.asset('assets/images/map.png'),
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!isConnected) {
                      connectVpn();
                      isConnected = true;
                    } else {
                      disconnectVpn();
                      isConnected = false;
                    }
                  },
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: !isConnected ? Colors.green : Colors.redAccent,
                    size: 38,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff173051),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(24),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Developed by harsha for demo to Zaid Hamid',
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          )
        ],
      )),
    );
  }
}
