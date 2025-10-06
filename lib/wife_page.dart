import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WifePage extends StatelessWidget {
  final String name;
  final String userId;
  const WifePage({super.key, required this.name, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, $name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final husbandEmail = data?['husbandEmail'] ?? '';
                final status = data?['status'] ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (status == 'approved' && husbandEmail.isNotEmpty)
                      Text('Husband: $husbandEmail', style: TextStyle(fontSize: 15)),
                  ],
                );
              },
            ),
            SizedBox(height: 24),
            Text('Submit New Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                // Add expense logic here
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
