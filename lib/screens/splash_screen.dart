import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saras/screens/login_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();

    Timer(Duration(seconds: 2), () {
      checkVersionAndNavigate();
    });
  }

  Future<void> checkVersionAndNavigate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentAppVersion = packageInfo.version;

      print('currentAppVersion version =========$currentAppVersion');

      final response = await http.get(
        Uri.parse('http://183.83.176.150:81/api/GetAppVersion'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          final String latestAppVersion = responseData.first['versionNo'];

          print('latest version =========$latestAppVersion');

          if (currentAppVersion != latestAppVersion) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Update Required'),
                  content: Text(
                      'A new version of the app is available. Please update to continue.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Handle navigation to the app store for update
                        // e.g., launch URL or use in-app update mechanisms
                      },
                      child: Text('Update'),
                    ),
                  ],
                );
              },
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        } else {
          throw Exception('Version data not found in response');
        }
      } else {
        throw Exception('Failed to load version info');
      }
    } catch (e) {
      print('Error: $e');
      // Handle errors here
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/splash.jpeg',
              height: 150,
              width: 150,
            ),
          ),
        ),
      ),
    );
  }
}
