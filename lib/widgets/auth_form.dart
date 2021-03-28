import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String username,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) submitFunction;
  final bool isLoading;

  const AuthForm({Key key, this.submitFunction, this.isLoading})
      : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _userName = '';
  String _userEmail = '';
  String _userPassword = '';

  void _validateForm() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFunction(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: ValueKey('email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'email',
              // border: InputBorder.none,
            ),
            validator: (val) {
              if (val == null || !val.contains('@')) {
                return 'Enter valid email';
              }
              return null;
            },
            onSaved: (newValue) => _userEmail = newValue,
          ),
          if (_isLogin == false)
            TextFormField(
              key: ValueKey('username'),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'username',
                // border: InputBorder.none,
              ),
              validator: (val) {
                if (val == null || val.length < 4) {
                  return 'Enter username 4 characters or more';
                }
                return null;
              },
              onSaved: (newValue) => _userName = newValue,
            ),
          TextFormField(
            key: ValueKey('password'),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'password',
              // border: InputBorder.none,
            ),
            obscureText: true,
            validator: (val) {
              if (val == null || val.length < 7) {
                return 'Enter password 7 characters or more';
              }
              return null;
            },
            onSaved: (newValue) => _userPassword = newValue,
          ),
          SizedBox(height: 20),
          if (widget.isLoading) CircularProgressIndicator(),
          if (!widget.isLoading)
            ElevatedButton(
              child: Text(_isLogin ? 'Login' : 'Signup'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _validateForm,
            ),
          if (!widget.isLoading)
            TextButton(
              child: Text(_isLogin
                  ? 'Create a new acount'
                  : 'I already have an account'),
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
            )
        ],
      ),
    );
  }
}
