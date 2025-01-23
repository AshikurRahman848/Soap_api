# Customer API Documentation

This documentation covers the API for customer synchronization and fetching customer details. The API uses SOAP/XML for requests and returns JSON responses.

---

## General Information

### Endpoint

```text
POST http://103.120.46.75:9080/da/ws
```

### Headers

| Header Name   | Value                        |
|---------------|------------------------------|
| Content-Type  | text/xml; charset=utf-8      |
| SOAPAction    | macus                        |
| Cookie        | JSESSIONID=[Session ID] (if required) |
| Accept        | /                            |
| Connection    | keep-alive                   |

### Summary

* Protocol: HTTP/HTTPS
* Request format: SOAP/XML
* Response format: JSON (single or multiple records)

---

## Customer Details API

### Purpose

The Customer Details API is used to fetch customer details from the server.

### Request Format

The API accepts SOAP/XML requests. Below is the request format:

```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Detail SessionID="[Session ID]" />
    <UserID>EMP-008065</UserID>
    <Password>258065</Password>
  </soap:Body>
</soap:Envelope>
```

### Response Format

The API returns a JSON response with the following structure:

#### Single Record Example

```json
{
  "status": "SUCCESS",
  "message": "Customer details fetched successfully.",
  "cus": "[Customer ID]",
  "org": "[Organization Name]",
  "address": "[Customer Address]",
  "phone": "[Customer Phone]"
}
```

#### Multiple Records Example

```json
[
  {
    "status": "SUCCESS",
    "message": "Customer Have been Synchronized.",
    "cus": "CUS-601313",
    "org": "Rafiq Pharmacy",
    "address": "123 Main Street",
    "phone": "123-456-7890"
  },
  {
    "status": "SUCCESS",
    "message": "Customer Have been Synchronized.",
    "cus": "CUS-605072",
    "org": "New Kamol Pharmacy",
    "address": "",
    "phone": ""
  }
]
```

### Response Fields

* `status`: Indicates the operation result (e.g., "SUCCESS").
* `message`: A human-readable message describing the result.
* `cus`: Customer ID.
* `org`: Organization/Pharmacy name.
* `address`: Customer address (if available).
* `phone`: Customer phone number (if available).

### Example Response

```json
{
  "status": "SUCCESS",
  "message": "Customer details fetched successfully.",
  "cus": "CUS-601313",
  "org": "Rafiq Pharmacy",
  "address": "123 Main Street",
  "phone": "123-456-7890"
}
```

---

## Example Dart Implementation

Here is an example of how to make a SOAP request in Dart for the Customer Details API:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchCustomerDetails() async {
  var headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'macus',
    'Cookie': 'JSESSIONID=[Session ID]',
    'Accept': '/',
    'Connection': 'keep-alive'
  };

  var requestBody = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Detail SessionID="[Session ID]" />
    <UserID>EMP-008065</UserID>
    <Password>258065</Password>
  </soap:Body>
</soap:Envelope>''';

  var request = http.Request(
    'POST',
    Uri.parse('http://103.120.46.75:9080/da/ws'),
  );

  request.headers.addAll(headers);
  request.body = requestBody;

  try {
    final streamedResponse = await request.send();
    final bytes = await streamedResponse.stream.toBytes();
    final responseBody = utf8.decode(bytes);

    if (streamedResponse.statusCode == 200) {
      print('Parsed JSON: $responseBody');
    } else {
      print('Error status: ${streamedResponse.statusCode}');
      print('Response: $responseBody');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## Notes

* The API requires proper authentication with valid session IDs.
* The session ID must be included in the `Cookie` header.
* Ensure that the `SOAPAction` and other headers match the API requirements.
* Response times are typically around 476ms, and response sizes are approximately 8.91 KB.
* The response may include multiple customer records, each with their own details.
