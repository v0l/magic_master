import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import 'karaoke_config.dart';

class QRScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanner();
}

class _QRScanner extends State<QRScanner> {
  bool wasPoped = false;
  String _lastScan;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return SizedBox(
      width: mq.size.width,
      height: mq.size.height,
      child: QrCamera(
        notStartedBuilder: (context) {
          return SizedBox.shrink();
        },
        qrCodeCallback: (code) {
          if (!wasPoped) {
            final kc = KaraokeConfig.fromJson(code);
            if (kc != null) {
              wasPoped = true;
              Navigator.pop<KaraokeConfig>(context, kc);
            } else if (_lastScan != code) {
              //show invalid json msg
              _lastScan = code;
            }
          }
        },
      ),
    );
  }
}

class QRScannerOverlay extends ModalRoute<KaraokeConfig> {
  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return QRScanner();
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => Duration.zero;
}
