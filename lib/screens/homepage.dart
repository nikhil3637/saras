import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:saras/constants/colors.dart';
import 'package:saras/screens/daily_demand.dart';
import 'package:saras/screens/daily_stock.dart';
import 'package:saras/screens/login_screen.dart';
import 'package:saras/screens/profile.dart';
import 'package:saras/screens/visit_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'other_route_stock.dart';

class HomePage extends StatefulWidget {
  final List<dynamic> loginData;

  const HomePage({Key? key, required this.loginData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? lastVisitBoothId;
  DateTime? selectedDate;
  String? lastVisitBoothName;

  late List<Widget> _widgetOptions;

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lastVisitBoothId = prefs.getString('lastBoothId');
    lastVisitBoothName = prefs.getString('lastBoothName');

    String? lastVisitOutDate = prefs.getString('lastSelectedDate');
    if (lastVisitOutDate != null) {
      selectedDate = DateFormat('dd-MMM-yyyy').parse(lastVisitOutDate);
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(loginData: widget.loginData),
      Profile(loginData: widget.loginData)
    ];
    getData();
    locationPermission();
  }

   locationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Location Permission Required"),
            content: Text("This app requires location permission to function properly. Please grant the permission."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          ),
        );
        permission = await Geolocator.requestPermission();
      }else{
        if (permission == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("Location Permission Required"),
              content: Text("This app requires location permission to function properly. Please grant the permission."),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            ),
          );
          permission = await Geolocator.requestPermission();
        }
      }
    }
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    int userNo = int.parse(widget.loginData[0]['userNo']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Hi ${widget.loginData[0]['name'] ?? 'User'}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      ),
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,

                ),
              ),
            ),

            ListTile(
              title: Text('Attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisitIn(
                      userNo: userNo,
                      loginData: widget.loginData ?? [],
                    ),
                  ),
                );
                            },
            ),
            ListTile(
              title: Text('Demand'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyDemand(
                      userNo:  userNo,
                      boothId: lastVisitBoothId.toString(),
                      selectedDate: selectedDate ?? DateTime.now(),
                      boothName: lastVisitBoothName.toString(),
                      loginData: widget.loginData, routeNo: '2',
                    ),
                  ),
                );
                            },
            ),
            ListTile(
              title: Text('Stock'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyStockPage(
                      userNo: userNo,
                      boothId: lastVisitBoothId.toString(),
                      selectedDate: selectedDate ?? DateTime.now(),
                      boothName: lastVisitBoothName.toString(),
                      loginData: widget.loginData, routeNo: '2',
                    ),
                  ),
                );
                            },
            ),
            ListTile(
              title: const Text('Other Routes'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OtherRouteStock(userNo: userNo, loginData: widget.loginData,)));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
