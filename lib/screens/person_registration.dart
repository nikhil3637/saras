import 'package:flutter/material.dart';
import 'package:saras/screens/booth_registration.dart';

class PersonRegistration extends StatefulWidget {
  const PersonRegistration({Key? key}) : super(key: key);

  @override
  State<PersonRegistration> createState() => _PersonRegistrationState();
}

class _PersonRegistrationState extends State<PersonRegistration> {
  // Define TextEditingController for handling input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();

  // Variable to store the selected type (admin/salesperson)
  String? _selectedType;

  // Variable to store the selected joining date
  DateTime? _selectedJoiningDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              items: ['admin', 'salesperson']
                  .map<DropdownMenuItem<String>>(
                      (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile No'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email ID'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            GestureDetector(
              onTap: () {
                _selectJoiningDate(context);
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _joiningDateController,
                  decoration: const InputDecoration(labelText: 'Joining Date'),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BoothRegistration()));
                _submitForm();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle form submission
  void _submitForm() {
    // Extract values from text controllers
    final String type = _selectedType ?? '';
    final String name = _nameController.text;
    final String mobile = _mobileController.text;
    final String email = _emailController.text;
    final String address = _addressController.text;
    final String joiningDate = _joiningDateController.text;

    // Perform validation if needed

    // Do something with the extracted data, like sending it to a server or saving it locally
    // You can also navigate to another screen or show a confirmation dialog
  }

  // Method to open calendar to choose joining date
  Future<void> _selectJoiningDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedJoiningDate) {
      setState(() {
        _selectedJoiningDate = pickedDate;
        _joiningDateController.text = pickedDate.toString();
      });
    }
  }

  @override
  void dispose() {
    // Clean up text controllers
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }
}
