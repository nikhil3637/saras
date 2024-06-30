import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saras/screens/daily_demand.dart';

import '../constants/colors.dart';

class DailyStockPage extends StatefulWidget {
  final int userNo;
  final String boothId;
  final String boothName;
  final String routeNo;
  final DateTime selectedDate;
  final List<dynamic> loginData;

  DailyStockPage({
    Key? key,
    required this.userNo,
    required this.boothId, required this.selectedDate, required this.boothName, required this.loginData, required this.routeNo,
  }) : super(key: key);

  @override
  _DailyStockPageState createState() => _DailyStockPageState();
}

class _DailyStockPageState extends State<DailyStockPage> {
  DateTime _selectedDate = DateTime.now(); // Initialize selected date with current date
  List<StockProduct> products = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      checkAttendance();
      fetchStockProducts(widget.selectedDate, widget.boothId, widget.userNo);
    });
  }

  void checkAttendance() {
    DateTime currentDate = DateTime.now();
    if (widget.selectedDate != currentDate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attendance Required'),
            content: Text('Please mark your attendance first.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to the attendance screen or perform any necessary action
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchStockProducts(demandDate,boothId,salesManId) async {
    print('userno on fetch   stock page ======${salesManId}');
    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/GetBoothStock'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'StockDate': DateFormat('dd-MMM-yyyy').format(demandDate),
        'BoothId': boothId,
        'SalesManId': salesManId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print("daily Stock response data====================$responseData");
      if (responseData.isNotEmpty) {
        setState(() {
          products = responseData.map((json) => StockProduct.fromJson(json)).toList();
        });
      } else {
        // Handle case when response data is empty
      }
    } else {
      // Handle API call failure
    }
  }

  Future<void> saveStock() async {
    // Construct the request body
    print('userno on stock page ======${widget.userNo}');
    List<Map<String, dynamic>> stockDetails = products.map((product) {
      return {
        'StockDate': DateFormat('dd-MMM-yyyy').format(widget.selectedDate),
        'BoothId': widget.boothId,
      'SalaesmanId': widget.userNo,
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
      // Handle success
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Stock Saved'),
            content: Text('Stock has been saved successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.routeNo == '1') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyDemand(
                          userNo: widget.userNo,
                          boothId: widget.boothId,
                          selectedDate: _selectedDate,
                          boothName: widget.boothName,
                          loginData: widget.loginData, routeNo: '1',
                        ),
                      ),
                    );
                  } else if (widget.routeNo == '2') {
                    Navigator.pop(context); // Dismiss the dialog first
                    Navigator.pop(context); // Go back to the previous page
                  }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Stock',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                  child: Text(
                    'Selected Date: ${DateFormat('dd-MMM-yyyy').format(widget.selectedDate)}',
                    style: TextStyle(wordSpacing: 2, fontSize: 18),
                  ),
                ),
                SizedBox(width: 50),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Selected Booth: ${widget.boothName}',
                      style: TextStyle(wordSpacing: 2, fontSize: 18),
                    ),
                  ),
                ),
              ],
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
                    StockProduct product = products[index];
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
                  saveStock();
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

class StockProduct {
  final int itemId;
  final String itemName;
  int stockQty;

  StockProduct({
    required this.itemId,
    required this.itemName,
    required this.stockQty,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      itemId: json['itemId'],
      itemName: json['itemName'],
      stockQty: json['stockQty'],
    );
  }
}
