import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiService({required this.baseUrl, this.defaultHeaders = const {}});

  Future<http.Response> post(String path, Map<String, dynamic> body, {Map<String,String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _doRequest('POST', uri, body: body, extraHeaders: headers);
  }

  Future<http.Response> get(String path, {Map<String,String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _doRequest('GET', uri, extraHeaders: headers);
  }

  Future<http.Response> _doRequest(String method, Uri uri, {Map<String, dynamic>? body, Map<String, String>? extraHeaders}) async {
    final token = await AuthService().token();
    final combined = {if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token', ...defaultHeaders, if (extraHeaders != null) ...extraHeaders};
    if (method == 'POST') {
      final res = await http.post(uri, headers: {...combined, 'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (res.statusCode == 401) {
        await AuthService().clear();
      }
      return res;
    } else {
      final res = await http.get(uri, headers: combined);
      if (res.statusCode == 401) {
        await AuthService().clear();
      }
      return res;
    }
  }

  Future<Map<String, dynamic>> registerVisitor(Map<String, dynamic> payload) async {
    final res = await post('/visitors', payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> validateQr(String token) async {
    final res = await post('/qrcode/validate', {'token': token});
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> recordEntry(Map<String, dynamic> payload) async {
    await post('/entry', payload);
  }

  Future<http.StreamedResponse> recordEntryWithPhoto(Map<String, dynamic> payload, File photo) async {
    final uri = Uri.parse('$baseUrl/entry');
    final request = http.MultipartRequest('POST', uri);
    final token = await AuthService().token();
    if (token != null) request.headers.addAll({'Authorization': 'Bearer $token'});
    // attach json payload as a field
    request.fields['payload'] = jsonEncode(payload);
    final mimeType = 'image/jpeg';
    final multipartFile = await http.MultipartFile.fromPath('photo', photo.path, contentType: MediaType.parse(mimeType));
    request.files.add(multipartFile);
    return request.send();
  }

  Future<void> recordExit(Map<String, dynamic> payload) async {
    await post('/exit', payload);
  }

  Future<List<Map<String, dynamic>>> fetchHistory({int limit = 50}) async {
    final res = await get('/history?limit=$limit');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchEmergencies() async {
    final res = await get('/emergencies');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> acknowledgeEmergency(String id) async {
    final res = await post('/emergencies/$id/ack', {});
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resolveEmergency(String id) async {
    final res = await post('/emergencies/$id/resolve', {});
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Active visitors currently inside
  Future<List<Map<String, dynamic>>> fetchActiveVisitors() async {
    final res = await get('/visitors/active');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  // Record staff or helper attendance (entry or exit). Backend should dedupe.
  Future<Map<String, dynamic>> recordAttendance(Map<String, dynamic> payload) async {
    final res = await post('/attendance', payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchStaffInside() async {
    final res = await get('/attendance/inside');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }
}
