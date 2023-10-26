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
  };

  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _urlController = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _slidAnimation;
  late Animation<double> _opacityAnimation;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _slidAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });

      // Clear username and password TextFormFields

      _controller.reverse();
    }
    _usernameController.clear();
    _passwordController.clear();
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
      child: AnimatedContainer(
        duration: const Duration(microseconds: 400),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Admin ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Admin ? 320 : 260),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Admin ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Admin ? 120 : 0,
                  ),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slidAnimation,
                      child: TextFormField(
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
                      ),
                    ),
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
