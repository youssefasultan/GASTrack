import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../helpers/data/constants.dart';
import '../helpers/data/shared.dart';
import '../models/http_exception.dart';
import '../providers/auth.dart';
import '../helpers/view/dialog_builder.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  final Map<String, String> _authData = {
    'username': '',
    'password': '',
    'url': '',
    'shiftType': '',
  };

  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _urlController = TextEditingController();

  var _isLoading = false;

  List<String> listOfValue = ['F', 'G'];

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
        if (_authMode == AuthMode.Login) {
          if (settings['ip']!.isEmpty) {
            throw HttpException(t!.notRegestered);
          }

          // call login
          await Provider.of<Auth>(context, listen: false).login(
            _authData['username']!,
            _authData['password']!,
            _authData['shiftType']!,
          );
        } else if (_authMode == AuthMode.Admin) {
          // call register
          await Provider.of<Auth>(context, listen: false).register(
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
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Admin;
      });
      if (settings['ip']!.isNotEmpty && settings['ip'] != 'null') {
        _usernameController.text = settings['username']!;
        _passwordController.text = settings['password']!;
        _urlController.text = settings['ip']!;
      }
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });

      _usernameController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var t = AppLocalizations.of(context);

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
                _authMode == AuthMode.Admin
                    ? TextFormField(
                        enabled: _authMode == AuthMode.Admin,
                        decoration: InputDecoration(labelText: t.url),
                        controller: _urlController,
                        validator: (value) {
                          if (value!.isEmpty && _authMode == AuthMode.Admin) {
                            return t.enterUrl;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['url'] = value!;
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3.0,
                          vertical: 8.0,
                        ),
                        child: DropdownButtonFormField(
                          value: _authData['shiftType']!.isEmpty
                              ? null
                              : _authData['shiftType'],
                          hint: Text(t.shiftTypeHint),
                          items: listOfValue
                              .map((val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(
                                      val == "F" ? t.fuel : t.gas,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _authData['shiftType'] = value!;
                            });
                          },
                          onSaved: (value) {
                            setState(() {
                              _authData['shiftType'] = value!;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty && _authMode == AuthMode.Login) {
                              return t.shiftTypeHint;
                            }
                            return null;
                          },
                        ),
                      ),
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
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text(
                      _authMode == AuthMode.Login ? t.login : t.register,
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
