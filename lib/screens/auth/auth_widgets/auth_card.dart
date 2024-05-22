import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../helpers/view/dialog/dialog_builder.dart';
import '../../../providers/auth_provider.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final Map<String, String> _authData = {
    'username': '',
    'password': '',
    'url': '',
    'shiftType': 'F',
  };

  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  // final _urlController = TextEditingController();

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // call login
      await Provider.of<AuthProvider>(context, listen: false).login(
        _authData['username']!,
        _authData['password']!,
        _authData['shiftType']!,
      );
    } catch (error) {
      if (!mounted) return;

      DialogBuilder(context).showErrorDialog(error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget customRadioButton(String text, String index) {
    Color primary = Theme.of(context).primaryColor;

    return OutlinedButton(
        onPressed: () {
          setState(() {
            _authData['shiftType'] = index;
          });
        },
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          side: BorderSide(
            color: primary,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          backgroundColor:
              (_authData['shiftType'] == index) ? primary : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: (_authData['shiftType'] == index) ? Colors.white : primary,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);
    ThemeData themeData = Theme.of(context);

    return Container(
      height: 40.h,
      width: 30.w,
      margin: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.w),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: t!.username),
                    keyboardType: TextInputType.name,
                    controller: _usernameController,
                    enabled: _isLoading ? false : true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return t.invalidUsername;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['username'] = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: t.password),
                    obscureText: true,
                    controller: _passwordController,
                    enabled: _isLoading ? false : true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return t.shortPassword;
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 3.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        customRadioButton(t.fuel, 'F'),
                        customRadioButton(t.gas, 'G'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ButtonStyle(
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 1.h,
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          themeData.primaryColor,
                        ),
                      ),
                      child: Text(
                        t.login,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .labelLarge
                              ?.color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
