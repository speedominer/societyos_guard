import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config.dart';

final activeVisitorsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ApiService(baseUrl: Config.backendBaseUrl);
  return api.fetchActiveVisitors();
});
