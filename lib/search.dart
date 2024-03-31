import 'package:flutter/material.dart';

class QuerySearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> queries;

  QuerySearchDelegate(this.queries);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredQueries = queries.where((query) {
      final queryText = query['query'].toString().toLowerCase();
      final input = this.query.toLowerCase();
      return queryText.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: filteredQueries.length,
      itemBuilder: (context, index) {
        final query = filteredQueries[index];
        return ExpansionTile(
          title: Text(query['query']),
          subtitle: Text(query['description'] ?? ''),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: query['responses']?.length ?? 0,
              itemBuilder: (context, responseIndex) {
                final response = query['responses'][responseIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Response ${responseIndex + 1}:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      response['response'] ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Divider(),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
