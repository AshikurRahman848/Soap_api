//import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<String?> authenticateAndGetSessionID() async {
  var url = Uri.parse('http://103.120.46.75:9080/da/ws');

  // SOAP Request Body
  String soapRequest = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
      <UserName>admin@eis.com</UserName>
      <Password>cGhhMTIz</Password>
      <BusinessID>100012</BusinessID>
    </soap:Body>
  </soap:Envelope>''';

  // Set Headers
  Map<String, String> headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'macus'
  };

  try {
    // Make the POST request
    final response = await http.post(url, headers: headers, body: soapRequest);

    if (response.statusCode == 200) {
      // If the server responds with a 200 OK, parse the response
      return extractSessionID(response.body);
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error making request: $e');
  }
  return null;
}

String? extractSessionID(String responseBody) {
  try {
    final document = xml.XmlDocument.parse(responseBody);
    final sessionIDElement = document.findAllElements('SessionID').single;
    return sessionIDElement.text; // Extract and return the SessionID
  } catch (e) {
    print('Error parsing SOAP response: $e');
  }
  return null;
}
