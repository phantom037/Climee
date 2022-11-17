import 'dart:convert';
import 'package:clima/utilities/constants.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:clima/screens/loading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Climee());
}

class Climee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasInternet = true;
  @override
  void initState() {
    super.initState();
    //Check Internet Connection
    InternetConnectionChecker().onStatusChange.listen((event) {
      final hasInternet = event == InternetConnectionStatus.connected;
      setState(() {
        this.hasInternet = hasInternet;
      });
    });
    checkVersion();
  }

  void checkVersion() async {
    var url = Uri.parse('https://dlmocha.com/app/appUpdate.json');
    http.Response response = await http.get(url);
    var update = jsonDecode(response.body)['Climee']['version'];
    var version = "2.0.1";
    final newVersion = NewVersion(
      iOSId: 'co.leotran9x.clima',
      androidId: 'co.leotran9x.climee',
    );
    final status = await newVersion.getVersionStatus();
    if (update != version) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dismissButtonText: "Skip",
        dialogTitle: 'New Version Available',
        dialogText:
            'The new app version $update is available now. Please update to have a better experience.'
            '\nIf you already updated please skip.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: hasInternet
          ? LoadingScreen()
          : Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                child: Text(
                  "No Internet Connection 😭",
                  style: kDetailTextStyleLarge,
                ),
              ),
            ),
    );
  }
}
