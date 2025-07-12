import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/services/music_service.dart';

class SleepMusicPage extends ConsumerStatefulWidget {
  const SleepMusicPage({super.key});

  @override
  ConsumerState<SleepMusicPage> createState() => _SleepMusicPageState();
}

class _SleepMusicPageState extends ConsumerState<SleepMusicPage> {
  final MusicService _musicService = MusicService();

  final List<MusicTrack> _musicTracks = [
    MusicTrack(
      id: 'lullaby1',
      title: 'Ninni',
      description: 'Sürekli tekrar eden ninni',
      duration: '∞',
      icon: Icons.music_note,
      color: Colors.purple,
      audioUrl: 'sounds/hairdryer.m4a',
      isLocal: true,
    ),
    MusicTrack(
      id: 'whitenoise',
      title: 'Su Sesi',
      description: 'Sürekli tekrar eden su sesi',
      duration: '∞',
      icon: Icons.waves,
      color: Colors.blue,
      audioUrl: 'sounds/water.m4a',
      isLocal: true,
    ),
    MusicTrack(
      id: 'rain',
      title: 'Süpürge Sesi',
      description: 'Sürekli tekrar eden süpürge sesi',
      duration: '∞',
      icon: Icons.cleaning_services,
      color: Colors.cyan,
      audioUrl: 'sounds/dyson.m4a',
      isLocal: true,
    ),
    MusicTrack(
      id: 'heartbeat',
      title: 'Jakuzi Sesi',
      description: 'Sürekli tekrar eden jakuzi sesi',
      duration: '∞',
      icon: Icons.hot_tub,
      color: Colors.red,
      audioUrl: 'sounds/bath.m4a',
      isLocal: true,
    ),
    MusicTrack(
      id: 'ocean',
      title: 'Pıspıs Sesi',
      description: 'Sürekli tekrar eden pıspıs sesi',
      duration: '∞',
      icon: Icons.pets,
      color: Colors.teal,
      audioUrl: 'sounds/pispis.m4a',
      isLocal: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _musicService.addListener(_onMusicStateChanged);
  }

  void _onMusicStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _musicService.removeListener(_onMusicStateChanged);
    super.dispose();
  }

  void _playMusic(MusicTrack track) {
    _musicService.playMusic(track.id, track.audioUrl, track.isLocal);
  }

  void _stopMusic() {
    _musicService.stopMusic();
  }

  void _showTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Timer Ayarla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.timer, color: Colors.blue),
                title: const Text('15 Dakika'),
                onTap: () {
                  Navigator.of(context).pop();
                  _musicService.setTimerDuration(const Duration(minutes: 15));
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: Colors.green),
                title: const Text('30 Dakika'),
                onTap: () {
                  Navigator.of(context).pop();
                  _musicService.setTimerDuration(const Duration(minutes: 30));
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: Colors.orange),
                title: const Text('45 Dakika'),
                onTap: () {
                  Navigator.of(context).pop();
                  _musicService.setTimerDuration(const Duration(minutes: 45));
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: Colors.red),
                title: const Text('60 Dakika'),
                onTap: () {
                  Navigator.of(context).pop();
                  _musicService.setTimerDuration(const Duration(minutes: 60));
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_off, color: Colors.grey),
                title: const Text('Timer Yok'),
                onTap: () {
                  Navigator.of(context).pop();
                  _musicService.setTimerDuration(Duration.zero);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimerDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Uyku Müziği',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _musicService.selectedDuration.inSeconds > 0
                  ? Icons.timer
                  : Icons.timer_off,
              color:
                  _musicService.selectedDuration.inSeconds > 0
                      ? Colors.blue
                      : Colors.grey,
            ),
            onPressed: _showTimerDialog,
            tooltip: 'Timer Ayarla',
          ),
        ],
      ),
      body: Column(
        children: [
          // Şu anda çalan müzik kartı
          if (_musicService.currentlyPlaying != null) _buildNowPlayingCard(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uyku Müzikleri',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bebeğinizin rahat uyuması için sakinleştirici sesler',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _musicTracks.length,
                      itemBuilder: (context, index) {
                        final track = _musicTracks[index];
                        final isCurrentlyPlaying =
                            _musicService.currentlyPlaying == track.id &&
                            _musicService.isPlaying;

                        return _buildMusicCard(track, isCurrentlyPlaying);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard() {
    final currentTrack = _musicTracks.firstWhere(
      (track) => track.id == _musicService.currentlyPlaying,
      orElse: () => _musicTracks.first,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentTrack.color.withOpacity(0.1),
            currentTrack.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentTrack.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentTrack.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  currentTrack.icon,
                  color: currentTrack.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Şu anda çalıyor',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Text(
                      currentTrack.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (_musicService.isTimerActive &&
                        _musicService.remainingTime.inSeconds > 0)
                      Text(
                        'Kalan süre: ${_musicService.formatTimerDuration(_musicService.remainingTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (_musicService.isPlaying)
                      Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 14,
                            color: currentTrack.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sürekli tekrar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: currentTrack.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _playMusic(currentTrack),
                    icon: Icon(
                      _musicService.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: currentTrack.color,
                      size: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: _stopMusic,
                    icon: Icon(Icons.stop_circle, color: Colors.red, size: 28),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusicCard(MusicTrack track, bool isPlaying) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaying ? track.color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? track.color : Colors.grey.shade200,
          width: isPlaying ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _playMusic(track),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: track.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(track.icon, color: track.color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                track.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                track.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: track.color,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  if (!isPlaying)
                    Text(
                      track.duration,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicTrack {
  final String id;
  final String title;
  final String description;
  final String duration;
  final IconData icon;
  final Color color;
  final String audioUrl;
  final bool isLocal;

  MusicTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
    required this.color,
    required this.audioUrl,
    this.isLocal = false,
  });
}
