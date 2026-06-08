import 'dart:convert';

import 'package:fluffychat/utils/custom_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'backend_session_service.dart';

class FrontendBuildInfo {
  const FrontendBuildInfo({required this.version});

  final String version;
}

class BackendBuildInfo {
  const BackendBuildInfo({
    required this.version,
    required this.commit,
    required this.buildDate,
  });

  final String version;
  final String commit;
  final String buildDate;
}

class BuildInfoService {
  BuildInfoService({http.Client? httpClient})
    : _httpClient = httpClient ?? CustomHttpClient.createHTTPClient();

  final http.Client _httpClient;

  Future<FrontendBuildInfo> frontendInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return FrontendBuildInfo(version: packageInfo.version);
  }

  Future<BackendBuildInfo> backendInfo({String? apiBaseUrl}) async {
    apiBaseUrl ??= BackendSessionService.defaultApiBaseUrl;
    final response = await _httpClient.get(Uri.parse('$apiBaseUrl/version'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Backend version request failed (${response.statusCode}): ${response.body}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, Object?>;
    return BackendBuildInfo(
      version: json['version'] as String? ?? 'unknown',
      commit: json['commit'] as String? ?? 'unknown',
      buildDate: json['build_date'] as String? ?? 'unknown',
    );
  }
}
