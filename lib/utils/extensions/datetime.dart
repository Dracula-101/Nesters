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

  String toShortUIDate() {
    String day = this.day.toString();
    String month = _toMonth(this.month);
    String year = this.year.toString();
    return '$day ${month.substring(0, 3)} $year';
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
}
