import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart'; // Import the main file to access the queries

class ProfilePage extends StatelessWidget {
  final String username; // Assuming you have a way to get the username
  FirebaseAuth auth = FirebaseAuth.instance;
  ProfilePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: const Color.fromARGB(255, 133, 187, 232),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the queries page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(uid: auth.currentUser!.uid)),
                );
              },
              child: Text('Manage Queries'),
            ),
            SizedBox(height: 16),
            Text(
              'About Ask Pro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ask Pro is a powerful application that allows you to ask questions, receive responses, and upvote or downvote the responses based on their relevance and accuracy. With Ask Pro, you can collaborate with others, share knowledge, and find the best solutions to your queries.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
