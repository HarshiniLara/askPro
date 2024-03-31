import 'package:askpro/auth_page.dart';
import 'package:askpro/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'search.dart';
import 'view_response.dart';
import 'add_response.dart';
import 'profile.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ask Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  final String uid;
  MyHomePage({super.key, required this.uid});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _queries = [];

  @override
  void initState() {
    super.initState();
    _loadQueries();
  }

  Future<void> _loadQueries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? queriesStringList = prefs.getStringList('queries');
    if (queriesStringList != null) {
      List<Map<String, dynamic>> parsedQueries =
          queriesStringList.map<Map<String, dynamic>>((queryString) {
        return jsonDecode(queryString) as Map<String, dynamic>;
      }).toList();
      setState(() {
        _queries = parsedQueries;
      });
    } else {
      setState(() {
        _queries = [];
      });
    }
  }

  Future<void> _saveQueries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> queriesStringList = _queries.map((query) {
      return jsonEncode(query);
    }).toList();
    prefs.setStringList('queries', queriesStringList);
  }

  Future<void> _addQuery(String query, String description) async {
    Map<String, dynamic> newQuery = {
      'query': query,
      'description': description,
      'responses': [],
    };
    _queries.add(newQuery);
    await _saveQueries();
    setState(() {});
  }

  Future<void> _addResponse(int queryIndex, String response) async {
    if (_queries.isNotEmpty &&
        queryIndex >= 0 &&
        queryIndex < _queries.length) {
      Map<String, dynamic> query = _queries[queryIndex];
      List<dynamic> responses = query['responses'] ?? [];
      responses.add({'response': response, 'upvotes': 0, 'downvotes': 0});
      query['responses'] = responses;
      _queries[queryIndex] = query;
      await _saveQueries();
      setState(() {});
    } else {
      print('Error: Unable to add response. Invalid query index.');
    }
  }

  Future<void> _upvote(int queryIndex, int responseIndex) async {
    setState(() {
      final response = _queries[queryIndex]['responses'][responseIndex];
      if (response['upvoted'] == true) {
        response['upvotes'] = (response['upvotes'] ?? 0) - 1;
        response['upvoted'] = false;
      } else {
        response['upvotes'] = (response['upvotes'] ?? 0) + 1;
        response['upvoted'] = true;
      }
      if (response['downvoted'] == true) {
        response['downvotes'] = (response['downvotes'] ?? 0) - 1;
        response['downvoted'] = false;
      }
      _saveQueries();
    });
  }

  Future<void> _downvote(int queryIndex, int responseIndex) async {
    setState(() {
      final response = _queries[queryIndex]['responses'][responseIndex];
      if (response['downvoted'] == true) {
        response['downvotes'] = (response['downvotes'] ?? 0) - 1;
        response['downvoted'] = false;
      } else {
        response['downvotes'] = (response['downvotes'] ?? 0) + 1;
        response['downvoted'] = true;
      }
      if (response['upvoted'] == true) {
        response['upvotes'] = (response['upvotes'] ?? 0) - 1;
        response['upvoted'] = false;
      }
      _saveQueries();
    });
  }

  Future<void> _updateResponse(
      int queryIndex, int responseIndex, String response) async {
    setState(() {
      _queries[queryIndex]['responses'][responseIndex]['response'] = response;
      _saveQueries();
    });
  }

  Future<void> _deleteResponse(int queryIndex, int responseIndex) async {
    setState(() {
      _queries[queryIndex]['responses'].removeAt(responseIndex);
      _saveQueries();
    });
  }

  Future<void> _updateQuery(
      int queryIndex, String query, String description) async {
    setState(() {
      _queries[queryIndex]['query'] = query;
      _queries[queryIndex]['description'] = description;
      _saveQueries();
    });
  }

  Future<void> _deleteQuery(int queryIndex) async {
    setState(() {
      _queries.removeAt(queryIndex);
      _saveQueries();
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask Pro'),
        backgroundColor: const Color.fromARGB(255, 133, 187, 232),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: QuerySearchDelegate(_queries),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _queries.length,
        itemBuilder: (context, index) {
          final query = _queries[index];
          final List<dynamic> responses = query['responses'] ?? [];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Query ${index + 1}:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Query: ${query['query']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Description: ${query['description'] ?? ''}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewResponsesPage(
                                queryTitle: query['query'],
                                responses: responses,
                                queryIndex: index,
                                onAddResponse: _addResponse,
                                onUpvote: _upvote,
                                onDownvote: _downvote,
                                onUpdateResponse: _updateResponse,
                                onDeleteResponse: _deleteResponse,
                              ),
                            ),
                          );
                        },
                        child: Text('View Responses (${responses.length})'),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          _showAddResponseDialog(context, index);
                        },
                        child: Text('Add Response'),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          _showEditQueryDialog(context, index);
                        },
                        child: Text('Edit Query'),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          _deleteQuery(index);
                        },
                        child: Text('Delete Query'),
                      ),
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddQueryPage(),
            ),
          );
          if (result != null) {
            // Add query to list
            await _addQuery(result['query'], result['description']);
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigate to home page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(uid: FirebaseAuth.instance.currentUser!.uid),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Navigate to queries page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(uid:FirebaseAuth.instance.currentUser!.uid),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                // Navigate to profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(username: FirebaseAuth.instance.currentUser!.email!),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddResponseDialog(
      BuildContext context, int queryIndex) async {
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
                await _addResponse(queryIndex, _responseController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditQueryDialog(
      BuildContext context, int queryIndex) async {
    TextEditingController _queryController =
        TextEditingController(text: _queries[queryIndex]['query']);
    TextEditingController _descriptionController =
        TextEditingController(text: _queries[queryIndex]['description']);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Query'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
            ],
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
                await _updateQuery(queryIndex, _queryController.text,
                    _descriptionController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
