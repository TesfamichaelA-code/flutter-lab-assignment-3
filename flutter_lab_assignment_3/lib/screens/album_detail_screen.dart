import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lab_assignment_3/blocs/album_detail/album_detail_bloc.dart';
import 'package:flutter_lab_assignment_3/blocs/album_detail/album_detail_event.dart';
import 'package:flutter_lab_assignment_3/blocs/album_detail/album_detail_state.dart';
import 'package:flutter_lab_assignment_3/models/photo.dart';

class AlbumDetailScreen extends StatelessWidget {
  final int albumId;

  const AlbumDetailScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlbumDetailBloc(
        albumRepository: context.read(),
      )..add(FetchAlbumDetail(albumId: albumId)),
      child: Scaffold(
        appBar: AppBar(
          // Add a leading back button explicitly
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to the list screen
              context.go('/');
            },
          ),
          title: BlocBuilder<AlbumDetailBloc, AlbumDetailState>(
            buildWhen: (previous, current) => 
                previous.album?.title != current.album?.title,
            builder: (context, state) {
              return Text(state.album?.title ?? 'Album Details');
            },
          ),
        ),
        body: BlocBuilder<AlbumDetailBloc, AlbumDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case AlbumDetailStatus.initial:
              case AlbumDetailStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case AlbumDetailStatus.success:
                return _buildAlbumDetail(context, state);
              case AlbumDetailStatus.failure:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AlbumDetailBloc>().add(
                                FetchAlbumDetail(albumId: albumId),
                              );
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

  Widget _buildAlbumDetail(BuildContext context, AlbumDetailState state) {
    final album = state.album;
    if (album == null) {
      return const Center(child: Text('Album not found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Album ID: ${album.id}'),
                Text('User ID: ${album.userId}'),
                const SizedBox(height: 16),
                const Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          state.photos.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No photos found for this album'),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.photos.length,
                  itemBuilder: (context, index) {
                    final photo = state.photos[index];
                    return PhotoGridItem(photo: photo);
                  },
                ),
        ],
      ),
    );
  }
}

class PhotoGridItem extends StatelessWidget {
  final Photo photo;

  const PhotoGridItem({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              photo.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              photo.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}