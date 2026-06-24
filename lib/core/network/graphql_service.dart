import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink _httpLink = HttpLink(
    'http://161.97.111.142:8080/v1/graphql',
  );

  static final AuthLink _authLink = AuthLink(
    getToken: () async => 'myadminsecretkey',
    headerKey: 'x-hasura-admin-secret',
  );

  static final Link _link = _authLink.concat(_httpLink);

  final GraphQLClient client;

  GraphQLService()
      : client = GraphQLClient(
          cache: GraphQLCache(),
          link: _link,
        );
}
