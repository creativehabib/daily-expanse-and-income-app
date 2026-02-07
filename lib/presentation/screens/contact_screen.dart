import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
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
                  leading: FaIcon(FontAwesomeIcons.user),
                  title: Text('Habibur Rahaman'),
                  subtitle: Text('Web & App Developer'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.envelope),
                  title: Text('iamhabibnu@gmail.com'),
                  subtitle: Text('Email support'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.globe),
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
