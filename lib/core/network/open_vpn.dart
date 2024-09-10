import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gas_track/core/data/shared_pref/shared.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

class OpenVpnService with ChangeNotifier {
  static final OpenVpnService _singleton = OpenVpnService._internal();
  late OpenVPN? openvpn;
  late VpnStatus status;
  VPNStage stage = VPNStage.prepare;

  final storage = Shared();

  OpenVpnService._internal();

  factory OpenVpnService() {
    return _singleton;
  }

  void init() {
    openvpn = OpenVPN(
      onVpnStatusChanged: (data) {
        status = data!;
      },
      onVpnStageChanged: (stage, rawStage) {
        this.stage = stage;

        debugPrint('vpn stage: ${stage.toString()}');
      },
    );

    openvpn!.initialize(
      groupIdentifier: "com.example.gastech_app",
      localizedDescription: 'GasTrackVPN',
    );
  }

  void connect() async {
    try {
      var content = await rootBundle
          .loadString('assets/vpn/pfsense-TCP4-6443-gastech-config.ovpn');

      final cred = await storage.getVpnCredentials();

      if (openvpn!.initialized) {
        openvpn!.connect(
          content,
          'GASTRACK VPN',
          username: cred['user'],
          password: cred['pass'],
          certIsRequired: true,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void connectWithUsernameAndPassword(String username, String password) async {
    try {
      var content = await rootBundle
          .loadString('assets/vpn/pfsense-TCP4-6443-gastech-config.ovpn');

      if (openvpn!.initialized) {
        openvpn!.connect(
          content,
          'GASTRACK VPN',
          username: username,
          password: password,
          certIsRequired: true,
        );

        await storage.saveVpnCredentials(
          username,
          password,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void disconnect() {
    openvpn!.disconnect();
  }
}
