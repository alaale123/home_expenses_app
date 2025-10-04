import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class TutorTeacher {
  final String name;
  final String profile;
  final String contact;
  TutorTeacher({required this.name, required this.profile, required this.contact});
}

class TutorCourse {
  final String name;
  final String price;
  final List<TutorTeacher> teachers;
  TutorCourse({required this.name, required this.price, List<TutorTeacher>? teachers})
      : teachers = teachers ?? [];
}

class HomeService {
  final String name;
  final String imagePath;
  final String description;
  final List<TutorCourse>? courses; // Only for tutors
  HomeService({
    required this.name,
    required this.imagePath,
    required this.description,
    this.courses,
  });
}

class HomeServicesCard extends StatelessWidget {
  final List<HomeService> services;
  final Function(HomeService) onServiceTap;
  const HomeServicesCard({
    required this.services,
    required this.onServiceTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 260,
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      DateTime? selectedDate;
                      TimeOfDay? selectedTime;
                      final addressController = TextEditingController();
                      final notesController = TextEditingController();
                      int selectedCourseIndex = 0;
                      int selectedTeacherIndex = 0;
                      return StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                          title: Text(service.name),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: service.imagePath.isNotEmpty
                                      ? Image.file(
                                          File(service.imagePath),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/placeholder.png',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                SizedBox(height: 16),
                                Text(service.description, style: TextStyle(fontSize: 16)),
                                SizedBox(height: 12),
                                Divider(),
                                Text('Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Icon(Icons.star_half, color: Colors.amber, size: 20),
                                    SizedBox(width: 8),
                                    Text('4.5/5 (23 reviews)', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                if (service.courses != null && service.courses!.isNotEmpty) ...[
                                  Text('Courses:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  DropdownButton<int>(
                                    value: selectedCourseIndex,
                                    isExpanded: true,
                                    items: List.generate(
                                      service.courses!.length,
                                      (i) => DropdownMenuItem(
                                        value: i,
                                        child: Text('${service.courses![i].name} - ${service.courses![i].price}'),
                                      ),
                                    ),
                                    onChanged: (i) {
                                      setState(() {
                                        selectedCourseIndex = i ?? 0;
                                        selectedTeacherIndex = 0;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Text('Select Teacher:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  if (service.courses![selectedCourseIndex].teachers.isNotEmpty) ...[
                                    DropdownButton<int>(
                                      value: selectedTeacherIndex,
                                      isExpanded: true,
                                      items: List.generate(
                                        service.courses![selectedCourseIndex].teachers.length,
                                        (i) => DropdownMenuItem(
                                          value: i,
                                          child: Text(service.courses![selectedCourseIndex].teachers[i].name),
                                        ),
                                      ),
                                      onChanged: (i) {
                                        setState(() => selectedTeacherIndex = i ?? 0);
                                      },
                                    ),
                                    SizedBox(height: 6),
                                    Text('Profile: ${service.courses![selectedCourseIndex].teachers[selectedTeacherIndex].profile}', style: TextStyle(fontSize: 14)),
                                  ] else ...[
                                    Text('No teachers available for this course.', style: TextStyle(fontSize: 14, color: Colors.red)),
                                  ],
                                  SizedBox(height: 12),
                                  Divider(),
                                  Text('Pricing:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  Text(service.courses![selectedCourseIndex].price, style: TextStyle(fontSize: 14)),
                                ] else ...[
                                  Text('Pricing:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  Text('From ₩25,000 per session', style: TextStyle(fontSize: 14)),
                                ],
                                SizedBox(height: 12),
                                Divider(),
                                Text('Availability:', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text('Mon-Fri: 8am - 8pm', style: TextStyle(fontSize: 14)),
                                Text('Sat-Sun: 10am - 6pm', style: TextStyle(fontSize: 14)),
                                SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.call, size: 28, color: Colors.green),
                                      onPressed: () {
                                        // TODO: Implement call action
                                      },
                                    ),
                                    SizedBox(width: 16),
                                    IconButton(
                                      icon: Icon(Icons.email, size: 28, color: Colors.blue),
                                      onPressed: () {
                                        // TODO: Implement email action
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 18),
                                Divider(),
                                Text('Book this service:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 10),
                                if (service.courses != null && service.courses!.isNotEmpty) ...[
                                  Text('Selected Course: ${service.courses![selectedCourseIndex].name}', style: TextStyle(fontSize: 15)),
                                  SizedBox(height: 4),
                                  if (service.courses![selectedCourseIndex].teachers.isNotEmpty)
                                    Text('Selected Teacher: ${service.courses![selectedCourseIndex].teachers[selectedTeacherIndex].name}', style: TextStyle(fontSize: 15)),
                                  SizedBox(height: 8),
                                ],
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(Duration(days: 365)),
                                          );
                                          if (picked != null) setState(() => selectedDate = picked);
                                        },
                                        child: Text(selectedDate == null ? 'Select Date' : '${selectedDate!.toLocal()}'.split(' ')[0]),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final picked = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (picked != null) setState(() => selectedTime = picked);
                                        },
                                        child: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: addressController,
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: notesController,
                                  decoration: InputDecoration(
                                    labelText: 'Notes (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (selectedDate == null || selectedTime == null || addressController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please fill all required fields.')),
                                  );
                                  return;
                                }
                                if (service.courses != null && service.courses!.isNotEmpty && service.courses![selectedCourseIndex].teachers.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('No teachers available for the selected course.')),
                                  );
                                  return;
                                }
                                // Save booking/request to Firestore
                                final user = FirebaseAuth.instance.currentUser;
                                await FirebaseFirestore.instance.collection('messages').add({
                                  'subject': 'Service Booking: ${service.name}',
                                  'message':
                                      'Service: ${service.name}\n' +
                                      (service.courses != null && service.courses!.isNotEmpty
                                          ? 'Course: ${service.courses![selectedCourseIndex].name}\n' : '') +
                                      (service.courses != null && service.courses!.isNotEmpty && service.courses![selectedCourseIndex].teachers.isNotEmpty
                                          ? 'Teacher: ${service.courses![selectedCourseIndex].teachers[selectedTeacherIndex].name}\n' : '') +
                                      'Date: ${selectedDate!.toLocal()}\nTime: ${selectedTime!.format(context)}\nAddress: ${addressController.text}\nNotes: ${notesController.text}',
                                  'userEmail': user?.email ?? user?.phoneNumber ?? 'Unknown',
                                  'approved': false,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Booking Confirmed'),
                                    content: Text(
                                      service.courses != null && service.courses!.isNotEmpty && service.courses![selectedCourseIndex].teachers.isNotEmpty
                                        ? 'Your booking for ${service.name} (${service.courses![selectedCourseIndex].name}) with ${service.courses![selectedCourseIndex].teachers[selectedTeacherIndex].name} on ${selectedDate!.toLocal()} at ${selectedTime!.format(context)} has been received!'
                                        : 'Your booking for ${service.name} on ${selectedDate!.toLocal()} at ${selectedTime!.format(context)} has been received!'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Book Service'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: service.imagePath.isNotEmpty
                          ? Image.file(
                              File(service.imagePath),
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/placeholder.png',
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            service.description,
                            style: TextStyle(fontSize: 15, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
