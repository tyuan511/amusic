import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:laji_music/models/song.dart';

part 'config.g.dart';

@JsonSerializable()
class ConfigModel {
  final ThemeMode themeMode;
  final bool autoPlay;
  final SongLevel level;

  const ConfigModel({required this.themeMode, this.autoPlay = true, this.level = SongLevel.standard});

  ConfigModel copyWith({ThemeMode? themeMode, bool? autoPlay, SongLevel? level, double? volume}) {
    return ConfigModel(
      themeMode: themeMode ?? this.themeMode,
      autoPlay: autoPlay ?? this.autoPlay,
      level: level ?? this.level,
    );
  }

  factory ConfigModel.fromJson(Map<String, dynamic> json) => _$ConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigModelToJson(this);
}
