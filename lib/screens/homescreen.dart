import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> loginData;
  const HomeScreen({Key? key,   required this.loginData}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to saras dairy',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
      ),
    );
  }
}
