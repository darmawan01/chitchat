import 'package:flutter/material.dart';

class ContactsModal extends StatefulWidget {
  const ContactsModal({super.key});

  @override
  ContactsModalState createState() => ContactsModalState();
}

class ContactsModalState extends State<ContactsModal> {
  final itemList = [];

  String input = '';

  void addItem() {
    setState(() {
      itemList.add(input);
      input = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),

      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Contacts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter someone name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  input = value;
                });
              },
              onSubmitted: (value) {
                addItem();
              },
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(itemList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
