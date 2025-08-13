int bpmFromTapTimes(List<int> timestampsMs) {
  if (timestampsMs.length < 2) return 0;
  timestampsMs.sort();
  final intervals = <int>[];
  for (int i = 1; i < timestampsMs.length; i++) {
    intervals.add(timestampsMs[i] - timestampsMs[i - 1]);
  }
  final double avgMs = intervals.reduce((a,b) => a + b) / intervals.length;
  if (avgMs <= 0) return 0;
  final bpm = (60000.0 / avgMs).round();
  if (bpm < 20) return 20;
  if (bpm > 300) return 300;
  return bpm;
}