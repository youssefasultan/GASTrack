import 'package:flutter/material.dart';
import 'package:gas_track/core/data/shared_pref/shared.dart';
import 'package:gas_track/core/extentions/context_ext.dart';
import 'package:gas_track/core/network/open_vpn.dart';
import 'package:gas_track/features/auth/view/auth_screen.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:sizer/sizer.dart';

import '../constants/ui_constants.dart';

class VpnScreen extends StatelessWidget {
  VpnScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  final shared = Shared();
  final vpn = OpenVpnService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate.vpnCred,
                style: TextStyle(fontSize: 12.sp, color: blueColor),
              ),
              SizedBox(height: 2.h),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: context.translate.username,
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return context.translate.invalidUsername;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: context.translate.password,
                      ),
                      keyboardType: TextInputType.name,
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          // password validation
                          return context.translate.shortPassword;
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          // init vpn and connect
                          vpn.init();
                          vpn.connectWithUsernameAndPassword(
                            usernameController.text,
                            passwordController.text,
                          );

                          if (!context.mounted) return;
                          context.dialogBuilder.showLoadingIndicator('');
                          // wait for vpn to connect
                          await Future.delayed(
                            const Duration(seconds: 10),
                            () {
                              context.dialogBuilder.hideOpenDialog();
                            },
                          );
                          if (!context.mounted) return;
                          if (vpn.stage == VPNStage.connected) {
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                                context, AuthScreen.routeName);
                          } else {
                            context.dialogBuilder
                                .showSnackBar(context.translate.vpnError);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(context.translate.confirm),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
