import 'package:agrinix/core/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:agrinix/data/community_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';
  ThemeMode selectedTheme = ThemeMode.system;

  // Demo user info
  final int userId = 23;
  final String userName = 'Dickson Daniel Peprah';

  CommunityData communityData = CommunityData();

  List<Map<String, dynamic>> get userPosts =>
      communityData.messages.where((msg) => msg['authorId'] == userId).toList();

  List<Map<String, dynamic>> get userResponses {
    List<Map<String, dynamic>> responses = [];
    for (var msg in communityData.messages) {
      if (msg['responses'] != null) {
        for (var resp in msg['responses']) {
          if (resp['responseAuthor'] == userName) {
            responses.add({
              'messageTitle': msg['messageTitle'],
              'responseBody': resp['responseBody'],
              'responseLikes': resp['responseLikes'],
              'responseDislikes': resp['responseDislikes'],
            });
          }
        }
      }
    }
    return responses;
  }

  String get userRank {
    final postCount = userPosts.length;
    final responseCount = userResponses.length;
    if (postCount > 10 || responseCount > 20) {
      return 'Top Contributor';
    } else if (postCount > 3 || responseCount > 5) {
      return 'Active Member';
    } else {
      return 'Newbie';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate a refresh, or reload user/community data here
          await Future.delayed(Duration(seconds: 1));
          setState(() {});
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // User Profile Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/32.jpg',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'dickson@example.com',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement profile edit
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // My Community Activity Section
            Text(
              'My Community Activity',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.green[700]),
                    SizedBox(width: 12),
                    Text(
                      'Rank: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userRank,
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            ExpansionTile(
              leading: Icon(Icons.forum),
              title: Text('My Posts (${userPosts.length})'),
              children:
                  userPosts.isEmpty
                      ? [ListTile(title: Text('No posts yet.'))]
                      : userPosts
                          .map(
                            (post) => ListTile(
                              title: Text(post['messageTitle'] ?? ''),
                              subtitle: Text(
                                post['messageBody'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
            ),
            ExpansionTile(
              leading: Icon(Icons.reply),
              title: Text('My Responses (${userResponses.length})'),
              children:
                  userResponses.isEmpty
                      ? [ListTile(title: Text('No responses yet.'))]
                      : userResponses
                          .map(
                            (resp) => ListTile(
                              title: Text(resp['messageTitle'] ?? ''),
                              subtitle: Text(
                                resp['responseBody'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text('${resp['responseLikes'] ?? 0}'),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text('${resp['responseDislikes'] ?? 0}'),
                                ],
                              ),
                            ),
                          )
                          .toList(),
            ),
            SizedBox(height: 24),

            // App Settings Section
            Text('App Settings', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                items:
                    ['English', 'French', 'Swahili']
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedLanguage = value;
                    });
                  }
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Theme'),
              trailing: DropdownButton<ThemeMode>(
                value: selectedTheme,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTheme = value;
                    });
                  }
                },
              ),
            ),
            SwitchListTile(
              secondary: Icon(Icons.notifications_active),
              title: Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            SizedBox(height: 24),

            // Account Section
            Text('Account', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Change Password'),
              onTap: () async {
                // TODO: Implement change password
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                if (mounted) {
                  final AppServices services = AppServices();
                  await services.deleteFromStorage('token');
                  await services.deleteFromStorage('userId');

                  context.go('/');
                }
              },
            ),
            SizedBox(height: 24),

            // About Section
            Text('About', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('App Version'),
              trailing: Text('1.0.0'),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy Policy'),
              onTap: () {
                // TODO: Open privacy policy
              },
            ),
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text('Terms of Service'),
              onTap: () {
                // TODO: Open terms of service
              },
            ),
          ],
        ),
      ),
    );
  }
}
