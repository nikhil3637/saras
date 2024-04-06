import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:saras/screens/homepage.dart';
import 'package:saras/screens/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';
class VisitOut extends StatefulWidget {
  final int userNo;
  final String boothId;
  final String boothName;
  final DateTime selectedDate;
  final List<dynamic> loginData;
  const VisitOut({Key? key, required this.userNo, required this.boothId, required this.selectedDate, required this.boothName, required this.loginData}) : super(key: key);

  @override
  State<VisitOut> createState() => _VisitOutState();
}

class _VisitOutState extends State<VisitOut> {
  TextEditingController boothController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // Set the initial time to the current time
    _selectedTime = TimeOfDay.now();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Out',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Selected Date:${DateFormat('dd-MMM-yyyy').format(widget.selectedDate)}',
                    style: TextStyle(wordSpacing: 2,fontSize: 18 ),),
                ),
                SizedBox(width: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Selected Booth: ${widget.boothName}',style: TextStyle(wordSpacing: 2,fontSize: 18 ),),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40,),
          TextButton(
            onPressed: () {},
            child: Text('Time: ${_selectedTime.format(context)}',style: TextStyle(wordSpacing: 2,fontSize: 18 ),),),
          Spacer(), // Spacer to push button to bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor,),
                ),
                onPressed: (){ _saveVisit();},
                child: Text('Save Visit',style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVisit() async {
      // Fetch current location
      Position? position = await _getCurrentLocation();
      if (position != null) {
        print("latitude at out ==================${position.latitude}");
        print("longitude at out ==================${position.longitude}");
        print("userno at out ==================${widget.userNo}");
        print("Boothid at out==================${widget.boothId}");
        final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
        final DateFormat timeFormat = DateFormat('HH:mm'); // 24-hour format

        final String formattedDate = dateFormat.format(widget.selectedDate);
        final String formattedTime = timeFormat.format(DateTime(2024, 1, 1, _selectedTime.hour, _selectedTime.minute));
        print("attntime==================${formattedTime}");
        print("attdate==================${formattedDate}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('lastUserNo', widget.userNo);
        prefs.setString('lastBoothId', widget.boothId);
        prefs.setString('lastBoothName', widget.boothName);
        prefs.setString('lastSelectedDate', DateFormat('dd-MMM-yyyy').format(widget.selectedDate));

        final response = await http.post(
          Uri.parse('http://183.83.176.150:81/api/AttendanceIn'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'UserNo': widget.userNo,
            'BoothId': widget.boothId,
            'AttnInDate': formattedDate,
            'AttnInTime': formattedTime,
            'latitude': position.latitude.toString(),
            'Longitude': position.longitude.toString(),
            'Flag': 'OUT',
          }),
        );
        if (response.statusCode == 200) {
          print('Visit saved successfully');
          // Navigate to DailyDemand page only if visit is successfully saved
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(loginData: widget.loginData,)));
        } else {
          print('Failed to save visit with status code ${response.statusCode}');
        }
      } else {
        print('Failed to fetch current location');
      }
  }


  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, handle accordingly
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, handle accordingly
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, handle accordingly
        return null;
      }

      // Permissions are granted, proceed to get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      // Handle any errors that occur during location retrieval
      print('Error getting current location: $e');
      return null;
    }
  }


}
