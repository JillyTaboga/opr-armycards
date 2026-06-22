import 'dart:convert';
import 'package:http/http.dart' as http;

class ArmyApiException implements Exception {
  final String message;
  ArmyApiException(this.message);

  @override
  String toString() => message;
}

class ArmyApiService {
  Future<Map<String, dynamic>> fetchArmyData(String armyId) async {
    final url = Uri.parse('https://army-forge.onepagerules.com/api/tts?id=$armyId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ArmyApiException('Erro ao buscar dados: Status ${response.statusCode}\n\n${response.body}');
      }
    } catch (e) {
      if (e is ArmyApiException) {
        rethrow;
      }
      throw ArmyApiException('Erro de rede ou conexão:\n$e');
    }
  }
}
