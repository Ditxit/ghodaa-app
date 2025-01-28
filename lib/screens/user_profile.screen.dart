import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/profile_placeholder.png',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'johndoe@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            // Settings Section
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Account Settings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountSettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Switch(
                value: true, // Replace with actual state
                onChanged: (value) {
                  // Handle toggle logic
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Privacy Settings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacySettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Help & Support
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle logout
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: Center(
        child: Text('Account Settings Page'),
      ),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy Settings')),
      body: Center(
        child: Text('Privacy Settings Page'),
      ),
    );
  }
}
