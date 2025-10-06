import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WifeApprovalPage extends StatelessWidget {
  final String husbandEmail;
  const WifeApprovalPage({super.key, required this.husbandEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approve Wives')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'wife')
            .where('husbandEmail', isEqualTo: husbandEmail)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No pending wives to approve.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final wifeEmail = data['email'] ?? '';
              final wifeId = docs[i].id;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(wifeEmail),
                  subtitle: Text('Pending approval'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        tooltip: 'Approve',
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('users').doc(wifeId).update({'status': 'approved'});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        tooltip: 'Decline',
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('users').doc(wifeId).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
