import 'package:flutter/material.dart';

class BeatPlayerDialog extends StatefulWidget {
  final List<dynamic> events; // Lista de BeatEvent
  final VoidCallback onComplete;

  const BeatPlayerDialog({
    super.key,
    required this.events,
    required this.onComplete,
  });

  @override
  State<BeatPlayerDialog> createState() => _BeatPlayerDialogState();
}

class _BeatPlayerDialogState extends State<BeatPlayerDialog> {
  int _currentEventIndex = -1;
  bool _isPlaying = true;
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  Future<void> _startPlayback() async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < widget.events.length; i++) {
      if (!_isPlaying || !mounted) break;

      final event = widget.events[i];
      final currentTime = DateTime.now().millisecondsSinceEpoch - startTime;
      final waitTime = event.time - currentTime;

      if (waitTime > 0) {
        await Future.delayed(Duration(milliseconds: waitTime));
      }

      if (!mounted) break;

      setState(() {
        _currentEventIndex = i;
        _log.add('🥁 ${event.instrument.toUpperCase()} [${event.time}ms] from ${event.trackName}');
      });
    }
  }

  void _stop() {
    setState(() {
      _isPlaying = false;
    });
    widget.onComplete();
    Navigator.of(context).pop();
  }

  IconData _getInstrumentIcon(String instrument) {
    switch (instrument.toLowerCase()) {
      case 'kick':
        return Icons.album;
      case 'snare':
        return Icons.circle_outlined;
      case 'hihat':
      case 'hihat_ft':
        return Icons.scatter_plot;
      case 'ride':
      case 'tomtom':
      case 'floor_tom':
        return Icons.circle;
      default:
        return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF252526),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_filled,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ejecutando Beats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Reproducción en tiempo real',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _stop,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Progress
            LinearProgressIndicator(
              value: _currentEventIndex >= 0 
                  ? (_currentEventIndex + 1) / widget.events.length 
                  : 0,
              backgroundColor: Colors.grey.shade800,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentEventIndex + 1} / ${widget.events.length} eventos',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Current playing
            if (_currentEventIndex >= 0 && _currentEventIndex < widget.events.length)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getInstrumentIcon(widget.events[_currentEventIndex].instrument),
                      color: Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.events[_currentEventIndex].instrument.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Track: ${widget.events[_currentEventIndex].trackName}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.events[_currentEventIndex].time}ms',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Log
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Registro de ejecución:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3E3E42)),
                ),
                child: ListView.builder(
                  itemCount: _log.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _log[index],
                        style: TextStyle(
                          color: index == _log.length - 1 
                              ? Colors.orange 
                              : Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Courier',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stop button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                label: const Text('Detener'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}