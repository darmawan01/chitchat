import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future showTransparentModalBottomSheet(
  BuildContext context,
  Widget Function(BuildContext) builder,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: builder,
  );
}

Future showConfirmDialog(
  BuildContext context, {
  String? title,
  Widget? content,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      if (Platform.isIOS) {
        return CupertinoAlertDialog(
          title: Text(title ?? "Confirm !"),
          content: content,
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }

      return AlertDialog(
        title: Text(title ?? "Confirm !"),
        content: content,
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

String formatSinceTime(int unixTime) {
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
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  }
}
