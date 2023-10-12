import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://127.0.0.1:8081'); // 대상 서버의 엔드포인트 URL을 지정하세요

  // GET 요청 보내기
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('GET 요청 응답: $data');
    } else {
      print('GET 요청 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('GET 요청 예외: $e');
  }

  // POST 요청 보내기
  try {
    final body = jsonEncode({'key': 'value'}); // POST 요청의 본문 데이터를 정의하세요
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('POST 요청 응답: $data');
    } else {
      print('POST 요청 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('POST 요청 예외: $e');
  }
}
