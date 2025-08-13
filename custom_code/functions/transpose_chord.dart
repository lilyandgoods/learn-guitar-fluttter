const List<String> _sharp = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];

String transposeChord(String chord, int semitones) {
  final RegExp re = RegExp(r'^([A-G]#?)(.*)$');
  final m = re.firstMatch(chord);
  if (m == null) return chord;
  final root = m.group(1)!;
  final rest = m.group(2)!;
  final idx = _sharp.indexOf(root);
  if (idx < 0) return chord;
  final shifted = (idx + semitones) % 12;
  final newIdx = shifted < 0 ? shifted + 12 : shifted;
  return '${_sharp[newIdx]}$rest';
}