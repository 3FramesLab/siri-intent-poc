import 'package:flutter/material.dart';

class ComdataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comdata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.data_usage, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('Comdata Screen', style: TextStyle(fontSize: 24)),
            Text('Opened via Siri: "Open Comdata"'),
          ],
        ),
      ),
    );
  }
}
