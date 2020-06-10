import 'package:flutter/material.dart';

class Entry {
  final String id;
  final String title;
  final String description;
  final String image;
  final double amount;
  final String transactionType;
  final bool isFavourite;
  final String userEmail;
  final String userId;

  Entry(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.transactionType,
      @required this.amount,
      @required this.image,
      @required this.userEmail,
      @required this.userId,
      this.isFavourite = false});
}
