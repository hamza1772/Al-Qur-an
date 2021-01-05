import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Center(
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Show translation'),
                  Text('Qur\'an font'),
                  Text('Translation font'),
                  Text('Quran font-size'),
                  Text('Translation font-size'),
                  Text('Theme'),
                  Text('Theme'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
