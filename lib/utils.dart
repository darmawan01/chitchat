import 'package:flutter/material.dart';

Future showTransparentModalBottomSheet(
  BuildContext context,
  Widget Function(BuildContext) builder,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}
