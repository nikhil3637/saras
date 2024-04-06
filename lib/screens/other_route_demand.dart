import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import 'homepage.dart';

class OtherRouteDemand extends StatefulWidget {
  final int userNo;
  final List<dynamic> loginData;
  const OtherRouteDemand({Key? key, required this.userNo, required this.loginData}) : super(key: key);

  @override
  State<OtherRouteDemand> createState() => _OtherRouteDemandState();
}

class _OtherRouteDemandState extends State<OtherRouteDemand> {
  List<DemandRoute> allRoutes = [];
  DemandRoute? selectedRoute;
  List<GetAllBoothOtherRouteDemand> boothList = [];
  GetAllBoothOtherRouteDemand? selectedBooth;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? selectedBoothId;
  List<OtherDemandProduct> products = [];

  Future<void> fetchAllRoutes() async {
    final response = await http.post(
        Uri.parse('http://183.83.176.150:81/api/GetAllRoute'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{})
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        allRoutes = responseData.map((routeJson) => DemandRoute.fromJson(routeJson)).toList();
      });
    } else {
      // Handle API call failure
    }
  }

  Future<void> fetchBooths(int routeId) async {
    final response = await http.post(
        Uri.parse('http://183.83.176.150:81/api/GetAllBoothRouteWise'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'routeId': routeId,
        })
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        boothList = responseData.map((data) => GetAllBoothOtherRouteDemand.fromJson(data)).toList();
      });
    } else {
      // Handle API call failure
    }
  }

  Future<void> fetchDemandProducts(boothId) async {
    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/GetBoothWiseDemand'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'DemandDate': DateFormat('dd-MMM-yyyy').format(DateTime.now()),
        'BoothId': boothId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      if (responseData.isNotEmpty) {
        setState(() {
          products = responseData.map((json) => OtherDemandProduct.fromJson(json)).toList();
        });
      } else {
        // Handle case when response data is empty
      }
    } else {
      // Handle API call failure
    }
  }

  Future<void> saveDemand(boothId) async {
    List<Map<String, dynamic>> demandDetails = products.map((product) {
      return {
        'DemandDate': DateFormat('dd-MMM-yyyy').format(DateTime.now()),
        'BoothId': boothId,
        'SalaesmanId': widget.userNo,
        'itemId': product.itemId,
        'DemandQty': product.demandQty,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/SaveBoothWiseDemand'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(demandDetails),
    );

    if (response.statusCode == 200) {
      _saveVisit();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Demand Saved'),
            content: Text('Demand has been saved successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(loginData: widget.loginData)));
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to save demand');
    }
  }

  Future<void> _saveVisit() async {
    // Fetch current location
    Position? position = await _getCurrentLocation();
    if (position != null) {
      print("latitude at out ==================${position.latitude}");
      print("longitude at out ==================${position.longitude}");
      print("userno at out ==================${widget.userNo}");
      print("userno at out ==================${widget.userNo}");
      final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
      final DateFormat timeFormat = DateFormat('HH:mm'); // 24-hour format

      final String formattedDate = dateFormat.format(_selectedDate);
      final String formattedTime = timeFormat.format(DateTime(2024, 1, 1, _selectedTime.hour, _selectedTime.minute));
      print("attntime on other route==================${formattedTime}");
      print("attdate on other route==================${formattedDate}");

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
          'Flag': 'OUT',
        }),
      );
      if (response.statusCode == 200) {
        print('Visit saved successfully');
        // Navigate to DailyDemand page only if visit is successfully saved
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

  @override
  void initState() {
    super.initState();
    fetchAllRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Other Route Demand Page'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage(loginData: widget.loginData)),
                    (route) => false, // Removes all routes from the stack
              );
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<DemandRoute>(
              value: selectedRoute,
              hint: const Text('Select Route'),
              onChanged: (DemandRoute? newValue) {
                setState(() {
                  selectedRoute = newValue;
                  if (newValue != null) {
                    fetchBooths(newValue.routeId);
                  }
                });
              },
              items: allRoutes.map<DropdownMenuItem<DemandRoute>>((DemandRoute route) {
                return DropdownMenuItem<DemandRoute>(
                  value: route,
                  child: Text(route.routeName),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton(
                value: selectedBooth,
                hint: Text('Select Booth'),
                onChanged: (dynamic newValue) {
                  setState(() {
                    selectedBooth = newValue;
                    if (newValue != null) {
                      selectedBoothId = newValue.id;
                      print('selectedBoothId for other routes demand=================$selectedBoothId');
                      fetchDemandProducts(selectedBooth?.id);
                    }
                  });
                },
                items: boothList.map<DropdownMenuItem<GetAllBoothOtherRouteDemand>>((GetAllBoothOtherRouteDemand booth) {
                  return DropdownMenuItem<GetAllBoothOtherRouteDemand>(
                    value: booth,
                    child: Text(booth.name),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 200,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      OtherDemandProduct product = products[index];
                      TextEditingController quantityController =
                      TextEditingController(text: product.demandQty.toString());
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Text('${index + 1}.'),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                product.itemName,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: quantityController,
                                onChanged: (value) {
                                  products[index].demandQty = int.parse(value);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor),
                  ),
                  onPressed: () {
                    saveDemand(selectedBooth?.id);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DemandRoute {
  final int routeId;
  final String routeName;

  DemandRoute({required this.routeId, required this.routeName});

  factory DemandRoute.fromJson(Map<String, dynamic> json) {
    return DemandRoute(
      routeId: json['routeId'],
      routeName: json['routeName'],
    );
  }
}
class OtherDemandProduct {
  final int itemId;
  final String itemName;
  int demandQty;

  OtherDemandProduct({
    required this.itemId,
    required this.itemName,
    required this.demandQty,
  });

  factory OtherDemandProduct.fromJson(Map<String, dynamic> json) {
    return OtherDemandProduct(
      itemId: json['itemId'],
      itemName: json['itemName'],
      demandQty: json['demandQty'],
    );
  }
}
class GetAllBoothOtherRouteDemand{
  String id;
  String name;
  double latitude;
  double longitude;

  GetAllBoothOtherRouteDemand({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude
  });

  factory GetAllBoothOtherRouteDemand.fromJson(Map<String, dynamic> json) => GetAllBoothOtherRouteDemand(
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
