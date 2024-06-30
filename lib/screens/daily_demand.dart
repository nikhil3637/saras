import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saras/screens/visit_out.dart';
import '../constants/colors.dart';
import 'daily_stock.dart';
import 'package:http/http.dart' as http;


class DailyDemand extends StatefulWidget {
  final int userNo;
  final String boothId;
  final String boothName;
  final String routeNo;
  final DateTime selectedDate;
  final List<dynamic> loginData;
  const DailyDemand({Key? key, required this.userNo, required this.boothId, required this.selectedDate, required this.boothName, required this.loginData, required this.routeNo}) : super(key: key);

  @override
  State<DailyDemand> createState() => _DailyDemandState();
}

class _DailyDemandState extends State<DailyDemand> {
  List<DemandProduct> products = [];
  TextEditingController boothController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      checkAttendance();
      fetchProducts(widget.selectedDate, widget.boothId, widget.userNo);
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

  @override
  Widget build(BuildContext context) {
    print('date=============================${widget.selectedDate}');
    print('boothid=============================${widget.boothId}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Demand',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                DemandProduct product = products[index];
                TextEditingController quantityController =
                TextEditingController(text: product.demandQty.toString());
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor,),
                ),
                onPressed: () {saveDemand();},
                child: Text('Save',style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Future<void> fetchProducts(demandDate,boothId,salesManId) async {
    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/GetBoothWiseDemand'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },

      body: jsonEncode(<String, dynamic>{
        'DemandDate':DateFormat('dd-MMM-yyyy').format(demandDate),
        'BoothId' : boothId,
        'SalesManId' : salesManId
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print("daily demand response data====================$responseData");
      if (responseData.isNotEmpty) {
        setState(() {
          products = responseData.map((json) => DemandProduct.fromJson(json)).toList();
        });

      } else {

      }
    } else {

    }
  }

  Future<void> saveDemand() async {
    // Construct the request body
    List<Map<String, dynamic>> demandDetails = products.map((product) {
      return {
        'DemandDate': DateFormat('dd-MMM-yyyy').format(widget.selectedDate),
        'BoothId': widget.boothId,
        'SalaesmanId': widget.userNo,
        'itemId': product.itemId,
        'DemandQty': product.demandQty,
      };
    }).toList();

    // Send API request
    final response = await http.post(
      Uri.parse('http://183.83.176.150:81/api/SaveBoothWiseDemand'), // Update the API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(demandDetails),
    );

    if (response.statusCode == 200) {
      // Handle success
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Demand Saved'),
            content: Text('Demand has been saved successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.routeNo == '1') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitOut(
                          userNo: widget.userNo,
                          boothId: widget.boothId,
                          selectedDate: widget.selectedDate,
                          boothName: widget.boothName,
                          loginData: widget.loginData,
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
      print('Demand saved successfully');
    } else {
      // Handle failure
      print('Failed to save demand');
    }
  }



}

class DemandProduct {
  final int itemId;
  final String itemName;
  int demandQty;

  DemandProduct({
    required this.itemId,
    required this.itemName,
    required this.demandQty,
  });

  factory DemandProduct.fromJson(Map<String, dynamic> json) {
    return DemandProduct(
      itemId: json['itemId'],
      itemName: json['itemName'],
      demandQty: json['demandQty'],
    );
  }
}
