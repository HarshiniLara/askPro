import 'package:flutter/material.dart';

class AddQueryPage extends StatefulWidget {
  @override
  _AddQueryPageState createState() => _AddQueryPageState();
}

class _AddQueryPageState extends State<AddQueryPage> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Query'),
        backgroundColor: const Color.fromARGB(255, 133, 187, 232),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(labelText: 'Query'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Pass data back to previous screen
                Navigator.pop(
                  context,
                  {
                    'query': _queryController.text,
                    'description': _descriptionController.text,
                  },
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
