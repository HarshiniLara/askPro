import 'package:flutter/material.dart';

class ViewResponsesPage extends StatelessWidget {
  final String queryTitle;
  final List<dynamic> responses;
  final int queryIndex;
  final Function(int, String) onAddResponse;
  final Function(int, int) onUpvote;
  final Function(int, int) onDownvote;
  final Function(int, int, String) onUpdateResponse;
  final Function(int, int) onDeleteResponse;

  ViewResponsesPage({
    required this.queryTitle,
    required this.responses,
    required this.queryIndex,
    required this.onAddResponse,
    required this.onUpvote,
    required this.onDownvote,
    required this.onUpdateResponse,
    required this.onDeleteResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Responses: $queryTitle'),
        backgroundColor: const Color.fromARGB(255, 133, 187, 232),
      ),
      body: ListView.builder(
        itemCount: responses.length,
        itemBuilder: (context, index) {
          final response = responses[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response ${index + 1}:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                response['response'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      onUpvote(queryIndex, index);
                    },
                  ),
                  Text((response['upvotes'] ?? 0).toString()),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      onDownvote(queryIndex, index);
                    },
                  ),
                  Text((response['downvotes'] ?? 0).toString()),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showUpdateResponseDialog(
                          context, index, response['response']);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      onDeleteResponse(queryIndex, index);
                    },
                  ),
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddResponseDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddResponseDialog(BuildContext context) async {
    TextEditingController _responseController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Response'),
          content: TextField(
            controller: _responseController,
            decoration: InputDecoration(labelText: 'Response'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await onAddResponse(queryIndex, _responseController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateResponseDialog(
      BuildContext context, int responseIndex, String currentResponse) async {
    TextEditingController _responseController =
        TextEditingController(text: currentResponse);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Response'),
          content: TextField(
            controller: _responseController,
            decoration: InputDecoration(labelText: 'Response'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await onUpdateResponse(
                    queryIndex, responseIndex, _responseController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
