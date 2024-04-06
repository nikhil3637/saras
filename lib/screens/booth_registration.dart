import 'package:flutter/material.dart';

class BoothRegistration extends StatefulWidget {
  const BoothRegistration({Key? key}) : super(key: key);

  @override
  _BoothRegistrationState createState() => _BoothRegistrationState();
}

class _BoothRegistrationState extends State<BoothRegistration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _contactPersonNameController =
  TextEditingController();
  final TextEditingController _contactPersonContactController =
  TextEditingController();
  final TextEditingController _contactPersonEmailController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booth Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _routeController,
              decoration: const InputDecoration(labelText: 'Route'),
            ),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _contactPersonNameController,
              decoration: const InputDecoration(
                  labelText: 'Contact Person Name'),
            ),
            TextFormField(
              controller: _contactPersonContactController,
              decoration: const InputDecoration(
                  labelText: 'Contact Person Contact'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _contactPersonEmailController,
              decoration: const InputDecoration(
                  labelText: 'Contact Person Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    final String name = _nameController.text;
    final String route = _routeController.text;
    final double longitude = double.parse(_longitudeController.text);
    final double latitude = double.parse(_latitudeController.text);
    final String contactPersonName = _contactPersonNameController.text;
    final String contactPersonContact =
        _contactPersonContactController.text;
    final String contactPersonEmail = _contactPersonEmailController.text;

    // Do something with the extracted data, like sending it to a server or saving it locally
  }

  @override
  void dispose() {
    _nameController.dispose();
    _routeController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _contactPersonNameController.dispose();
    _contactPersonContactController.dispose();
    _contactPersonEmailController.dispose();
    super.dispose();
  }
}
