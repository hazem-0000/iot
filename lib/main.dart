import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thinger.io Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLedOn = false;
  String distance = 'Fetching distance...';

  // Thinger.io API endpoint for controlling LED
  final String ledEndpoint =
      'https://backend.thinger.io/v3/users/hazem_pi/devices/esp32/resources/led';

  // Thinger.io API endpoint for fetching distance
  final String distanceEndpoint =
      'https://backend.thinger.io/v3/users/hazem_pi/devices/esp32/resources/distance';

  // Thinger.io token
  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MjEwMzExNzAsImlhdCI6MTcyMTAyMzk3MCwicm9sZSI6InVzZXIiLCJ1c3IiOiJoYXplbV9waSJ9.cEleFAo8oAzL1zspYB_HTfJAidV_v6ZjKzTxbBq_K-4';

  // Function to toggle LED state
  void toggleLed() async {
    try {
      final response = await http.post(
        Uri.parse(ledEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'in': !isLedOn}),
      );

      print('LED Toggle Response Status: ${response.statusCode}');
      print('LED Toggle Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          isLedOn = !isLedOn;
        });
      } else {
        print('Failed to toggle LED: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling LED: $e');
    }
  }

  // Function to fetch distance data
  void fetchDistance() async {
    print('this distance');
    try {
      final response = await http.get(
        Uri.parse(distanceEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Fetch Distance Response Status: ${response.statusCode}');
      print('Fetch Distance Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          distance = jsonDecode(response.body)['out'].toString() + ' cm'; // Adjust 'out' based on your Thinger.io resource structure
        });
      } else {
        print('Failed to fetch distance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching distance: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    toggleLed();
    fetchDistance();

    print('This is a test message printed from initState');// Fetch distance data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thinger.io Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: toggleLed,
              child: Text(isLedOn ? 'Turn LED Off' : 'Turn LED On'),
            ),
            SizedBox(height: 20),
            Text('Distance: $distance'),
          ],
        ),
      ),
    );
  }
}
