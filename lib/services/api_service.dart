import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';

class ApiService {

  static const BASE_URL = "http://localhost:8000/api/v2/service/credit-card";

  Future<CardDataDto?> extractCreditCardData(File image) async {
    print("Entra en extractCreditCardData()");
    var request = http.MultipartRequest('POST', 
      Uri.parse(BASE_URL));

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    try {
      final response = await request.send();
      final jsonResponse = await response.stream.bytesToString();
      print("RESULT\n$jsonResponse");

      final dataDto = CardDataDto.fromRawJson(jsonResponse);
      return dataDto;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

}