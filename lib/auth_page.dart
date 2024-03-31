import 'package:askpro/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginMode = true;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reEnterPasswordController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String? _userId; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoginMode
                      ? _buildLoginForm()
                      : _buildSignupForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      Text(
        'Login',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Email',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          _performLogin();
        },
        child: Text('Login'),
      ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = false;
          });
        },
        child: Text('Signup'),
      ),
    ];
  }

   List<Widget> _buildSignupForm() {
    return [
      Text(
        'Signup',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _reEnterPasswordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Re-enter Password',
        ),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          _performSignup();
        },
        child: Text('Signup'),
      ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = true;
          });
        },
        child: Text('Login'),
      ),
    ];
  }


  
  Future<void> _performLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    await auth.signInWithEmailAndPassword(email: username, password: password);
    if (auth.currentUser != null ) {
      // Store the logged-in user's ID
      _userId = auth.currentUser!.uid;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(uid: _userId!),
        ),
      );
    } else {
      _showErrorMessage('Invalid username or password');
    }
  }

  Future<void> _performSignup() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String reEnterPassword = _reEnterPasswordController.text;

    if (password != reEnterPassword) {
      // Show error message
      _showErrorMessage('Passwords do not match');
      return;
    }

    // Check if the username is already taken
    await auth.createUserWithEmailAndPassword(email: username, password: password);
    if (auth.currentUser != null) {
      _showErrorMessage('Username already exists');
      return;
    }

    // Navigate to LoginPage after successful signup
    setState(() {
      _isLoginMode = true;
    });
    _showSuccessMessage('Signup successful! Please login.');
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
