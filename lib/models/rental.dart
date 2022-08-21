
import 'package:flutter/material.dart';

class RentalBuilder {
  String? id;
  String? userId;
  String? itemId;
  String? start;
  String? end;
  double? totalCost;
  String? currency;
  bool? isPayed;
  String? dueDate;
  List<String>? notedDamages;
  List<String>? damageImagesPaths;
  String? endImagesPaths;
}

class Rental with ChangeNotifier {
  String? id;
  String? userId;
  String? itemId;
  String? start;
  String? end;
  double? totalCost;
  String? currency;
  bool? isPayed;
  String? dueDate;
  List<String>? notedDamages;
  List<String>? damageImagesPaths;
  String? endImagesPaths;

  Rental(RentalBuilder builder) {
    id = builder.id;
    userId = builder.userId;
    itemId = builder.itemId;
    start = builder.start;
    end = builder.end;
    totalCost = builder.totalCost;
    currency = builder.currency;
    isPayed = builder.isPayed;
    dueDate = builder.dueDate;
    notedDamages = builder.notedDamages;
    damageImagesPaths = builder.damageImagesPaths;
    endImagesPaths = builder.endImagesPaths;
  }
}
