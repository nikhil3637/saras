import 'package:flutter/material.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  // Demo list of inventory items
  final List<Map<String, dynamic>> inventoryItems = [
    {
      'date': '2024-02-26',
      'booth': 'Booth A',
      'product': 'Milk',
      'quantity': 100,
    },
    {
      'date': '2024-02-26',
      'booth': 'Booth B',
      'product': 'Cheese',
      'quantity': 50,
    },
    {
      'date': '2024-02-26',
      'booth': 'Booth C',
      'product': 'Yogurt',
      'quantity': 75,
    },
    {
      'date': '2024-02-27',
      'booth': 'Booth A',
      'product': 'Milk',
      'quantity': 120,
    },
    {
      'date': '2024-02-27',
      'booth': 'Booth B',
      'product': 'Cheese',
      'quantity': 60,
    },
    {
      'date': '2024-02-27',
      'booth': 'Booth C',
      'product': 'Yogurt',
      'quantity': 80,
    },
  ];

  DateTime? selectedDate;
  List<Map<String, dynamic>> filteredItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Inventory'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _selectDate(context);
            },
            child: Text(selectedDate == null
                ? 'Select Date'
                : 'Selected Date: ${selectedDate!.toString().split(' ')[0]}'),
          ),
          if (filteredItems.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text('Date: ${item['date']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booth: ${item['booth']}'),
                        Text('Product: ${item['product']}'),
                        Text('Quantity: ${item['quantity']}'),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        filteredItems = inventoryItems
            .where((item) => item['date'] == picked.toString().substring(0, 10))
            .toList();
      });
    }
  }
}

