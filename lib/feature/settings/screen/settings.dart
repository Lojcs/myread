import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core/helpers/extensions.dart';
import 'settings_sync.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.sync),
              title: Text("Sync"),
              subtitle: Text("Syncing & account settings"),
              onTap:
                  () => context.navigator.push(
                    CupertinoPageRoute(
                      builder: (context) => SettingsSyncPage(),
                    ),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.copyright),
              title: Text("Licenses"),
              subtitle: Text("Syncing & account settings"),
              onTap:
                  () => context.navigator.push(
                    CupertinoPageRoute(
                      builder:
                          (context) => LicensePage(applicationName: "MyRead"),
                    ),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
              subtitle: Text("About information"),
              onTap:
                  () => showAboutDialog(
                    context: context,
                    applicationName: "MyRead",
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
