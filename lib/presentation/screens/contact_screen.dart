import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('support@dailyexpanse.app'),
                  subtitle: Text('Email support'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.public),
                  title: Text('www.dailyexpanse.app'),
                  subtitle: Text('Visit our website'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
