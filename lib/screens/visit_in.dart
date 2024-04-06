import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saras/screens/daily_stock.dart';

import '../constants/colors.dart';

class VisitIn extends StatefulWidget {
  final int userNo;
  final List<dynamic> loginData;
  const VisitIn({Key? key, required this.userNo, required this.loginData}) : super(key: key);

  @override
  State<VisitIn> createState() => _VisitInState();
}

class _VisitInState extends State<VisitIn> {
  DateTime _selectedDate = DateTime.now();
  TextEditingController boothController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<GetAllBooth> boothList = [];
  GetAllBooth? selectedBooth;
  String? selectedBoothId;
  String? selectedBoothName;


  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
    getAllBooth(widget.userNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visit In',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(height: 20,),
                Expanded(
                  child: Text('Selected Date: ${DateFormat('dd-MMM-yyyy').format(_selectedDate)}',style: TextStyle(wordSpacing: 2,fontSize: 18 )),
                ),
                SizedBox(width: 40),
                Expanded(
                  child: DropdownButtonFormField<GetAllBooth>(
                    value: selectedBooth,
                    items: boothList.map((GetAllBooth booth) {
                      return DropdownMenuItem<GetAllBooth>(
                        value: booth,
                        child: Text(booth.name),
                      );
                    }).toList(),
                    onChanged: (GetAllBooth? newValue) {
                      setState(() {
                        selectedBooth = newValue;
                        if (newValue != null) {
                          selectedBoothId = newValue.id;
                          selectedBoothName = newValue.name;
                          print('selectedBoothId=================$selectedBoothId');
                        } else {
                          selectedBoothId = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Booth',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40,),
          TextButton(
            onPressed: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
            child: Text('Time: ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',style: TextStyle(wordSpacing: 2,fontSize: 18 )),
          ),

          Spacer(), // Spacer to push button to bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor,),
                ),
                onPressed: () async {
                  await _saveVisit();
                },
                child: Text('Save Visit',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getAllBooth(int userNo) async {
    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/getallbooth'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'UserNo': userNo.toString(),
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print('responseData get all booth =========$responseData');

      setState(() {
        boothList = responseData.map((data) => GetAllBooth.fromJson(data)).toList();
        print('boothlist=============================$boothList');
      });
      if (responseData.isEmpty) {
        print('No booths found.');
      }
    } else {
      print('Failed to fetch booths with status code ${response.statusCode}');
    }
  }

  Future<void> _saveVisit() async {
    if (selectedBoothId != null) {
      // Fetch current location
      Position? position = await _getCurrentLocation();
      if (position != null) {
        double distance = _calculateDistance(
            position.latitude,
            position.longitude,
            selectedBooth!.latitude,
            selectedBooth!.longitude);

        if (distance <= 50) {
          // Location within 50 meters, proceed with saving visit
          print("Location within 50 meters.");
          print("latitude==================${position.latitude}");
          print("longitude==================${position.longitude}");
          print("userno==================${widget.userNo}");
          print("Boothid==================${selectedBoothId}");
          final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
          final DateFormat timeFormat = DateFormat('HH:mm'); // 24-hour format

          final String formattedDate = dateFormat.format(_selectedDate);
          final String formattedTime = timeFormat.format(DateTime(2024, 1, 1, _selectedTime.hour, _selectedTime.minute));
          print("attntime==================${formattedTime}");
          print("attdate==================${formattedDate}");
          final response = await http.post(
            Uri.parse('http://183.83.176.150:81/api/AttendanceIn'),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'UserNo': widget.userNo,
              'BoothId': selectedBoothId,
              'AttnInDate': formattedDate,
              'AttnInTime': formattedTime,
              'latitude': position.latitude.toString(),
              'Longitude': position.longitude.toString(),
              'Flag': 'IN',
            }),
          );
          if (response.statusCode == 200) {
            print('Visit saved successfully');
            // Navigate to DailyDemand page only if visit is successfully saved
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DailyStockPage(userNo: widget.userNo, boothId: selectedBooth!.id, selectedDate: _selectedDate, boothName: selectedBoothName.toString(), loginData: widget.loginData, routeNo: '1',)));
          } else {
            print('Failed to save visit with status code ${response.statusCode}');
          }
        } else {
          // Location not within 50 meters
          print("Location not within 50 meters.");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('You are too far from the selected booth.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Failed to fetch current location');
      }
    } else {
      // If no booth is selected, show a message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select a booth before saving the visit.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
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

  double _calculateDistance(
      double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const R = 6371000.0; // Radius of the Earth in meters
    double phi1 = startLatitude * pi / 180.0;
    double phi2 = endLatitude * pi / 180.0;
    double deltaPhi = (endLatitude - startLatitude) * pi / 180.0;
    double deltaLambda = (endLongitude - startLongitude) * pi / 180.0;

    double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c;
    return distance;
  }

}

class GetAllBooth{
  String id;
  String name;
  double latitude;
  double longitude;

  GetAllBooth({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude
  });

  factory GetAllBooth.fromJson(Map<String, dynamic> json) => GetAllBooth(
    id: json["id"],
    name: json["name"],
    latitude:  double.parse(json["lat"].toString()),
    longitude: double.parse(json["long"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "lat" : latitude,
    "long" : longitude
  };
}
