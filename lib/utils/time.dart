import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stars/generated/l10n.dart';

String formatTimestamp(
  BuildContext context,
  DateTime timestamp, {
  DateTime Function()? clock,
}) {
  final now = (clock?.call() ?? DateTime.now()).toLocal();
  final localTimestamp = timestamp.toLocal();
  final localeName = Localizations.localeOf(context).toString();

  if (localTimestamp.isAfter(now)) {
    return _formatAbsoluteTimestamp(localTimestamp, now, localeName);
  }
  if (!_isSameCalendarDate(localTimestamp, now)) {
    return DateFormat.yMd(localeName).format(localTimestamp);
  }

  final difference = now.difference(localTimestamp);
  if (difference.inHours > 0) {
    return DateFormat.jm(localeName).format(localTimestamp);
  }
  if (difference.inMinutes > 0) {
    return S.of(context).minutesAgo(difference.inMinutes);
  }
  return S.of(context).justNow;
}

String _formatAbsoluteTimestamp(
  DateTime timestamp,
  DateTime now,
  String localeName,
) =>
    _isSameCalendarDate(timestamp, now)
        ? DateFormat.jm(localeName).format(timestamp)
        : DateFormat.yMd(localeName).format(timestamp);

bool _isSameCalendarDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
