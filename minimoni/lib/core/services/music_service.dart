import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _setupAudioPlayer();
  }

  AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  bool _isPlaying = false;
  Timer? _musicTimer;
  Duration _selectedDuration = const Duration(minutes: 30);
  bool _isTimerActive = false;
  Duration _remainingTime = const Duration(minutes: 30);

  // Callbacks for UI updates
  List<Function()> _listeners = [];

  void _setupAudioPlayer() {
    // AudioPlayer'ı loop modunda ayarla
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Getters
  String? get currentlyPlaying => _currentlyPlaying;
  bool get isPlaying => _isPlaying;
  bool get isTimerActive => _isTimerActive;
  Duration get remainingTime => _remainingTime;
  Duration get selectedDuration => _selectedDuration;

  void addListener(Function() callback) {
    _listeners.add(callback);
  }

  void removeListener(Function() callback) {
    _listeners.remove(callback);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Future<void> playMusic(String trackId, String audioUrl, bool isLocal) async {
    try {
      if (_currentlyPlaying == trackId && _isPlaying) {
        // Aynı şarkı çalıyorsa durdur
        await _audioPlayer.pause();
        _isPlaying = false;
        _stopTimer();
      } else {
        // Yeni şarkı çal
        if (_currentlyPlaying != trackId) {
          await _audioPlayer.stop();
          await _audioPlayer.dispose();

          // Yeni AudioPlayer oluştur
          _audioPlayer = AudioPlayer();
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);

          if (isLocal) {
            await _audioPlayer.play(AssetSource(audioUrl));
          } else {
            await _audioPlayer.play(UrlSource(audioUrl));
          }
        } else {
          await _audioPlayer.resume();
        }

        _currentlyPlaying = trackId;
        _isPlaying = true;

        // Timer başlat (eğer seçilmişse)
        if (_selectedDuration.inSeconds > 0) {
          _startTimer();
        }
      }
      _notifyListeners();
    } catch (e) {
      print('Müzik çalma hatası: $e');
      // Hata durumunda AudioPlayer'ı yeniden oluştur
      await _audioPlayer.dispose();
      _audioPlayer = AudioPlayer();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    }
  }

  void _startTimer() {
    _musicTimer?.cancel();
    _remainingTime = _selectedDuration;
    _isTimerActive = true;

    _musicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime = _remainingTime - const Duration(seconds: 1);

      if (_remainingTime.inSeconds <= 0) {
        // Timer süresi doldu, müziği durdur
        stopMusic();
        timer.cancel();
      } else {
        _notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _musicTimer?.cancel();
    _isTimerActive = false;
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _isPlaying = false;
    _currentlyPlaying = null;
    _stopTimer();
    _notifyListeners();
  }

  void setTimerDuration(Duration duration) {
    _selectedDuration = duration;
    _remainingTime = duration;
    _notifyListeners();
  }

  String formatTimerDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _audioPlayer.dispose();
    _musicTimer?.cancel();
    _listeners.clear();
  }
}
