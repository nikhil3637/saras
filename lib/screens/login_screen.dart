import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saras/constants/colors.dart';
import 'package:saras/screens/homepage.dart';
import 'package:saras/screens/visit_in.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();

  seeUniqueId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;
    if (Theme
        .of(context)
        .platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: Text(deviceId!)
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue.shade300,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage(
                          'assets/images/saraslogo.png'), // Adjust path to your logo
                    ),
                    Text(
                      'Welcome to Saras Dairy',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'MobileNo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(

                  ),
                  onPressed: () {
                    loginUser(_mobileController.text);
                  },
                  child: Text('Login', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser(mobileNo) async {
    // Show a loading indicator

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;
    if (Theme
        .of(context)
        .platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
    print('device id =========$deviceId');

    // String uuid = Uuid().v4();
    // print('UUID: ============= $uuid');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: CircularProgressIndicator()
        );
      },
    );

    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'MobileNo': mobileNo.toString(),
        'MobileKey': deviceId.toString()
      }),
    );

    // Close loading indicator dialog
    Navigator.pop(context);
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List) {
        // User exists, proceed with login
        final List<dynamic> loginData = responseData;
        print('login response data ==============$loginData');
        if (loginData.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(loginData: loginData)),
          );
        } else {
          print('User not found.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("User Not Found"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("The entered mobile number is not registered."),
                    SizedBox(height: 8),
                    Text("Please contact the admin to get registered with your device ID: $deviceId"),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else if (responseData is String) {
        // User does not exist, handle accordingly
        print('User does not exist.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("User Not Found"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("The entered mobile number is not registered."),
                  SizedBox(height: 8),
                  Text("Please contact the admin to get registered with your device ID: $deviceId"),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Invalid response format
        print('Invalid response format.');
        // Show a generic error message
      }
    } else {
      // Handle other status codes
      print('Login failed with status code ${response.statusCode}');
      // Show a generic error message
    }

  }
}