import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
const hoursAgo = 3;
final timestamp = now - (hoursAgo * 3600);

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final List<Map<String, dynamic>> callList = [
    {
      'callerName': 'John Doe',
      'callerAvatar': 'https://picsum.photos/id/237/200/300',
      'callTime': timestamp,
    },
    {
      'callerName': 'Jane Doe',
      'callerAvatar': 'https://picsum.photos/id/237/200/300',
      'callTime': timestamp,
    },
    {
      'callerName': 'Jim Doe',
      'callerAvatar': 'https://picsum.photos/id/237/200/300',
      'callTime': timestamp,
    },
  ];

  String _formatCallTime(int unixTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - unixTime;
    if (diff < 60) {
      return '$diff seconds ago';
    } else if (diff < 3600) {
      final minutes = (diff ~/ 60).toString();
      return '$minutes minutes ago';
    } else if (diff < 86400) {
      final hours = (diff ~/ 3600).toString();
      return '$hours hours ago';
    } else {
      final date = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: callList.length,
      itemBuilder: (BuildContext context, int index) {
        final callTime =
            _formatCallTime(int.parse(callList[index]['callTime'].toString()));
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(callList[index]['callerAvatar']),
            ),
            title: Text(callList[index]['callerName']),
            subtitle: Text(callTime),
          ),
        );
      },
    );
  }
}
