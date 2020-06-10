import 'package:flutter/material.dart';

class User {
  final String userId;
  final String email;
  final String token;
  final String name;
  final String designation;
  final String mob;
  final String image;

  User(
      {@required this.userId,
      @required this.email,
      @required this.token,
      @required this.name,
      @required this.designation,
      @required this.mob,
      this.image});
}
