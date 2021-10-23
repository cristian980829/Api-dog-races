import 'dart:convert';
import 'package:examen_api/models/dog.dart';
import 'package:examen_api/models/response.dart';
import 'package:http/http.dart' as http;

import 'package:examen_api/helpers/constans.dart';

class ApiHelper {
  static Future<Response> getDogsList() async {
    var url = Uri.parse('${Constans.apiUrl}/api/breeds/list/all');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    List<Dog> list = [];
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      var races = decodedJson['message'];
      for (var key in races.keys) {
        list.add(Dog.fromJson(key, races[key]));
      }
    }

    return Response(isSuccess: true, result: list);
  }
}
