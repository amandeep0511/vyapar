import 'package:flutter/material.dart';
import '../model/auth.dart';

import '../scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthPageSate();
  }
}

class _AuthPageSate extends State<AuthPage> {
  String _emailValue = "";
  String _passwordValue = "";
  bool _acceptTerms = false;

  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'name': null,
    'desgn': null,
    'phone': null,
    'acceptTerms': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      image: AssetImage('assets/background.jpg'),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          labelText: "Confirm Password",
          filled: true,
          fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (value != _passwordTextController.text) {
          return "Password do not match";
        }
      },
    );
  }

  Widget _buildEmailTextFiled() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          prefixStyle:
              TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          labelText: "Email Address",
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid Name';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPhoneTextFiled() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          labelText: "Mobile Number",
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid Name';
        }
      },
      onSaved: (String value) {
        _formData['phone'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.security),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          labelText: "Password",
          filled: true,
          fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid Name';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildNameTextFiled() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          labelText: "Name",
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid Name';
        }
      },
      onSaved: (String value) {
        _formData['name'] = value;
      },
    );
  }

  Widget _buildDesignationTextFiled() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.list),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          labelText: "Designation",
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a Designation';
        }
      },
      onSaved: (String value) {
        _formData['desgn'] = value;
      },
    );
  }

  Widget _buildSwitchTile() {
    return SwitchListTile(
      value: _acceptTerms,
      onChanged: (bool value) {
        setState(() {
          _acceptTerms = value;
        });
      },
      title: Text(
        "Accept Terms",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _submitSignup(Function signUp) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    print("!st case");

    Map<String, dynamic> successInformation;

    successInformation = await signUp(_formData['email'], _formData['password'],
        _formData['name'], _formData['desgn'], _formData['phone']);
    print("@nd case");

    if (successInformation['success']) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("An error Occured!!"),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: Navigator.of(context).pop,
                )
              ],
            );
          });
    }
  }

  void _submitLogin(Function login) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    print("!st case");

    Map<String, dynamic> successInformation;

    successInformation = await login(
      _formData['email'],
      _formData['password'],
    );
    print("@nd case");

    if (successInformation['success']) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("An error Occured!!"),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: Navigator.of(context).pop,
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    // TODO: implement build
    return ScopedModel<MainModel>(
        model: new MainModel(),
        child: Container(
          decoration: BoxDecoration(image: _buildBackgroundImage()),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                  // decoration: BoxDecoration(image: _buildBackgroundImage()),
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                      child: SingleChildScrollView(
                          child: Container(
                    width: targetWidth,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _authMode == AuthMode.Signup
                              ? _buildNameTextFiled()
                              : Container(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _authMode == AuthMode.Signup
                              ? _buildDesignationTextFiled()
                              : Container(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildEmailTextFiled(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _authMode == AuthMode.Signup
                              ? _buildPhoneTextFiled()
                              : Container(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildPasswordTextField(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _authMode == AuthMode.Signup
                              ? _buildConfirmPasswordTextField()
                              : Container(),
                          FlatButton(
                            child: Text(
                              'Switch to  ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            onPressed: () {
                              setState(() {
                                _authMode = _authMode == AuthMode.Login
                                    ? AuthMode.Signup
                                    : AuthMode.Login;
                              });
                            },
                          ),
                          //_buildSwitchTile(),
                          ScopedModelDescendant<MainModel>(
                            builder: (BuildContext context, Widget child,
                                MainModel model) {
                              return model.isLoading
                                  ? CircularProgressIndicator()
                                  : ButtonTheme(
                                      minWidth: 200.0,
                                      height: 15.0,
                                      padding: const EdgeInsets.all(20.0),
                                      child: RaisedButton(
                                        child: _authMode == AuthMode.Login
                                            ? Text(
                                                "Login",
                                                style: TextStyle(
                                                    color: Colors.deepOrange),
                                              )
                                            : Text(
                                                'Signup',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                        color: Colors.yellow,
                                        splashColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        onPressed: () =>
                                            _authMode == AuthMode.Signup
                                                ? _submitSignup(model.signUp)
                                                : _submitLogin(model.logIn),
                                      ));
                            },
                          )
                        ],
                      ),
                    ),
                  ))))),
        ));
  }
}
