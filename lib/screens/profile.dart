import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final List<dynamic> loginData;

  const Profile({Key? key,  required this.loginData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Name',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${loginData?[0]['name']}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Mobile No',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${loginData?[0]['mobileNo']}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Email',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${loginData?[0]['emailId']}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            // Add more profile details as needed
          ],
        ),
      ),
    );
  }
}
