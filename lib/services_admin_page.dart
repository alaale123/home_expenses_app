import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ServicesAdminPage extends StatefulWidget {
  @override
  State<ServicesAdminPage> createState() => _ServicesAdminPageState();
}

class _ServicesAdminPageState extends State<ServicesAdminPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String? _imagePath;
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
        _imagePath = picked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Services')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Service Name'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _pickedImage != null
                          ? Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 32, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    ElevatedButton(
                      child: Text('Upload Image'),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  child: Text('Add Service'),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && descController.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('services').add({
                        'name': nameController.text,
                        'description': descController.text,
                        'imagePath': _pickedImage?.path ?? '',
                      });
                      nameController.clear();
                      descController.clear();
                      setState(() {
                        _pickedImage = null;
                        _imagePath = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    Widget leadingWidget;
                    if (data['imagePath'] != null && data['imagePath'].toString().isNotEmpty) {
                      leadingWidget = Image.file(
                        File(data['imagePath']),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    } else {
                      leadingWidget = Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image, color: Colors.grey),
                      );
                    }
                    return ListTile(
                      leading: leadingWidget,
                      title: Text(data['name'] ?? ''),
                      subtitle: Text(data['description'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await docs[i].reference.delete();
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
    );
  }
}
