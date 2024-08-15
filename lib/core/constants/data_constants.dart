// enums
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AuthMode { admin, login }

const String vNo = '0.1.0.21';

const String ipAddress = '10.30.1.3';
const String ipAddressTest = '20.245.129.201';

String kUsername = dotenv.env['SAP_USER']!;
String kPassword = dotenv.env['SAP_PASS']!;



