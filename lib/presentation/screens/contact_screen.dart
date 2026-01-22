import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.man_outlined),
                  title: Text('Habibur Rahaman'),
                  subtitle: Text('Web & App Developer'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('iamhabibnu@gmail.com'),
                  subtitle: Text('Email support'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.public),
                  title: Text('www.creativehabib.com'),
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
