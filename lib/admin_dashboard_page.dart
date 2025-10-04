import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services_admin_page.dart';


class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'inbox') {
                setState(() => _selectedIndex = 0);
              } else if (value == 'approved') {
                setState(() => _selectedIndex = 1);
              } else if (value == 'services') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ServicesAdminPage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'inbox', child: Text('Admin Inbox')),
              PopupMenuItem(value: 'approved', child: Text('Approved Requests')),
              PopupMenuItem(value: 'services', child: Text('Manage Services')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Inbox/messages page
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.settings),
                  label: Text('Manage Services'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ServicesAdminPage()),
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('messages').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No messages/appointments found.'));
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final messageId = docs[index].id;
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(data['subject'] ?? 'No Subject'),
                            subtitle: Text(data['message'] ?? ''),
                            trailing: data['reply'] != null
                                ? const Icon(Icons.mark_email_read, color: Colors.green)
                                : const Icon(Icons.mark_email_unread, color: Colors.red),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final replyController = TextEditingController(text: data['reply'] ?? '');
                                  return AlertDialog(
                                    title: Text(data['subject'] ?? 'Message'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('From: ${data['userEmail'] ?? 'Unknown'}'),
                                        const SizedBox(height: 8),
                                        Text('Message: ${data['message'] ?? ''}'),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: replyController,
                                          decoration: const InputDecoration(labelText: 'Reply'),
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('messages')
                                              .doc(messageId)
                                              .update({'reply': replyController.text});
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Send Reply'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Approved requests/appointments page (placeholder)
          Center(child: Text('Approved Requests/Appointments will appear here.')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Approved',
          ),
        ],
      ),
    );
  }
}
