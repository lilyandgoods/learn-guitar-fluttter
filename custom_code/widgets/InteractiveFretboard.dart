import 'package:flutter/material.dart';

class InteractiveFretboard extends StatelessWidget {
  final int frets;
  final List<double> stringFrequencies; // low E -> high E
  final Map<int, List<int>> highlightedFrets; // stringIndex -> [fretNumbers]
  final void Function(int stringIndex, int fret)? onNoteTap;

  const InteractiveFretboard({
    super.key,
    this.frets = 12,
    required this.stringFrequencies,
    this.highlightedFrets = const {},
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: frets / 6,
      child: Column(
        children: List.generate(6, (s) {
          final stringIndex = 5 - s; // visual top is high E
          return Expanded(
            child: Row(
              children: List.generate(frets + 1, (fret) {
                final isNut = fret == 0;
                final isOn = highlightedFrets[stringIndex]?.contains(fret) ?? false;
                return Expanded(
                  child: InkWell(
                    onTap: onNoteTap == null ? null : () => onNoteTap!(stringIndex, fret),
                    child: Container(
                      margin: EdgeInsets.only(right: fret == frets ? 0 : 2),
                      decoration: BoxDecoration(
                        color: isOn ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : null,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade400, width: 1),
                          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
                          right: BorderSide(color: Colors.grey.shade300, width: isNut ? 2 : 1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isNut
                          ? const Text('●', style: TextStyle(fontSize: 10, color: Colors.grey))
                          : (fret == 3 || fret == 5 || fret == 7 || fret == 9 || fret == 12)
                              ? const Text('•', style: TextStyle(fontSize: 10, color: Colors.grey))
                              : null,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}