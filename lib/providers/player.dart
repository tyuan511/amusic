import 'dart:convert';

import 'package:laji_music/consts/key.dart';
import 'package:laji_music/models/lyric.dart';
import 'package:laji_music/models/player.dart';
import 'package:laji_music/models/song.dart';
import 'package:laji_music/providers/config.dart';
import 'package:laji_music/utils/storage.dart';
import 'package:ncm_api/ncm_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';

part 'player.g.dart';

@Riverpod(keepAlive: true)
class Player extends _$Player {
  final _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? _currPlaylist;

  @override
  PlayerModel build() {
    final json = storage.read(playerStorageKey);
    if (json != null) {
      return PlayerModel.fromJson(jsonDecode(json));
    }

    return const PlayerModel(
      isPlaying: false,
      position: Duration.zero,
      currentSongIdx: null,
      songList: [],
    );
  }

  _saveState() {
    storage.write(playerStorageKey, jsonEncode(state.toJson()));
  }

  Player() {
    _audioPlayer.playerStateStream.listen((e) {
      state = state.copyWith(isPlaying: e.playing);
      _saveState();
    });

    _audioPlayer.positionStream.listen((e) {
      state = state.copyWith(position: e);
      _calcCurrLyric();
      _saveState();
    });

    _audioPlayer.currentIndexStream.listen((e) {
      state = state.copyWith(currentSongIdx: e);
      if (state.currSong != null) {
        _getLyric(state.currSong!);
      }
      _saveState();
    });
  }

  Future<void> _setPlaylist(List<Song> songs) async {
    final res = await getSongURL(songs.map((e) => e.id).toList());
    for (var element in songs) {
      element.url = res.data!.firstWhere((e) => e.id == element.id).url;
    }
    state = state.copyWith(songList: songs.where((value) => value.url != null).toList());
  }

  _getLyric(Song song) async {
    state = state.copyWith(
      lyric: null,
      currentLyricIdx: null,
    );
    final res = await getLyric(song.id);
    state = state.copyWith(
      lyric: LyricRow.fromString(res.lrc.lyric),
      currentLyricIdx: 0,
    );
  }

  _calcCurrLyric() {
    if (state.lyric == null) return;
    var index = state.lyric!.indexWhere((element) => element.time > state.position);
    if (index < 0) index = state.lyric!.length;
    state = state.copyWith(currentLyricIdx: index - 1);
  }

  resume() async {
    final snapshot = state.copyWith();

    _currPlaylist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: (snapshot.songList ?? []).map((e) => e.toAudioSource()).toList());
    await _audioPlayer.setAudioSource(
      _currPlaylist!,
      initialIndex: snapshot.currentSongIdx,
      initialPosition: snapshot.position,
      preload: false,
    );
    if (ref.read(configProvider).autoPlay) {
      await _audioPlayer.play();
    }
  }

  playSongs(List<Song> songs, {int index = 0}) async {
    await _setPlaylist(songs);
    _currPlaylist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: (state.songList ?? []).map((e) => e.toAudioSource()).toList());
    state = state.copyWith(currentSongIdx: index);
    await _audioPlayer.setAudioSource(
      _currPlaylist!,
      initialIndex: index,
      initialPosition: Duration.zero,
      preload: false,
    );
    await _audioPlayer.play();
    _saveState();
  }

  playSong(Song song) async {
    int idx = state.songList!.indexWhere((element) => element.id == song.id);
    if (idx < 0) {
      final res = await getSongURL([song.id]);
      song.url = res.data!.first.url;
      state = state.copyWith(songList: [...state.songList!, song]);
      idx = state.songList!.length - 1;
      _currPlaylist ??=
          ConcatenatingAudioSource(useLazyPreparation: true, shuffleOrder: DefaultShuffleOrder(), children: []);
      _currPlaylist!.insert(idx, song.toAudioSource());
      await _audioPlayer.setAudioSource(_currPlaylist!, initialIndex: idx, initialPosition: Duration.zero);
    }

    await _audioPlayer.seek(Duration.zero, index: idx);
    await _audioPlayer.play();
    _saveState();
  }

  playOrPause() {
    if (!state.isPlaying) {
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }
  }

  prev() {
    _audioPlayer.seekToPrevious();
  }

  next() {
    _audioPlayer.seekToNext();
  }
}
