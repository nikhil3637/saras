  import 'dart:convert';
  import 'dart:math';
  import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';
  import 'package:saras/screens/homepage.dart';
import 'package:saras/screens/other_route_demand.dart';

  import '../constants/colors.dart';

  class OtherRouteStock extends StatefulWidget {
    final int userNo;
    final List<dynamic> loginData;
    const OtherRouteStock({Key? key, required this.userNo, required this.loginData}) : super(key: key);

    @override
    State<OtherRouteStock> createState() => _OtherRouteStockState();
  }

  class _OtherRouteStockState extends State<OtherRouteStock> {
    List<Route> allRoutes = [];
    Route? selectedRoute;
    DateTime _selectedDate = DateTime.now();
    TimeOfDay _selectedTime = TimeOfDay.now();
    List<GetAllBoothOtherRoute> boothList = [];
    GetAllBoothOtherRoute? selectedBooth;
    String? selectedBoothId;
    List<OtherStockProduct> products = [];

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
        print("all routes response data====================$responseData");
        setState(() {
          allRoutes = responseData.map((routeJson) => Route.fromJson(routeJson)).toList();
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
        print("all booths response data====================$responseData");
        setState(() {
          boothList = responseData.map((data) => GetAllBoothOtherRoute.fromJson(data)).toList();
        });
      } else {
        // Handle API call failure
      }
    }

    Future<void> fetchStockProducts(boothId,salesManId) async {
      print('userno on fetch   stock page ======${salesManId}');
      final response = await http.post(
        Uri.parse('http://183.83.176.150:81/api/GetBoothStock'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'StockDate':  DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          'BoothId': boothId,
          'SalesManId': salesManId,
        }),
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print("daily Stock response data====================$responseData");
        if (responseData.isNotEmpty) {
          setState(() {
            products = responseData.map((json) => OtherStockProduct.fromJson(json)).toList();
          });
        } else {
          // Handle case when response data is empty
        }
      } else {
        // Handle API call failure
      }
    }

    Future<void> saveStock(boothId,salesManId) async {
      // Construct the request body
      List<Map<String, dynamic>> stockDetails = products.map((product) {
        return {
          'StockDate': DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          'BoothId': boothId,
          'SalaesmanId': salesManId,
          'itemId': product.itemId,
          'stockQty': product.stockQty,
        };
      }).toList();

      // Send API request
      print('Stock details changed===============$stockDetails');
      final response = await http.post(
        Uri.parse('http://183.83.176.150:81/api/SaveBoothStock'), // Update the API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(stockDetails),
      );

      if (response.statusCode == 200) {
        _saveVisit();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Stock Saved'),
              content: Text('Stock has been saved successfully.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => OtherRouteDemand(userNo: widget.userNo, loginData: widget.loginData)),
                          (route) => false, // Removes all routes from the stack
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print('Stock saved successfully');
      } else {
        // Handle failure
        print('Failed to save stock');
      }
    }

    Future<void> _saveVisit() async {
      if (selectedBoothId != null) {
        // Fetch current location
        Position? position = await _getCurrentLocation();
        if (position != null) {
            print("latitude==================${position.latitude}");
            print("longitude==================${position.longitude}");
            print("userno on other ==================${widget.userNo}");
            print("Boothid on other stock==================${selectedBoothId}");
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
            } else {
              print('Failed to save visit with status code ${response.statusCode}');
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


    @override
    void initState() {
      super.initState();
      fetchAllRoutes();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Other Route Stock Page'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<Route>(
              value: selectedRoute,
              hint: const Text('Select Route'),
              onChanged: (Route? newValue) {
                setState(() {
                  selectedRoute = newValue;
                  if (newValue != null) {
                    fetchBooths(newValue.routeId);
                    print('route id============${newValue.routeId}');
                    print('route Name============${newValue.routeName}');
                  }
                });
              },
              items: allRoutes.map<DropdownMenuItem<Route>>((Route route) {
                return DropdownMenuItem<Route>(
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
                      print('selectedBoothId for other routes=================$selectedBoothId');
                      fetchStockProducts(selectedBooth?.id, widget.userNo);
                    }
                  });
                },
                items: boothList.map<DropdownMenuItem<GetAllBoothOtherRoute>>((GetAllBoothOtherRoute booth) {
                  return DropdownMenuItem<GetAllBoothOtherRoute>(
                    value: booth,
                    child: Text(booth.name), // Accessing name property directly
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 200, // Adjust the maximum height as needed
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      OtherStockProduct product = products[index];
                      TextEditingController quantityController =
                      TextEditingController(text: product.stockQty.toString());
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
                                  // Update the demandQty of the product in the products list
                                  products[index].stockQty = int.parse(value);
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
              child: Container(
                height: 100, // Adjust the height as needed
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Remarks',
                    border: OutlineInputBorder(),
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
                    saveStock(selectedBooth?.id,widget.userNo);
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
      );
    }
  }

  class Route {
    final int routeId;
    final String routeName;

    Route({required this.routeId, required this.routeName});

    factory Route.fromJson(Map<String, dynamic> json) {
      return Route(
        routeId: json['routeId'],
        routeName: json['routeName'],
      );
    }
  }
  class OtherStockProduct {
    final int itemId;
    final String itemName;
    int stockQty;

    OtherStockProduct({
      required this.itemId,
      required this.itemName,
      required this.stockQty,
    });

    factory OtherStockProduct.fromJson(Map<String, dynamic> json) {
      return OtherStockProduct(
        itemId: json['itemId'],
        itemName: json['itemName'],
        stockQty: json['stockQty'],
      );
    }
  }
  class GetAllBoothOtherRoute{
    String id;
    String name;
    dynamic latitude;
    dynamic longitude;

    GetAllBoothOtherRoute({
      required this.id,
      required this.name,
      required this.latitude,
      required this.longitude
    });

    factory GetAllBoothOtherRoute.fromJson(Map<String, dynamic> json) => GetAllBoothOtherRoute(
      id: json["id"],
      name: json["name"],
      latitude:  json["lat"].toString(),
      longitude: json["long"].toString()
    );

    Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
      "lat" : latitude,
      "long" : longitude
    };
  }
