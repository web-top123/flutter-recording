String durationToString(Duration? duration) {
  if (duration == null) {
    return '0:00';
  }
  String twoDigits(int n) => (n >= 10) ? '$n' : '0$n';

  final twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour).toInt());
  final twoDigitSeconds = twoDigits(
      duration.inSeconds.remainder(Duration.secondsPerMinute).toInt());
  return '$twoDigitMinutes:$twoDigitSeconds';
}
