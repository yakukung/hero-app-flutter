import 'package:flutter_dotenv/flutter_dotenv.dart';

final String httpScheme = dotenv.env['HTTP_SCHEME'] ?? 'http';
final String apiHost = dotenv.env['API_HOST'] ?? 'localhost';
final String apiPort = dotenv.env['API_PORT'] ?? '3000';
final String apiByCloudflaredTunnel =
    dotenv.env['API_BY_CLOUDFLARED_TUNNEL'] ?? 'http://localhost:3000';

// final String apiEndpoint = "$httpScheme://$apiHost:$apiPort";
final String apiEndpoint = apiByCloudflaredTunnel;
