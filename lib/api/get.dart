import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

class CustomerDetailsScreen extends StatefulWidget {
  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  Map<String, dynamic>? customerData;

  @override
  void initState() {
    super.initState();
    getSessionIDAndCustomerDetails();
  }

  Future<void> getSessionIDAndCustomerDetails() async {
    var url = Uri.parse('http://103.120.46.75:9080/da/ws');

    // Step 1: Authenticate and Get Session ID
    String sessionID = await authenticate(url);

    if (sessionID.isNotEmpty) {
      // Step 2: Use the session ID to get customer details
      await getCustomerDetails(url, sessionID);
    }
  }

  Future<String> authenticate(Uri url) async {
    String authRequest = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <soap:Body>
        <Authenticate>
          <UserName>admin@eis.com</UserName>
          <Password>cGhhMTIz</Password>
          <BusinessID>100012</BusinessID>
        </Authenticate>
      </soap:Body>
    </soap:Envelope>''';

    Map<String, String> headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'ZX_Authenticate',
    };

    try {
      final response =
          await http.post(url, headers: headers, body: authRequest);

      if (response.statusCode == 200) {
        print('Auth Response Body: ${response.body}');
        var data = parseAndConvertXMLToJSON(response.body);

        // Extract the SessionID from the response JSON
        String sessionID = data['soap:Envelope']['soap:Body']
            ['AuthenticateResponse']['SessionID'];
        print('Session ID: $sessionID');
        return sessionID;
      } else {
        print('Authentication failed: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error authenticating: $e');
      return '';
    }
  }

  Future<void> getCustomerDetails(Uri url, String sessionID) async {
    String customerRequest = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <soap:Body>
        <Detail SessionID="$sessionID">
          <UserID>EMP-008065</UserID>
          <Password>258065</Password>
        </Detail>
      </soap:Body>
    </soap:Envelope>''';

    Map<String, String> headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'macus',
    };

    try {
      final response =
          await http.post(url, headers: headers, body: customerRequest);

      if (response.statusCode == 200) {
        print('Customer Response Body: ${response.body}');
        var data = parseAndConvertXMLToJSON(response.body);

        setState(() {
          customerData = data;
        });
      } else {
        print('Error fetching customer details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making request: $e');
    }
  }

  Map<String, dynamic> parseAndConvertXMLToJSON(String responseBody) {
    final xml2Json = Xml2Json();
    try {
      xml2Json.parse(responseBody);
      String jsonString = xml2Json.toParker();
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error parsing XML: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
      ),
      body: customerData != null
          ? SingleChildScrollView(
              child: Text('Customer Data: ${customerData.toString()}'),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
