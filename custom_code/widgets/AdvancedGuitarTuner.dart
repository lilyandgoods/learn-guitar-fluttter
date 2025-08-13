import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

class AdvancedGuitarTuner extends StatefulWidget {
  final bool autoDetect; // true = detect closest E2–E4 string; false = use targetNote
  final String targetNote; // "E2","A2","D3","G3","B3","E4" (ignored if autoDetect=true)

  const AdvancedGuitarTuner({
    super.key,
    this.autoDetect = true,
    this.targetNote = 'E2',
  });

  @override
  State<AdvancedGuitarTuner> createState() => _AdvancedGuitarTunerState();
}

class _AdvancedGuitarTunerState extends State<AdvancedGuitarTuner> {
  static const List<String> kNoteNames = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
  static const Map<String, double> kStandardStringHz = {
    'E2': 82.41,
    'A2': 110.00,
    'D3': 146.83,
    'G3': 196.00,
    'B3': 246.94,
    'E4': 329.63,
  };

  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late final PitchDetector _detector;

  bool _isListening = false;
  double _frequencyHz = 0.0;
  double _smoothedHz = 0.0;
  double _cents = 0.0;
  double _confidence = 0.0;
  String _nearestString = 'E2';
  String _noteLabel = '-';

  static const int _sampleRate = 44100;
  static const int _bufferSize = 2048;
  static const double _smoothAlpha = 0.2;

  @override
  void initState() {
    super.initState();
    _detector = PitchDetector(_sampleRate, _bufferSize);
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Future<void> _start() async {
    if (_isListening) return;
    try {
      await _audioCapture.start(_onAudio, _onError,
          sampleRate: _sampleRate, bufferSize: _bufferSize);
      setState(() => _isListening = true);
    } catch (e) {
      _onError(Object());
    }
  }

  Future<void> _stop() async {
    if (!_isListening) return;
    try {
      await _audioCapture.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  void _onError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Microphone unavailable. Check permissions.')),
    );
  }

  void _onAudio(dynamic obj) {
    if (obj is! Float32List) return;
    final Float32List floatData = obj;
    if (floatData.isEmpty) return;

    final List<double> samples = floatData.map((e) => e.toDouble()).toList();

    final result = _detector.getPitch(samples);
    if (!result.pitched) return;

    final double detectedHz = result.pitch;
    final double conf = result.confidence;

    if (detectedHz.isNaN || detectedHz <= 0 || conf < 0.5) return;

    _smoothedHz = (_smoothedHz == 0.0)
        ? detectedHz
        : (_smoothedHz * (1.0 - _smoothAlpha) + detectedHz * _smoothAlpha);

    String targetStr = widget.targetNote;
    if (widget.autoDetect) {
      targetStr = _closestStandardString(_smoothedHz);
    }
    final double targetHz = kStandardStringHz[targetStr] ?? _smoothedHz;

    final double cents = _centsOffset(_smoothedHz, targetHz);

    final String noteText = _frequencyToNoteName(_smoothedHz);

    if (!mounted) return;
    setState(() {
      _frequencyHz = _smoothedHz;
      _confidence = conf;
      _nearestString = targetStr;
      _cents = cents.clamp(-100.0, 100.0);
      _noteLabel = noteText;
    });
  }

  String _closestStandardString(double hz) {
    String best = 'E2';
    double bestDiff = double.infinity;
    kStandardStringHz.forEach((name, f) {
      final d = (hz - f).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = name;
      }
    });
    return best;
  }

  double _centsOffset(double freq, double target) {
    if (freq <= 0 || target <= 0) return 0.0;
    return 1200.0 * (math.log(freq / target) / math.ln2);
  }

  String _frequencyToNoteName(double frequencyHz) {
    if (frequencyHz <= 0) return '-';
    const double a4 = 440.0;
    final double n = 12 * (math.log(frequencyHz / a4) / math.ln2);
    final int midi = (69 + n).round();
    final String name = kNoteNames[midi % 12];
    final int octave = (midi ~/ 12) - 1;
    return '$name$octave';
  }

  @override
  Widget build(BuildContext context) {
    final bool inTune = _cents.abs() < 5;
    final bool slightlyOff = _cents.abs() < 20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Text(
          widget.autoDetect ? 'Auto (Standard Tuning)' : 'Target: ${widget.targetNote}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        Text(
          _noteLabel,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_frequencyHz.toStringAsFixed(1)} Hz • ${_nearestString} • conf ${(_confidence * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _TuningMeter(
          cents: _cents,
          inTune: inTune,
          slightlyOff: slightlyOff,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Badge(text: _cents < 0 ? 'Flat' : _cents > 0 ? 'Sharp' : '—'),
            const SizedBox(width: 8),
            _Badge(text: _nearestString),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: Icon(_isListening ? Icons.stop : Icons.mic),
          label: Text(_isListening ? 'Stop Tuner' : 'Start Tuner'),
          onPressed: _isListening ? _stop : _start,
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
        const SizedBox(height: 12),
        Text(
          'Play one open string at a time. Move the needle to center.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TuningMeter extends StatelessWidget {
  final double cents; // -100..100
  final bool inTune;
  final bool slightlyOff;

  const _TuningMeter({
    required this.cents,
    required this.inTune,
    required this.slightlyOff,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = cents.clamp(-50.0, 50.0);
    return SizedBox(
      height: 80,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final center = width / 2;
          final pxPerCent = (width * 0.9) / 100.0; // +/-50 cents spans 90% width
          final needleX = center + clamped * pxPerCent;

          final Color barColor = inTune
              ? Colors.green
              : (slightlyOff ? Colors.amber : Colors.red);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MeterPainter(),
                ),
              ),
              Positioned(
                left: needleX - 2,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: barColor),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 2, height: 80, color: Colors.grey.shade500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MeterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    final double w = size.width;
    final double h = size.height;
    final double y = h * 0.75;

    canvas.drawLine(Offset(w * 0.05, y), Offset(w * 0.95, y), line);

    for (final pct in [0.05, 0.275, 0.5, 0.725, 0.95]) {
      final double x = w * pct;
      final double tickH = (pct == 0.5) ? 18 : 12;
      canvas.drawLine(Offset(x, y - tickH), Offset(x, y + tickH), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}