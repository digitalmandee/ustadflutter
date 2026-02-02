
 import 'package:intl/intl.dart';

String formatTimeTo12Hour(String time24) {
    try {
      DateTime parsedTime = DateFormat("HH:mm:ss").parse(time24);
      String formattedTime =
          DateFormat("h:mm a").format(parsedTime).toLowerCase();
      return formattedTime; 
    } catch (e) {
      return time24; 
    }
  }