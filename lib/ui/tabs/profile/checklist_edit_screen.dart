import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:findmate1/service/tabs/matching/checklist_provider.dart';

class ChecklistEditScreen extends StatefulWidget {
  @override
  _ChecklistEditScreenState createState() => _ChecklistEditScreenState();
}

class _ChecklistEditScreenState extends State<ChecklistEditScreen> {
  Map<String, dynamic> checklistData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('checklists')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          checklistData = doc.data()!;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateChecklist(String key, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('checklists').doc(user.uid).update({
        key: value,
      });
      setState(() {
        checklistData[key] = value;
      });
    }
  }

  void _showEditDialog(String key, String title, dynamic currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$title 수정'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "새로운 값을 입력하세요"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                _updateChecklist(key, controller.text);
                Navigator.pop(context);
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16),
        children: checklistData.entries.map((entry) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entry.value.toString()),
              trailing: Icon(Icons.edit, color: Colors.blue),
              onTap: () {
                _showEditDialog(entry.key, entry.key, entry.value);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
