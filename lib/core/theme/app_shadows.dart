import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Soft shadows for light mode
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0D000000),  // 5% opacity
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x19000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x19000000),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
  ];

  // Glow effect for primary actions
  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x332a6aea),  // primary color with opacity
      offset: Offset(0, 0),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  // Shadow variants for dark mode (more subtle)
  static const List<BoxShadow> shadowSoftDark = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}
