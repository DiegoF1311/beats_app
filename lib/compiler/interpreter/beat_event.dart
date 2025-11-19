class BeatEvent {
  final String instrument;
  final int time; // En milisegundos
  final String trackName;

  BeatEvent({
    required this.instrument,
    required this.time,
    required this.trackName,
  });

  @override
  String toString() => '$instrument at ${time}ms (from $trackName)';
}