import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/storage_service.dart';

class GraphQLService {
  final StorageService storageService;
  late final GraphQLClient client;

  static const String _hasuraEndpoint = 'http://161.97.111.142:8080/v1/graphql';
  static const String _adminSecret = 'myadminsecretkey';

  GraphQLService({required this.storageService}) {
    final HttpLink httpLink = HttpLink(_hasuraEndpoint);

    // Dynamic auth link: uses JWT if available, falls back to admin secret
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final jwt = storageService.getAuthToken();
        if (jwt != null && jwt.isNotEmpty && jwt != 'mock-jwt-token') {
          return 'Bearer $jwt';
        }
        // Fallback to admin secret during initial login (before JWT is issued)
        return null;
      },
    );

    // Admin secret link used as fallback header
    final AuthLink adminLink = AuthLink(
      getToken: () async {
        final jwt = storageService.getAuthToken();
        // Only use admin secret if no valid JWT exists yet
        if (jwt == null || jwt.isEmpty || jwt == 'mock-jwt-token') {
          return _adminSecret;
        }
        return null;
      },
      headerKey: 'x-hasura-admin-secret',
    );

    // Chain: try JWT first, admin secret as fallback for login/register calls
    final Link link = authLink.concat(adminLink).concat(httpLink);

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }
}
