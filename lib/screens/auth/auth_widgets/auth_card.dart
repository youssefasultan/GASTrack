import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../helpers/data/data_constants.dart';
import '../../../helpers/data/shared.dart';
import '../../../models/http_exception.dart';
import '../../../helpers/view/dialog_builder.dart';
import '../../../providers/auth_provider.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;

  final Map<String, String> _authData = {
    'username': '',
    'password': '',
    'url': '',
    'shiftType': 'F',
  };

  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _urlController = TextEditingController();

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    var settings = await Shared.getSettings();

    if (!mounted) return;

    var t = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    if (_authData['username'] == 'EcsAdmin' &&
        _authData['password'] == 'Ecs@2023') {
      _switchAuthMode();
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_authMode == AuthMode.login) {
          if (settings['ip']!.isEmpty) {
            throw HttpException(t!.notRegestered);
          }

          // call login
          await Provider.of<AuthProvider>(context, listen: false).login(
            _authData['username']!,
            _authData['password']!,
            _authData['shiftType']!,
          );
        } else if (_authMode == AuthMode.admin) {
          // call register
          await Provider.of<AuthProvider>(context, listen: false).register(
            _authData['username']!,
            _authData['password']!,
            _authData['url']!,
          );

          _switchAuthMode();
        }
      } catch (error) {
        if (!mounted) return;

        DialogBuilder(context).showErrorDialog(error.toString());
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() async {
    var settings = await Shared.getSettings();
    // switch between Auth Mode
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.admin;
      });
      if (settings['ip']!.isNotEmpty && settings['ip'] != 'null') {
        _usernameController.text = settings['username']!;
        _passwordController.text = settings['password']!;
        _urlController.text = settings['ip']!;
      }
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });

      _usernameController.clear();
      _passwordController.clear();
    }
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
    final deviceSize = MediaQuery.of(context).size;
    var t = AppLocalizations.of(context);
    ThemeData themeData = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 320,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                _authMode == AuthMode.admin
                    ? TextFormField(
                        enabled: _authMode == AuthMode.admin,
                        decoration: InputDecoration(labelText: t.url),
                        controller: _urlController,
                        validator: (value) {
                          if (value!.isEmpty && _authMode == AuthMode.admin) {
                            return t.enterUrl;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['url'] = value!;
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            customRadioButton(t.fuel, 'F'),
                            customRadioButton(t.gas, 'G'),
                          ],
                        )),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 8.0,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        themeData.primaryColor,
                      ),
                    ),
                    child: Text(
                      _authMode == AuthMode.login ? t.login : t.register,
                      style: TextStyle(
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
    );
  }
}
