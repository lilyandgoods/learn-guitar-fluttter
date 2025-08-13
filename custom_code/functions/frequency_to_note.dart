import 'dart:math';

String frequencyToNote(double frequencyHz) {
  if (frequencyHz <= 0) return '';
  const List<String> names = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
  final double a4 = 440.0;
  final double n = 12 * (log(frequencyHz / a4) / ln2);
  final int midi = (69 + n).round();
  final String name = names[midi % 12];
  final int octave = (midi ~/ 12) - 1;
  return '$name$octave';
}

double noteToFrequency(String noteName) {
  const List<String> names = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
  final RegExp re = RegExp(r'^([A-G]#?)(-?\d+)$');
  final match = re.firstMatch(noteName);
  if (match == null) return 0;
  final name = match.group(1)!;
  final octave = int.parse(match.group(2)!);
  final int semitone = names.indexOf(name);
  final int midi = (octave + 1) * 12 + semitone;
  return 440.0 * pow(2, (midi - 69) / 12.0);
}