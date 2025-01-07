part of 'extensions.dart';

extension DateTimeExtension on DateTime {
  String toLongUIDateTime() {
    bool isWithinSeconds = DateTime.now().difference(this).inSeconds.abs() < 60;
    bool isWithinMinutes = DateTime.now().difference(this).inMinutes.abs() < 60;
    bool isWithinHours = DateTime.now().difference(this).inHours.abs() < 24;
    bool isWithinDays = DateTime.now().difference(this).inDays.abs() < 7;
    bool isWithinWeeks = DateTime.now().difference(this).inDays.abs() < 30;

    if (isWithinSeconds) {
      return 'Just now';
    } else if (isWithinMinutes) {
      return '${DateTime.now().difference(this).inMinutes.abs()} minute${DateTime.now().difference(this).inMinutes.abs() > 1 ? 's' : ''} ago';
    } else if (isWithinHours) {
      return '${DateTime.now().difference(this).inHours.abs()} hour${DateTime.now().difference(this).inHours.abs() > 1 ? 's' : ''} ago';
    } else {
      String day = _toDay(weekday);
      String time = DateFormat('HH:mm a').format(this);
      bool isToday = DateTime.now().day == this.day;
      bool isYesterday = DateTime.now().day - this.day == 1;
      String year = DateTime.now().year == this.year ? '' : ', ${this.year}';
      if (isToday) {
        return 'Today, $time$year';
      } else if (isYesterday) {
        return 'Yesterday, $time$year';
      } else {
        String date = this.day.toString();
        String month = _toMonth(this.month);
        return '$day, $date${suffix()} $month$year, $time';
      }
    }
  }

  String toUIDate() {
    String day = this.day.toString();
    String month = _toMonth(this.month);
    String year = this.year.toString();
    bool isToday = DateTime.now().day == this.day;
    bool isYesterday = DateTime.now().day - this.day == 1;
    int dayDiff = DateTime.now().difference(this).inDays.abs();
    int weekDiff = DateTime.now().difference(this).inDays.abs() ~/ 7;
    int monthDiff = DateTime.now().difference(this).inDays.abs() ~/ 30;
    int yearDiff = DateTime.now().difference(this).inDays.abs() ~/ 365;
    if (isToday) {
      return 'Today';
    } else if (isYesterday) {
      return 'Yesterday';
    } else if (dayDiff >= 2 && dayDiff <= 7) {
      return '$dayDiff days ago';
    } else if (weekDiff >= 1 && weekDiff <= 4) {
      return '$weekDiff week${weekDiff > 1 ? 's' : ''} ago';
    } else if (monthDiff >= 1 && monthDiff <= 12) {
      return '$monthDiff month${monthDiff > 1 ? 's' : ''} ago';
    } else if (yearDiff >= 1) {
      return '$yearDiff year${yearDiff > 1 ? 's' : ''} ago';
    } else {
      return '$day ${month.substring(0, 3)} $year';
    }
  }

  String toShortUIDate({bool shortenYear = false}) {
    String day = this.day.toString();
    String month = _toMonth(this.month);
    String year = this.year.toString();
    return '$day ${month.substring(0, 3)} ${shortenYear ? '\'${year.substring(2)}' : year}';
  }

  String _toDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _toMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String suffix() {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String monthName(bool isShort) {
    switch (month) {
      case 1:
        return isShort ? 'Jan' : 'January';
      case 2:
        return isShort ? 'Feb' : 'February';
      case 3:
        return isShort ? 'Mar' : 'March';
      case 4:
        return isShort ? 'Apr' : 'April';
      case 5:
        return isShort ? 'May' : 'May';
      case 6:
        return isShort ? 'Jun' : 'June';
      case 7:
        return isShort ? 'Jul' : 'July';
      case 8:
        return isShort ? 'Aug' : 'August';
      case 9:
        return isShort ? 'Sep' : 'September';
      case 10:
        return isShort ? 'Oct' : 'October';
      case 11:
        return isShort ? 'Nov' : 'November';
      case 12:
        return isShort ? 'Dec' : 'December';
      default:
        return '';
    }
  }

  String dayName(bool isShort) {
    switch (weekday) {
      case 1:
        return isShort ? 'Mon' : 'Monday';
      case 2:
        return isShort ? 'Tue' : 'Tuesday';
      case 3:
        return isShort ? 'Wed' : 'Wednesday';
      case 4:
        return isShort ? 'Thu' : 'Thursday';
      case 5:
        return isShort ? 'Fri' : 'Friday';
      case 6:
        return isShort ? 'Sat' : 'Saturday';
      case 7:
        return isShort ? 'Sun' : 'Sunday';
      default:
        return '';
    }
  }
}
