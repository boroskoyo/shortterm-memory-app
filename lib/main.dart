import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DoneDone',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const LockStatusPage(),
    );
  }
}

class LockStatusPage extends StatefulWidget {
  const LockStatusPage({Key? key}) : super(key: key);

  @override
  State<LockStatusPage> createState() => _LockStatusPageState();
}

class _LockStatusPageState extends State<LockStatusPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _lastUpdateTime;
  bool _isElevated = true;

  Future<void> _lockDoor() async {
    final SharedPreferences prefs = await _prefs;
    final bool isElevated = !(prefs.getBool('elevated') ?? true);
    final String lastUpdateTime =
        DateFormat('MMM d, yyyy HH:MM:SS').format(DateTime.now()).toString();
    ;
    setState(() {
      _lastUpdateTime =
          prefs.setString('lastUpdate', lastUpdateTime).then((bool success) {
        return lastUpdateTime;
      });
      _isElevated = !_isElevated;
    });
  }

  @override
  void initState() {
    super.initState();
    _lastUpdateTime = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('lastUpdate') ?? "none";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(children: <Widget>[
          const Spacer(flex: 1),
          FutureBuilder<String>(
              future: _lastUpdateTime,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text('${snapshot.data}');
                    }
                }
              }),
          const Spacer(flex: 1),
          GestureDetector(
              onLongPress: () {
                setState(() {
                  _lockDoor();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: _isElevated == true
                      ? [
                          const BoxShadow(
                            color: Colors.grey,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-4, -4),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: const Icon(
                  Icons.key,
                  size: 48,
                  color: Color.fromARGB(255, 85, 84, 84),
                ),
              )),
          const Spacer()
        ]),
      ),
    );
  }
}
