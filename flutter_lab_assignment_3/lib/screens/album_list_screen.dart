import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab_assignment_3/blocs/album_list/album_list_bloc.dart';
import 'package:flutter_lab_assignment_3/blocs/album_list/album_list_event.dart';
import 'package:flutter_lab_assignment_3/blocs/album_list/album_list_state.dart';
import 'package:flutter_lab_assignment_3/models/album.dart';
import 'package:go_router/go_router.dart';
class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlbumListBloc(
        albumRepository: context.read(),
      )..add(FetchAlbums()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Albums'),
        ),
        body: BlocBuilder<AlbumListBloc, AlbumListState>(
          builder: (context, state) {
            switch (state.status) {
              case AlbumListStatus.initial:
                return const Center(child: Text('Loading albums...'));
              case AlbumListStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case AlbumListStatus.success:
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AlbumListBloc>().add(RefreshAlbums());
                  },
                  child: ListView.builder(
                    itemCount: state.albums.length,
                    itemBuilder: (context, index) {
                      final album = state.albums[index];
                      return AlbumListItem(album: album);
                    },
                  ),
                );
              case AlbumListStatus.failure:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AlbumListBloc>().add(FetchAlbums());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class AlbumListItem extends StatelessWidget {
  final Album album;

  const AlbumListItem({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: album.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  album.thumbnailUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.photo_album),
              ),
        title: Text(
          album.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Album ID: ${album.id}'),
        onTap: () {
          context.go('/album/${album.id}');
        },
      ),
    );
  }
}