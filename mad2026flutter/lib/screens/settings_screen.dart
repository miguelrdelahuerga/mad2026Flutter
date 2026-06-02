import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> _signOut() async {
      await FirebaseAuth.instance.signOut();
    }

    Future<void> _showLogoutConfirmationDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text('Are you sure you want to logout?')],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Logout'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _signOut();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showLogoutConfirmationDialog,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
