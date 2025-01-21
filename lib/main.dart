import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOAP Request Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> sendSoapRequest() async {
    var headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'macus',
      'Cookie': 'JSESSIONID=2CC3C042D5E1D7646E6055ACF2570E2A',
      'Accept': '/', // Added Accept header
      'Connection': 'keep-alive' // Added Connection header
    };

    var request = http.Request(
      'POST',
      Uri.parse('http://103.120.46.75:9080/da/ws'),
    );

    // Simplified SOAP request
    request.body = '''<?xml version="1.0" encoding="utf-8"?>
                      <!-- SOAPAction: "macus" -->
                      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                        <soap:Body>
                          <Detail SessionID="2CC3C042D5E1D7646E6055ACF2570E2A" />    
                            <UserID>EMP-008065</UserID> 
                          <Password>258065</Password>        
                        </soap:Body>
                      </soap:Envelope>''';

    request.headers.addAll(headers);

    try {
      final streamedResponse = await request.send();

      // Read response as bytes first
      final bytes = await streamedResponse.stream.toBytes();

      // Try to decode as UTF-8
      final responseBody = utf8.decode(bytes);
      print('Response body length: ${responseBody.length}');
      print('Raw response: "$responseBody"');

      if (streamedResponse.statusCode == 200) {
        if (responseBody.isEmpty) {
          print('Response is empty despite 200 status');
          return;
        }

        // Check if response contains JSON
        if (responseBody.trim().startsWith('{')) {
          try {
            String jsonStr = responseBody;
            // If response contains multiple JSON objects, wrap them in array
            if (!jsonStr.trim().startsWith('[')) {
              jsonStr = '[$jsonStr]';
            }
            final result = jsonStr;
            print('Parsed JSON: $result');
          } catch (e) {
            print('JSON parsing error: $e');
          }
        } else {
          print('Response appears to be XML or other format');
        }
      } else {
        print('Error status: ${streamedResponse.statusCode}');
        print('Response: $responseBody');
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOAP Request Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await sendSoapRequest();
          },
          child: const Text('Send SOAP Request'),
        ),
      ),
    );
  }
}
