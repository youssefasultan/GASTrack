import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

class OpenVpnService with ChangeNotifier {
  late OpenVPN openvpn;
  late VpnStatus status;
  late VPNStage stage;

  OpenVpnService();

  void init() {
    openvpn = OpenVPN(
      onVpnStatusChanged: (data) {
        status = data!;
        // debugPrint('vpn status : ${status.toString()}');
      },
      onVpnStageChanged: (stage, rawStage) {
        this.stage = stage;
        notifyListeners();
        debugPrint('vpn stage: ${stage.toString()}');
      },
    );

    openvpn.initialize(
      groupIdentifier: "com.example.gastech_app",
      localizedDescription: 'GasTrackVPN',
    );
  }

  void connect() async {
    try {
      var content = await rootBundle
          .loadString('assets/vpn/pfsense-TCP4-6443-gastech-config.ovpn');
      if (openvpn.initialized) {
        openvpn.connect(
          content,
          'GASTRACK VPN',
          username: dotenv.env['VPN_USER']!,
          password: dotenv.env['VPN_PASS']!,
          certIsRequired: true,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void disconnect() {
    openvpn.disconnect();
  }
}
