import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trakt_dart/trakt_dart.dart';

import '../services/cancellation_token.dart';
import '../services/token_service.dart';
import '../services/trakt_client.dart';
import '../theme/theme_colors.dart';

class DeviceCodeState {
  String userCode = "";

  String verificationUrl = "";

  int expiresIn = 0;

  CancellationToken cancellationToken = CancellationToken();
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.title, required this.traktClient, required this.tokenService});

  final String title;

  final TraktClient traktClient;

  final TokenService tokenService;

  Future<DeviceCodeState> _getDeviceCode(BuildContext context) async {
    var state = DeviceCodeState();
    state.cancellationToken.reset();
    final DeviceCodeResponse res = await traktClient.getDeviceCodes();
    state.userCode = res.userCode;
    state.expiresIn = res.expiresIn;
    state.verificationUrl = "${res.verificationUrl}/${res.userCode}";
    Future<AccessTokenResponse> completer = traktClient.pollDevice(
        state.cancellationToken, res.deviceCode, state.expiresIn);
    completer.then((res) {
      tokenService.setAccessToken(res.accessToken);
      tokenService.setRefreshToken(res.refreshToken);
      // go back to the login screen
      Navigator.pop(context);
    });
    completer.catchError((error) {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return state;
  }

  Widget LoginDetails(DeviceCodeState? deviceCodeState) {
    if (deviceCodeState == null) {
      return const Center(child: Text("An error has occurred: empty device code state."));
    }
    return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.
      spaceEvenly,
          children: [
            Column(children: [
              const Row(children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    child:
                    _HeaderText()),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        _CodeContainer(
                            deviceCode: deviceCodeState.userCode),
                      ])),
                  Column(children: [
                    _QRContainer(
                        verificationUrl: deviceCodeState.verificationUrl),
                  ])
                ],
              ),
            ])
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: ThemeColors.backgroundColor,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: ThemeColors.accentColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: FutureBuilder<DeviceCodeState>(
        future: _getDeviceCode(context),
        builder: (buildContext, snapshot) {
          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var deviceCodeState = snapshot.data;
          return LoginDetails(deviceCodeState);
        },
      )
    );
  }


// @override
// State<LoginPage> createState() => _LoginPageState(traktClient: traktClient);
}



// class _LoginPageState extends State<LoginPage> {
//   _LoginPageState({required this.traktClient});
//
//   final TraktClient traktClient;
//
//   CancellationToken cancellationToken = new CancellationToken();
//
//   String userCode = "";
//
//   String verificationUrl = "";
//
//   int expiresIn = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     getDeviceCode();
//   }
//


//}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
          "Navigate to the URL below and enter the code on your TV to login.",
          style: TextStyle(fontSize: 20, color: Colors.white)
      ),
    );
  }
}

class _CodeContainer extends StatelessWidget {
  _CodeContainer({required this.deviceCode});

  String deviceCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
          deviceCode,
          style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white)
      ),
    );
  }
}

class _QRContainer extends StatelessWidget {
  _QRContainer({required this.verificationUrl});

  String verificationUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Center(
                  child: QrImageView(
                    data: verificationUrl,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white
                  ),
                ),
              ],
            ),
            const Row(children: [
              Text("Scan Code to Login"),
            ]),
            Row(children: [
              Text(verificationUrl, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, color: Colors.white))
            ]),
          ],
        ),
      ],
    );
  }
}
