import 'dart:io';

import 'package:intl/intl.dart';
import 'package:my_chat_journal/domain/entities/category.dart';

/// The element that is created on the event page
class Event {
  String? message;
  File? image;
  bool isBookmarked;
  DateTime sendTime;
  String stringSendTime;
  Category? category;

  Event({
    this.category,
    this.message,
    this.image,
    this.isBookmarked = false,
  })  : sendTime = DateTime.now(),
        stringSendTime = '${DateFormat('hh:mm a').format(DateTime.now())}';

  void updateSendTime() {
    stringSendTime = 'edited ${DateFormat('hh:mm a').format(DateTime.now())}';
  }

  int compareTo(Event other) {
    return sendTime.isAfter(other.sendTime) ? -1 : 1;
  }
}
