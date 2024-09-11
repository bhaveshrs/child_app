// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class MediaData {
  List<String> image;
  List<String> videos;
  List<String> brochures;
  MediaData({
    this.image = const [],
    this.videos = const [],
    this.brochures = const [],
  });

  MediaData copyWith({
    List<String>? image,
    List<String>? videos,
    List<String>? brochures,
  }) {
    return MediaData(
      image: image ?? this.image,
      videos: videos ?? this.videos,
      brochures: brochures ?? this.brochures,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'videos': videos,
      'brouchers': brochures,
    };
  }

  factory MediaData.fromMap(Map<String, dynamic> map) {
    return MediaData(
      image: List<String>.from(map['image']?.map((x) => x.toString()) ?? []),
      videos: List<String>.from(map['videos']?.map((x) => x.toString()) ?? []),
      brochures:
          List<String>.from(map['brouchers']?.map((x) => x.toString()) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaData.fromJson(String source) =>
      MediaData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MediaData(image: $image, videos: $videos, brouchers: $brochures)';

  @override
  bool operator ==(covariant MediaData other) {
    if (identical(this, other)) return true;

    return listEquals(other.image, image) &&
        listEquals(other.videos, videos) &&
        listEquals(other.brochures, brochures);
  }

  @override
  int get hashCode => image.hashCode ^ videos.hashCode ^ brochures.hashCode;
}
