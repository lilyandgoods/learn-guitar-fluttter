int calculateStreak(DateTime lastActive, DateTime now, int currentStreak) {
  final today = DateTime(now.year, now.month, now.day);
  final last = DateTime(lastActive.year, lastActive.month, lastActive.day);
  final diff = today.difference(last).inDays;
  if (diff == 0) return currentStreak;
  if (diff == 1) return currentStreak + 1;
  return 1;
}