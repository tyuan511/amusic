import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laji_music/models/playlist.dart';
import 'package:laji_music/widgets/image_cover.dart';

class PlaylistCoverItem extends StatelessWidget {
  final Playlist data;

  const PlaylistCoverItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/song_list', extra: data.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageCover(
              url: '${data.picUrl}?param=200y200',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }
}
