import 'package:flutter/material.dart';

ThemeData defaultTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    appBarTheme: AppBarTheme(
      color: Colors.white,
      shadowColor: Colors.transparent,
      titleSpacing: 20.0,
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      actionsIconTheme: const IconThemeData(
        color: Colors.black54,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black54,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.white,
      background: Colors.white,
    ),
  );
}
