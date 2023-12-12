// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel(
      isPlaying: json['isPlaying'] as bool,
      position: Duration(microseconds: json['position'] as int),
      currentSongIdx: json['currentSongIdx'] as int?,
      songList: (json['songList'] as List<dynamic>?)
          ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
      lyric: (json['lyric'] as List<dynamic>?)
          ?.map((e) => LyricRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentLyricIdx: json['currentLyricIdx'] as int?,
    );

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'isPlaying': instance.isPlaying,
      'position': instance.position.inMicroseconds,
      'currentSongIdx': instance.currentSongIdx,
      'songList': instance.songList,
      'lyric': instance.lyric,
      'currentLyricIdx': instance.currentLyricIdx,
    };
