import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_ui/l10n/localization.dart';

enum ProvidersTypes { email, google, facebook, phone }

final GoogleSignIn googleSignIn = new GoogleSignIn();
final FacebookLogin facebookLogin = new FacebookLogin();

ProvidersTypes stringToProvidersType(String value) {
  if (value.toLowerCase().contains('facebook')) return ProvidersTypes.facebook;
  if (value.toLowerCase().contains('google')) return ProvidersTypes.google;
  if (value.toLowerCase().contains('password')) return ProvidersTypes.email;
//TODO  if (value.toLowerCase().contains('phone')) return ProvidersTypes.phone;
  return null;
}

// Description button
class ButtonDescription extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color color;
  final String logo;
  final String name;
  final VoidCallback onSelected;

  const ButtonDescription(
      {@required this.logo,
      @required this.label,
      @required this.name,
      this.onSelected,
      this.labelColor = Colors.grey,
      this.color = Colors.white});

  ButtonDescription copyWith({
    String label,
    Color labelColor,
    Color color,
    String logo,
    String name,
    VoidCallback onSelected,
  }) {
    return new ButtonDescription(
        label: label ?? this.label,
        labelColor: labelColor ?? this.labelColor,
        color: color ?? this.color,
        logo: logo ?? this.logo,
        name: name ?? this.name,
        onSelected: onSelected ?? this.onSelected);
  }

  @override
  Widget build(BuildContext context) {
    VoidCallback _onSelected = onSelected ?? () => {};
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double widthUnit = mediaQuery.size.height / 14;
    double heightUnit = mediaQuery.size.width / 53;
    return ButtonTheme(
        height: 41,
        child:
          RaisedButton(
        padding: EdgeInsets.all(0),
        color: color,
        child: Container(
          height: 41,
          width: 225,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Image.asset('assets/$logo', package: 'firebase_ui', height: 20, width: 20,)
                  ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
                ),
              )
            ],
        ),
      ),
      onPressed: _onSelected
      ),
    );
  }
}

Map<ProvidersTypes, ButtonDescription> providersDefinitions(
        BuildContext context) =>
    {
      ProvidersTypes.facebook: new ButtonDescription(
          color: const Color.fromRGBO(59, 87, 157, 1.0),
          logo: "fb-logo.png",
          label: FFULocalizations.of(context).signInFacebook,
          name: "Facebook",
          labelColor: Colors.white),
      ProvidersTypes.google: new ButtonDescription(
          color: Colors.white,
          logo: "go-logo.png",
          label: FFULocalizations.of(context).signInGoogle,
          name: "Google",
          labelColor: Colors.grey),
      ProvidersTypes.email: new ButtonDescription(
          color: const Color.fromRGBO(219, 68, 55, 1.0),
          logo: "email-logo.png",
          label: FFULocalizations.of(context).signInEmail,
          name: "Email",
          labelColor: Colors.white),
    };

Future<Null> showErrorDialog(BuildContext context, String message,
    {String title}) {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) => new AlertDialog(
          title: title != null ? new Text(title) : null,
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(message ?? FFULocalizations.of(context).errorOccurred),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Row(
                children: <Widget>[
                  new Text(FFULocalizations.of(context).cancelButtonLabel),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
  );
}

Future<void> signOutProviders() async {
  var currentUser = await FirebaseAuth.instance.currentUser();
  if (currentUser != null) {
    await signOut(currentUser.providerData);
  }

  return await FirebaseAuth.instance.signOut();
}

Future<dynamic> signOut(Iterable providers) async {
  return Future.forEach(providers, (p) async {
    switch (p.providerId) {
      case 'facebook.com':
        await facebookLogin.logOut();
        break;
      case 'google.com':
        await googleSignIn.signOut();
        break;
    }
  });
}
